data "aws_iam_policy_document" "access" {
  statement {
    sid    = "CreateRepos"
    effect = "Allow"
    actions = [
      "ecr:CreateRepository",
      "ecr:PutImageScanningConfiguration",
      "ecr:PutImageTagMutability",
      "ecr:PutLifecyclePolicy",
      "ecr:TagResource"
    ]
    resources = [
      "arn:aws:ecr:${local.current_region}:${local.current_account_id}:repository/*"
    ]
  }
  statement {
    sid     = "DescribeRepos"
    effect  = "Allow"
    actions = ["ecr:DescribeRepositories"]
    resources = [
      "arn:aws:ecr:${local.current_region}:${local.current_account_id}:repository/*"
    ]
  }
  statement {
    sid    = "WriteLogGroup"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.this.arn}:*"
    ]
  }
}

data "aws_iam_policy_document" "assume" {
  statement {
    sid     = "AllowAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "dynamic-create-ecr-repo-lambda-role-${local.current_region}"
  description        = "Role for ecr repo create lambda."
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = merge({ Name = local.full_name }, local.common_tags)
}

resource "aws_iam_role_policy" "this" {
  name_prefix = "dynamic-create-ecr-repo-lambda-policy-${local.current_region}"
  policy      = data.aws_iam_policy_document.access.json
  role        = aws_iam_role.this.id
}