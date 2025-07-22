# Atun Supplementary Terraform Modules
This repository contains supplementary Terraform modules to be used with the Atun.io

## Modules

### iam-group-ssm-access

This module creates an IAM policy that allows SSM port forwarding sessions to EC2 instances and optionally attaches it to an IAM group.

#### Features

- Creates an IAM policy that allows:
  - Starting, describing, getting, and terminating SSM sessions
  - Using AWS port forwarding session documents
  - Starting sessions to EC2 instances with specific environment tags
  - Listing EC2 instances and their tags
- Optionally attaches the policy to an existing IAM group

#### Usage

```hcl
module "ssm_access" {
  source = "github.com/dimmkirr/terraform-aws-atun//modules/iam-group-ssm-access"
  
  env           = "dev"
  name          = "ssm-port-forwarding"
  iam_group_name = "developers"
  attach_policy = true
}
```

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| env | Environment name | `string` | n/a | yes |
| name | Name of the access policy | `string` | `"ssm-port-forwarding"` | no |
| iam_group_name | Name of AWS IAM Group to which attach the access policy | `string` | `""` | no |
| attach_policy | Whether attach policy to IAM group. Disable for external attachment | `bool` | `true` | no |

#### Outputs

| Name | Description |
|------|-------------|
| policy_arn | ARN of the created IAM policy |

### iam-ssm-tunnel-access

This module creates an IAM policy that allows SSM port forwarding sessions to EC2 instances and optionally attaches it to multiple IAM entities (groups, roles, users).

#### Features

- Creates an IAM policy that allows:
  - Starting, describing, getting, and terminating SSM sessions
  - Using AWS port forwarding session documents
  - Starting sessions to EC2 instances with specific environment tags and additional custom tags
  - Listing EC2 instances and their tags
- Supports attaching the policy to multiple IAM entities:
  - Multiple IAM groups
  - Multiple IAM roles
  - Multiple IAM users
- Allows additional EC2 instance tag filtering beyond the default Atun environment tag

#### Usage

```hcl
module "ssm_tunnel_access" {
  source = "github.com/dimmkirr/terraform-aws-atun//modules/iam-ssm-tunnel-access"
  
  env           = "dev"
  name          = "ssm-port-forwarding"
  
  # Attach to multiple IAM entities
  iam_group_arns = ["arn:aws:iam::123456789012:group/developers", "arn:aws:iam::123456789012:group/operators"]
  iam_role_arns  = ["arn:aws:iam::123456789012:role/admin-role"]
  iam_user_arns  = ["arn:aws:iam::123456789012:user/specific-user"]
  
  # Additional EC2 instance tag filtering
  ec2_allow_tags = {
    "service" = "database"
    "access-level" = "restricted"
  }
}
```

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| env | Environment name | `string` | n/a | yes |
| name | Name of the access policy | `string` | `"ssm-port-forwarding"` | no |
| iam_group_arns | ARNs of AWS IAM Groups to which attach the access policy | `list(string)` | `[]` | no |
| iam_role_arns | ARNs of AWS IAM Roles to which attach the access policy | `list(string)` | `[]` | no |
| iam_user_arns | ARNs of AWS IAM Users to which attach the access policy | `list(string)` | `[]` | no |
| attach_policy | Whether attach policy to IAM entities. Disable for external attachment | `bool` | `true` | no |
| ec2_allow_tags | Tags to filter EC2 instances for which to allow SSM port forwarding sessions. This is optional and additional to atun tags | `map(string)` | `{}` | no |

#### Outputs

| Name | Description |
|------|-------------|
| policy_arn | ARN of the created IAM policy |
