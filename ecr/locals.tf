locals {
  common_tags        = merge({ "managed-by" = "terraform" })
  current_region     = data.aws_region.current.name
  current_account_id = data.aws_caller_identity.current.account_id
  full_name          = "dynamic-create-ecr-repo-${local.current_region}"
  repo_tags          = merge(var.REPO_TAGS)
}