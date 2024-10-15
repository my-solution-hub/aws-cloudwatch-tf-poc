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

## Deploy Infrastructure

``` shell
export TFSTATE_KEY=aws-solutins/cloudwatch-eks-poc
export TFSTATE_BUCKET=$(aws s3 ls --output text | awk '{print $3}' | grep my-tfstate-)
# current s3 bucket located region
export TFSTATE_REGION=<bucket-region>

# default is ap-southeast-1
export TF_VAR_region=<resource-region>
export TF_VAR_username=<EKS-access-IAM-user>
```

``` shell
terraform init -backend-config="bucket=${TFSTATE_BUCKET}" -backend-config="key=${TFSTATE_KEY}" -backend-config="region=${TFSTATE_REGION}"

terraform apply --auto-approve

aws eks update-kubeconfig --name cloudwatch-poc --region $TF_VAR_region --alias cloudwatch-poc

```

## Deploy Application

``` shell
# enabld application signals auto-discovery
aws application-signals start-discovery

# get information for deployment
export ACCOUNT_ID=`aws sts get-caller-identity --query "Account" --output text`

export MSK_BOOTSTRAP_ADDRESSES=`terraform output -raw msk_bootstrap_addresses`

export REDIS_USER=`terraform output redis_user`

export REDIS_PASSWORD=`terraform output redis_password`

export REDIS_ENDPOINT=`terraform output redis_endpoint`

export APP_VERSION=v0.1

export ECR_ENDPOINT=$ACCOUNT_ID.dkr.ecr.$TF_VAR_region.amazonaws.com

cd ../apps/hello

sh ./build-push.sh $ECR_ENDPOINT $APP_VERSION
envsubst < k8s.yaml | kubectl apply -f -

cd ../world
sh ./build-push.sh $ECR_ENDPOINT $APP_VERSION
envsubst < k8s.yaml | kubectl apply -f -

# move back to root directory
cd ../..

```

## Test Application

## Cleanup

``` shell

# make sure you have the environment values set

terraform init -backend-config="bucket=${TFSTATE_BUCKET}" -backend-config="key=${TFSTATE_KEY}" -backend-config="region=${TFSTATE_REGION}"

terraform destroy --auto-approve
```
