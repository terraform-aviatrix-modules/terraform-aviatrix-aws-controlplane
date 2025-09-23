# terraform-aviatrix-aws-controlplane - release notes

## v1.0.5
- Increase timeout for fetching controller image data.

## v1.0.4
- Add cloudshell launch option
- Add ability to disable termination protection

## v1.0.3
- Fix an issue with security groups

## v1.0.2
- Update security group entries for controller to allow copilot to connect on tcp ports 50441-50443.

## v1.0.1
- Solve issue where g3 images were selected by default. To deploy g3 images with this module, use the 0.9.x release train.
- Added output for VPC ID

## v1.0.0
g4 image support