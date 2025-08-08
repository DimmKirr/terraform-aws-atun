
resource "aws_iam_group_policy_attachment" "iam_group" {
  for_each = toset(var.attach_policy ? var.iam_group_arns : [])
  group      = regex("^arn:aws:iam::[0-9]+:group/(.+)$", each.value)[0]

  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_policy" "this" {
  name        = "${var.env}-${var.name}"
  description = "Allow SSM sessions/port-forward + RunCommand for tagged EC2 instances (atun)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # StartSession / SendCommand on *tagged* EC2 instances
      {
        Sid      = "SSMOnTaggedInstances"
        Effect   = "Allow"
        Action   = ["ssm:StartSession", "ssm:SendCommand"]
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          StringEquals = merge({
            "aws:ResourceTag/atun.io/env" = var.env
          }, var.ec2_allow_tags)
        }
      },

      # Session Manager docs (no tag condition possible)
      {
        Sid      = "SSMSessionDocuments"
        Effect   = "Allow"
        Action   = "ssm:StartSession"
        Resource = [
          "arn:aws:ssm:*:*:document/AWS-StartPortForwardingSession",
          "arn:aws:ssm:*:*:document/AWS-StartPortForwardingSessionToRemoteHost",
          "arn:aws:ssm:*:*:document/AWS-StartSSHSession"
        ]
      },

      # Run Command doc used by your code (no tag condition here)
      {
        Sid      = "SSMRunShellScriptDocument"
        Effect   = "Allow"
        Action   = "ssm:SendCommand"
        Resource = "arn:aws:ssm:*:*:document/AWS-RunShellScript"
      },

      # Read/describe calls that are "*" only
      {
        Sid    = "SSMDescribeAndGet"
        Effect = "Allow"
        Action = [
          "ssm:DescribeSessions",
          "ssm:GetSession",
          "ssm:TerminateSession",
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "ssm:ListCommands",
          "ssm:DescribeInstanceInformation"
        ]
        Resource = "*"
      },

      # EC2 Instance Connect (optional for other code paths); tag-scoped to instances
      {
        Sid      = "AllowEC2InstanceConnect"
        Effect   = "Allow"
        Action   = "ec2-instance-connect:SendSSHPublicKey"
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          StringEquals = merge({
            "aws:ResourceTag/atun.io/env" = var.env
          }, var.ec2_allow_tags)
        }
      },

      # DescribeInstances can be tag-scoped to *instance ARNs*
      {
        Sid      = "DescribeTaggedInstances"
        Effect   = "Allow"
        Action   = "ec2:DescribeInstances"
        Resource = "*"

      },

      # DescribeTags / DescribeImages can't be tag-scoped → must stay "*"
      {
        Sid      = "DescribeTagsAndImages"
        Effect   = "Allow"
        Action   = ["ec2:DescribeTags", "ec2:DescribeImages"]
        Resource = "*"
      }
    ]
  })
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
