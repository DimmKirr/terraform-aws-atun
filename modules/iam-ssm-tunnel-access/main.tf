resource "aws_iam_policy" "this" {
  name        = "${var.env}-${var.name}"
  description = "Policy to allow SSM port forwarding sessions via EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "SSMPortForwardingOnly"
        Effect    = "Allow"
        Action    = [
          "ssm:StartSession",
          "ssm:DescribeSessions",
          "ssm:GetSession",
          "ssm:TerminateSession"
        ]
        Resource  = "*"
      },
      {
        Sid       = "AllowPortForwardingDocuments"
        Effect    = "Allow"
        Action    = [
          "ssm:StartSession"
        ]
        Resource  = [
          "arn:aws:ssm:*:*:document/AWS-StartPortForwardingSession",
          "arn:aws:ssm:*:*:document/AWS-StartPortForwardingSessionToRemoteHost"
        ]
      },
      {
        Sid       = "AllowInstances"
        Effect    = "Allow"
        Action    = [
          "ssm:StartSession"
        ]
        Resource  = [
          "arn:aws:ec2:*:*:instance/*"
        ],
        Condition = {
          StringEquals = merge({
            "aws:ResourceTag/atun.io/env" = var.env # Allow only instances with atun.io schema tags
          }, var.ec2_allow_tags)
        }
      },
      {
        Sid       = "AllowEC2InstanceListing"
        Effect    = "Allow"
        Action    = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource  = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "iam_group" {
  for_each = toset(var.attach_policy ? var.iam_group_arns : [])
  group      = each.value
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_group_policy_attachment" "iam_role" {
  for_each = toset(var.attach_policy ? var.iam_role_arns : [])
  group      = each.value
  policy_arn = aws_iam_policy.this.arn
}


resource "aws_iam_group_policy_attachment" "iam_user" {
  for_each = toset(var.attach_policy ? var.iam_user_arns : [])
  group = each.value
  policy_arn = aws_iam_policy.this.arn
}

