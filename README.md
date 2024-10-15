# aws-cloudwatch-tf-poc

This is a PoC for using AWS CloudWatch services on EKS Java based microservice solution.

## Prerequisites

1. Setup Environment Variables

   ``` shell
   # optional - need to make sure you have the right permissions
   export AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>
   export AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY>
   
   # must have
   export AWS_REGION=<AWS_REGION>
   
   ```

2. aws cli - [install aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. Terraform - [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
4. Helm - [Install Helm](https://helm.sh/docs/intro/install/)
5. S3 bucket for backend

   ``` shell
   aws s3 mb s3://my-tfstate-`aws sts get-caller-identity --query "Account" --output text` --region $AWS_REGION
   ```

6. Download JMX Gatherer and JMX Prometheus Export Manually

   - Select a version and download from the [link](https://mvnrepository.com/artifact/io.opentelemetry.contrib/opentelemetry-jmx-metrics)
   - Download Prometheus Export from the [link](https://github.com/prometheus/jmx_exporter)
   - Put file under `./agent` directory of the applications (both `hello` and `world` application under `./apps`)

## Deploy Infrastructure

``` shell
export TFSTATE_KEY=aws-solutins/cloudwatch-eks-poc
export TFSTATE_BUCKET=$(aws s3 ls --output text | awk '{print $3}' | grep my-tfstate-)
# current s3 bucket located region
export TFSTATE_REGION=<bucket-region>

# default is ap-southeast-1
export TF_VAR_region=<resource-region>
export TF_VAR_username=<EKS-access-IAM-user>

# set a Grafana user
export TF_VAR_grafana_user="xxx@amazon.com"
```

``` shell
terraform init -backend-config="bucket=${TFSTATE_BUCKET}" -backend-config="key=${TFSTATE_KEY}" -backend-config="region=${TFSTATE_REGION}"

terraform apply --auto-approve

aws eks update-kubeconfig --name cloudwatch-poc --region $TF_VAR_region --alias cloudwatch-poc

# Deploy Collector
PROM_PATH=`terraform output -raw prom_remotewrite_endpoint`api/v1/remote_write

cd .. # back to root directory
# update collector configuration
sed  "s|{{PromEndpoint}}|$PROM_PATH|g; s|{{MyRegion}}|$TF_VAR_region|g" ./collector/collector.yaml.template > ./collector/collector.yaml

# update jmx metrics collector configuration
OTLP_ENDPOINT=http://adot-collector-collector.observability:4317
sed  "s|{{adot-server-endpoint}}|$OTLP_ENDPOINT|g" ./apps/hello/agent/session.properties.template > ./apps/hello/agent/session.properties
sed  "s|{{adot-server-endpoint}}|$OTLP_ENDPOINT|g" ./apps/world/agent/session.properties.template > ./apps/world/agent/session.properties

kubectl apply -f "./collector/collector.yaml"

```

## Deploy Application

``` shell
# enabld application signals auto-discovery, once per region
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

mvn clean install
sh ./build-push.sh $ECR_ENDPOINT $APP_VERSION 
envsubst < k8s.yaml | kubectl apply -f -

cd ../world
mvn clean install
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
