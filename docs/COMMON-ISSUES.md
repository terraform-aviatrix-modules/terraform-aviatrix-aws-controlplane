# Common Issues

This page provides solutions to common issues you may encounter when using this Terraform module for Aviatrix AWS Control Plane deployment.

## Troubleshooting Guide

If you're experiencing problems with the module, check the issues below for potential solutions. If your issue isn't listed here, please open a GitHub issue with detailed information about your problem.

---

## Issue: Role with name already exists.

**Symptoms:**
Upon executing a terraform apply you are getting these or similar errors:
- EntityAlreadyExists: Role with name aviatrix-role-ec2 already exists.
- EntityAlreadyExists: Role with name aviatrix-role-app already exists.
- EntityAlreadyExists: A policy called aviatrix-role-ec2-assume-role-policy already exists.
- EntityAlreadyExists: A policy called aviatrix-role-app-app-policy already exists.

**Cause:**
The module assumes by default that no Aviatrix IAM roles and policies have been created and will attempt to create them with their default names. (See **Symptoms** for default names)

**Solution:**
When this occurs you have two options.

1. Reuse the existing roles and policies.
In order to achieve this, we simply need to instruct this module not to create the IAM roles and policies. We can achieve that with the `module_config` argument, which toggles which parts of the module are activated.

```hcl
module "controlplane" {
  <...> #All your other arguments

  module_config = {
    iam_roles                 = false, #This prevents the creation of roles and uses the existing ones.
    controller_deployment     = true,
    controller_initialization = true,
    copilot_deployment        = true,
    copilot_initialization    = true,
    account_onboarding        = true,
  }
}
```

2. Create new roles and policies with a different name.
In order to achieve this, add the `controller_app_role_name` and `controller_ec2_role_name` arguments to your module config, to set custom names:

```hcl
module "controlplane" {
  <...> #All your other arguments

  controller_app_role_name = "MyCustomAppRoleName"
  controller_ec2_role_name = "MyCustomEC2RoleName"
}
```

---

## Additional Resources

- [Module Documentation](../README.md)
- [Aviatrix Documentation](https://docs.aviatrix.com)
- [GitHub Issues](../../issues)