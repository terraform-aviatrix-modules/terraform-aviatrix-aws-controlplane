# terraform-aviatrix-aws-controlplane - release notes

## v1.0.11
- Add support for bring your own EIP for controller and Copilot.

## v1.0.10
- Fix an issue where empty strings propagated to the account_onboarding submodule. This caused the module to error out on account onboarding.
- Allow for additional bootstrap arguments in production deployments.

## v1.0.9
- Fixed an issue where refreshing availability-related data could trigger an unintended controller instance replacement.
- Removed an unused variable.
- Updated EC2 network interface attachment to use the supported (non-deprecated) method.
- Fixed an issue with custom ec2 role names.
- Implemented a mechanism to disable security group management on destroy (Credits @ashishavx)

## v1.0.8
- Fix issue with incorrect AWS provider version

## v1.0.7
- Copilot root disk is now gp3 and encrypted.
- Resolved an issue where empty optional `user_data` values were preventing the controller from fully initializing with the latest g4 image (released 2025-12-22).
- Moved from using `user_data` to using `user_data_base64` for bootstrapping the controller.

## v1.0.6
- Add ability to provide secondary account ID's
- Expose controller data volume size

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