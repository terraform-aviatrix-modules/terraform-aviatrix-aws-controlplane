This is a deployment example for this module.

Execute the following Terraform code:

```hcl
module "copilot_build" {
  source = "./modules/copilot_build"

  use_existing_vpc = true
  subnet_id        = "subnet-123456789"
  vpc_id           = "vpc-123456789"

  controller_public_ip     = "1.2.3.4"
  controller_private_ip    = "10.2.3.4"
  copilot_name             = "my-copilot"
  default_data_volume_name = "/dev/sdf"
  default_data_volume_size = "100"

  allowed_cidrs = {
    "tcp_cidrs" = {
      protocol = "Tcp"
      port     = 443
      cidrs    = ["1.2.3.4/32"]
    }
    "udp_5000_cidrs" = {
      protocol = "Udp"
      port     = 5000
      cidrs    = ["1.2.3.4/32"]
    },
    "udp_31283_cidrs" = {
      protocol = "Udp"
      port     = 31283
      cidrs    = ["1.2.3.4/32"]
    }
  }
}

```