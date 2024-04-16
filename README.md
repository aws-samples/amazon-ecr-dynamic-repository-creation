# Dynamically create repositories upon image push to Amazon ECR

Amazon Elastic Container Registry (Amazon ECR) provides a fully managed container registry service, offering high-performance hosting for reliably deploying application images anywhere. Amazon ECR service requires repositories to pre-exist before pushing container images.

We explore a dynamic solution that leverages AWS CloudTrail, Amazon EventBridge, and AWS Lambda functions to automatically create Amazon ECR repositories on demand. This solution gives you the ability to implement UPSERT in Amazon ECR. By default, detailed events for actions taken in an AWS environment are integrated from CloudTrail into EventBridge. EventBridge is a service that provides real-time access to changes in data in AWS services, your own applications, and Software-as-a-Service (SaaS) applications without writing code. This integration enables monitoring specific event patterns and triggering Lambda functions in response. We create an EventBridge rule to watch for “not found” error messages in the CloudTrail logs of repositories. This rule invokes a Lambda function to create missing repositories just-in-time before pushing images. By doing this, we can significantly streamline the end-user experience by removing the need to manually create repositories beforehand.

This solution is compatible with Docker, Podman, and Finch clients. However, Finch client does not include a built-in retry mechanism today. Therefore, Finch push commands need to be executed twice to make sure container images are pushed. Docker client is used as an example in this post.

## Deployment Steps

**1.** Clone the project from the GitHub source.

```
git clone https://github.com/aws-samples/amazon-ecr-dynamic-repository-creation

cd amazon-ecr-dynamic-repository-creation
```

**2.** Update tfvars with the needed values, or use default values.


```By default, repositories created have the below settings configured. However, should you wish to change the settings, update the tfvars file accordingly.```

`a.` repository scan on push is set to `true`

`b.` image tag mutability is set to `immutable`

`c.` repository scan frequency is set to `scan_on_push`

`d.` scan type is set to `basic`


**3.** Run the following Terraform commands to deploy the needed components.


`a.` Prepare your working directory: `terraform init`

`b.` Check whether the configuration is valid: `terraform validate`

`c.` Show changes required by the current configuration: `terraform plan`

`d.` Create or update infrastructure: `terraform apply --auto-approve`


`Note: To provision resources using terrform, the terraform deployer user or role should have the below IAM permissions at minumum.` 

```json
"iam:CreatePolicy",
"iam:PassRole",
"iam:DeleteRolePolicy",
"iam:TagRole",
"iam:DeletePolicy",
"iam:CreateRole",
"iam:DeleteRole",
"iam:AttachRolePolicy",
"iam:TagPolicy",
"events:TagResource",
"ecr:PutRegistryPolicy",
"lambda:CreateFunction",
"lambda:UpdateFunctionEventInvokeConfig",
"lambda:TagResource",
"lambda:AddPermission",
"lambda:PutFunctionEventInvokeConfig",
"lambda:DeleteFunctionEventInvokeConfig",
"lambda:DeleteFunction",
"lambda:UntagResource",
"lambda:RemovePermission",
"lambda:ListFunctions",
"ecr:GetRegistryPolicy",
"events:PutRule",
"iam:GetRole",
"iam:ListRolePolicies",
"iam:ListAttachedRolePolicies",
"ecr:DeleteRegistryPolicy",
"iam:ListInstanceProfilesForRole",
"events:DescribeRule",
"events:ListTagsForResource",
"events:DeleteRule",
"lambda:GetFunction",
"lambda:ListVersionsByFunction",
"lambda:GetFunctionCodeSigningConfig",
"lambda:GetFunctionEventInvokeConfig",
"lambda:GetPolicy",
"logs:CreateLogGroup",
"events:PutTargets",
"logs:TagResource",
"events:ListTargetsByRule",
"events:RemoveTargets",
"logs:DescribeLogGroups",
"logs:ListTagsLogGroup",
"logs:DeleteLogGroup",
"iam:PutRolePolicy",
"iam:GetRolePolicy"
```