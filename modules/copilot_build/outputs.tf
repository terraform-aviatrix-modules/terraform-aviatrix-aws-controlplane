output "ec2-info" {
  value       = aws_instance.aviatrixcopilot.*
  description = "EC2 instance info"
}

output "private_ip" {
  value       = aws_instance.aviatrixcopilot.private_ip
  description = "Private IP address of the Aviatrix Copilot"
}

output "public_ip" {
  value       = concat(aws_eip.copilot_eip.*.public_ip, [null])[0]
  description = "Public IP address of the Aviatrix Copilot"
}

output "vpc_id" {
  value       = data.aws_vpc.copilot_vpc.id
  description = "VPC ID"
}

output "vpc_name" {
  value       = data.aws_vpc.copilot_vpc.tags.Name
  description = "VPC name"
}

output "region" {
  value       = data.aws_region.current.region
  description = "Current AWS region"
}

output "security_group_id" {
  value       = aws_security_group.AviatrixCopilotSecurityGroup.id
  description = "Copilot Security group ID"
}

output "instance_id" {
  value       = aws_instance.aviatrixcopilot.id
  description = "Copilot Instance ID"
}
