data "aws_caller_identity" "source" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.module}/files/"
  output_path = "${path.module}/files/python.zip"
}