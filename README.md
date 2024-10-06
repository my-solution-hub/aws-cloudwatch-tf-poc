# aws-cloudwatch-tf-poc

This is a PoC for using AWS CloudWatch services on EKS Java based microservice solution.

## Prerequisites

0. Setup Environment Variables

   ``` shell
   # optional - need to make sure you have the right permissions
   export AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>
   export AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY>
   
   # must have
   export AWS_REGION=<AWS_REGION>
   
   ```

1. aws cli - [install aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. Terraform - [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
3. Helm - [Install Helm](https://helm.sh/docs/intro/install/)
4. S3 bucket for backend

   ``` shell
   aws s3 mb s3://my-tfstate-`aws sts get-caller-identity --query "Account" --output text` --region $AWS_REGION
   ```

## Deployment

``` shell
export TFSTATE_KEY=aws-solutins/cloudwatch-eks-poc
export TFSTATE_BUCKET=$(aws s3 ls --output text | awk '{print $3}' | grep my-tfstate-)
export TFSTATE_REGION=$AWS_REGION
# default is ap-southeast-1
export TF_VAR_region=<resource-region>
export TF_VAR_username=<EKS-access-IAM-user>
```

``` shell
terraform init -backend-config="bucket=${TFSTATE_BUCKET}" -backend-config="key=${TFSTATE_KEY}" -backend-config="region=${TFSTATE_REGION}"

terraform apply --auto-approve

aws eks update-kubeconfig --name cloudwatch-poc --region ap-southeast-1 --alias cloudwatch-poc

```

## Cleanup

``` shell
terraform init -backend-config="bucket=${TFSTATE_BUCKET}" -backend-config="key=${TFSTATE_KEY}" -backend-config="region=${TFSTATE_REGION}"

terraform destroy --auto-approve
```