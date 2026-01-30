resource "aws_vpc" "controller_vpc" {
  count      = var.use_existing_vpc ? 0 : 1
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${local.name_prefix}controller_vpc"
  }
}

data "aws_vpc" "controller_vpc" {
  id = var.vpc_id != "" ? var.vpc_id : aws_vpc.controller_vpc[0].id
}

data "aws_eip" "existing_eip" {
  count = var.use_existing_eip ? 1 : 0
  id    = var.eip_id
}

resource "aws_internet_gateway" "igw" {
  count  = var.use_existing_vpc ? 0 : 1
  vpc_id = aws_vpc.controller_vpc[0].id
  tags = {
    Name = "${local.name_prefix}controller_igw"
  }
}

resource "aws_route_table" "public" {
  count  = var.use_existing_vpc ? 0 : 1
  vpc_id = aws_vpc.controller_vpc[0].id
  tags = {
    Name = "${local.name_prefix}controller_rt"
  }
}

resource "aws_route" "public_internet_gateway" {
  count                  = var.use_existing_vpc ? 0 : 1
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
  timeouts {
    create = "5m"
  }
}

resource "aws_subnet" "controller_subnet" {
  count             = var.use_existing_vpc ? 0 : 1
  vpc_id            = aws_vpc.controller_vpc[0].id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "${local.name_prefix}controller_subnet"
  }
}

resource "aws_route_table_association" "rta" {
  count          = var.use_existing_vpc ? 0 : 1
  subnet_id      = aws_subnet.controller_subnet[0].id
  route_table_id = aws_route_table.public[0].id
}

resource "tls_private_key" "key_pair_material" {
  count     = var.use_existing_keypair ? 0 : 1
  algorithm = "ED25519"
}

resource "local_file" "private_key" {
  count           = var.use_existing_keypair ? 0 : 1
  filename        = "${local.name_prefix}controller-priv-key.pem"
  content         = tls_private_key.key_pair_material[0].private_key_openssh
  file_permission = "0600"
}

resource "aws_key_pair" "controller_key_pair" {
  count      = var.use_existing_keypair ? 0 : 1
  key_name   = local.key_pair_name
  public_key = tls_private_key.key_pair_material[0].public_key_openssh
}

resource "aws_security_group" "aviatrix_security_group" {
  name        = "${local.name_prefix}AviatrixSecurityGroup"
  description = "Aviatrix - Controller Security Group"
  vpc_id      = var.use_existing_vpc ? var.vpc_id : aws_vpc.controller_vpc[0].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}controller_security_group"
  })
}

resource "aws_security_group_rule" "ingress_rule_https" {
  count             = length(var.incoming_ssl_cidrs) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.incoming_ssl_cidrs
  security_group_id = aws_security_group.aviatrix_security_group.id
}

resource "aws_security_group_rule" "ingress_rule_ssh" {
  count             = length(var.incoming_ssl_cidrs) > 0 && var.ssh_sg_rule ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.incoming_ssl_cidrs
  security_group_id = aws_security_group.aviatrix_security_group.id
}

resource "aws_security_group_rule" "egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aviatrix_security_group.id
}

resource "aws_eip" "controller_eip" {
  count  = var.use_existing_eip ? 0 : 1
  domain = "vpc"
  tags   = local.common_tags
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.aviatrix_controller.id
  allocation_id = var.use_existing_eip ? var.eip_id : aws_eip.controller_eip[0].id

  lifecycle {
    precondition {
      condition     = !var.use_existing_eip || (var.use_existing_eip && var.eip_id != "")
      error_message = "The controller eip_id must be provided when use_existing_eip is true."
    }
  }
}

resource "aws_network_interface" "eni_controller" {
  subnet_id       = var.use_existing_vpc ? var.subnet_id : aws_subnet.controller_subnet[0].id
  security_groups = [aws_security_group.aviatrix_security_group.id]
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}controller_network_interface"
  })
  lifecycle {
    ignore_changes = [tags, security_groups, subnet_id]
  }
}

resource "aws_instance" "aviatrix_controller" {
  ami                     = local.ami_id
  instance_type           = var.instance_type
  key_name                = local.key_pair_name
  iam_instance_profile    = local.ec2_role_name
  disable_api_termination = var.termination_protection

  primary_network_interface {
    network_interface_id = aws_network_interface.eni_controller.id
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.root_volume_encrypted
    kms_key_id            = var.root_volume_kms_key_id
    delete_on_termination = true
    tags = {
      Name = "${local.name_prefix}controller"
    }
  }

  user_data_base64 = var.user_data != "" ? var.user_data : local.cloud_init

  tags = merge(local.common_tags, {
    Name = local.controller_name
  })

  lifecycle {
    ignore_changes = [
      ami, key_name, user_data, user_data_base64, network_interface
    ]
  }
}
