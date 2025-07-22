module "ssm_tunnel_access" {
  source = "../../modules/iam-ssm-tunnel-access"
  env = "local"
  iam_user_arns = ["arn:aws:iam::123456789012:user/test"]
}
