variable "env" {
  type = string
  description = "Environment name"
}

variable "name" {
  type = string
  description = "Name of the access policy"
  default = "ssm-port-forwarding"
}
variable "iam_group_arns" {
  type        = list(string)
  description = "ARNs of AWS IAM Group to which attach the access policy"
  default     = []
}

variable "iam_role_arns" {
  type        = list(string)
  description = "ARNs of AWS IAM Role to which attach the access policy"
  default     = []
}

variable "iam_user_arns" {
  type        = list(string)
  description = "ARNs of AWS IAM User to which attach the access policy"
  default     = []
}

variable "attach_policy" {
  type    = bool
  description = "Whether attach policy to IAM group. Disable for external attachment"
  default = true
}

variable "ec2_allow_tags" {
  type = map(string)
  description = "Tags to filter EC2 instances for which to allow SSM port forwarding sessions. This is optional and additional to atun tags"
  default = {}
}
