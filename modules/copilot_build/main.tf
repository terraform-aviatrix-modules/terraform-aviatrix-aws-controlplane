resource "aws_vpc" "copilot_vpc" {
  count      = var.use_existing_vpc == false ? 1 : 0
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${local.name_prefix}copilot_vpc"
  }
}

data "aws_vpc" "copilot_vpc" {
  id = var.vpc_id != "" ? var.vpc_id : aws_vpc.copilot_vpc[0].id
}

resource "aws_internet_gateway" "igw" {
  count  = var.use_existing_vpc == false ? 1 : 0
  vpc_id = aws_vpc.copilot_vpc[0].id
  tags = {
    Name = "${local.name_prefix}copilot_igw"
  }
}

resource "aws_route_table" "public" {
  count  = var.use_existing_vpc == false ? 1 : 0
  vpc_id = aws_vpc.copilot_vpc[0].id
  tags = {
    Name = "${local.name_prefix}copilot_rt"
  }
}

resource "aws_route" "public_internet_gateway" {
  count                  = var.use_existing_vpc == false ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
  timeouts {
    create = "5m"
  }
}

resource "aws_subnet" "copilot_subnet" {
  count             = var.use_existing_vpc == false ? 1 : 0
  vpc_id            = aws_vpc.copilot_vpc[0].id
  cidr_block        = var.subnet_cidr
  availability_zone = local.availability_zone
  tags = {
    Name = "${local.name_prefix}copilot_subnet"
  }
}

resource "aws_route_table_association" "rta" {
  count          = var.use_existing_vpc == false ? 1 : 0
  subnet_id      = aws_subnet.copilot_subnet[0].id
  route_table_id = aws_route_table.public[0].id
}

resource "tls_private_key" "key_pair_material" {
  count     = var.use_existing_keypair == false ? 1 : 0
  algorithm = "ED25519"
}

resource "local_file" "private_key" {
  count           = var.use_existing_keypair ? 0 : 1
  filename        = "${local.name_prefix}copilot-priv-key.pem"
  content         = tls_private_key.key_pair_material[0].private_key_pem
  file_permission = "0600"
}

resource "aws_key_pair" "copilot_key_pair" {
  count      = var.use_existing_keypair == false ? 1 : 0
  key_name   = var.key_pair_name
  public_key = tls_private_key.key_pair_material[0].public_key_openssh
}

resource "aws_security_group" "AviatrixCopilotSecurityGroup" {
  name        = "${local.name_prefix}AviatrixCopilotSecurityGroup"
  description = "Aviatrix - Copilot Security Group"
  vpc_id      = var.use_existing_vpc == false ? aws_vpc.copilot_vpc[0].id : var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_cidrs
    content {
      description      = ingress.key
      from_port        = ingress.value["from_port"]
      to_port          = coalesce(ingress.value["to_port"], ingress.value["from_port"])
      protocol         = ingress.value["protocol"]
      cidr_blocks      = ingress.value["cidrs"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  }
  egress = [
    {
      description      = "All out traffic allowed"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}copilot_security_group"
  })

  lifecycle {
    ignore_changes = [
      ingress,
      egress,
    ]
  }
}

resource "aws_eip" "copilot_eip" {
  count = var.private_mode == false ? 1 : 0
  tags  = local.common_tags
}

resource "aws_eip_association" "eip_assoc" {
  count         = var.private_mode == false ? 1 : 0
  instance_id   = aws_instance.aviatrixcopilot.id
  allocation_id = aws_eip.copilot_eip[0].id
}

resource "aws_network_interface" "eni-copilot" {
  subnet_id       = var.use_existing_vpc == false ? aws_subnet.copilot_subnet[0].id : var.subnet_id
  security_groups = [aws_security_group.AviatrixCopilotSecurityGroup.id]
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}copilot_network_interface"
  })

  lifecycle {
    ignore_changes = [
      security_groups,
    ]
  }
}

data "aws_subnet" "subnet" {
  id = var.use_existing_vpc == false ? aws_subnet.copilot_subnet[0].id : var.subnet_id
}

resource "aws_instance" "aviatrixcopilot" {
  ami               = local.ami_id
  instance_type     = local.instance_type
  key_name          = var.key_pair_name
  availability_zone = data.aws_subnet.subnet.availability_zone
  user_data         = <<EOF
#!/bin/bash
jq '.config.controllerIp="${local.controller_ip}" | .config.controllerPublicIp="${local.controller_ip}" | .config.isCluster=${var.is_cluster}' /etc/copilot/db.json > /etc/copilot/db.json.tmp
mv /etc/copilot/db.json.tmp /etc/copilot/db.json
EOF

  network_interface {
    network_interface_id = aws_network_interface.eni-copilot.id
    device_index         = 0
  }

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = var.root_volume_encrypted
    kms_key_id  = var.root_volume_kms_key_id
    tags = {
      Name = "${local.name_prefix}copilot"
    }
  }

  tags = merge(local.common_tags, {
    Name = var.copilot_name != "" ? var.copilot_name : (var.type == "Copilot" ? "${local.name_prefix}AviatrixCopilot" : "${local.name_prefix}AviatrixCopilot_ARM")
  })
}

resource "aws_ebs_volume" "default" {
  count             = var.default_data_volume_name == "" ? 0 : 1
  availability_zone = data.aws_subnet.subnet.availability_zone
  size              = var.default_data_volume_size
  type              = var.default_data_volume_type
  encrypted         = var.default_data_volume_encrypted
  kms_key_id        = var.default_data_volume_kms_key_id
  tags = {
    Name = "${local.name_prefix}copilot_default_data_volume"
  }
}

resource "aws_volume_attachment" "default" {
  count       = var.default_data_volume_name == "" ? 0 : 1
  device_name = var.default_data_volume_name
  volume_id   = aws_ebs_volume.default[0].id
  instance_id = aws_instance.aviatrixcopilot.id
}

resource "aws_volume_attachment" "ebs_att" {
  for_each    = var.additional_volumes
  device_name = each.value.device_name
  volume_id   = each.value.volume_id
  instance_id = aws_instance.aviatrixcopilot.id
}
