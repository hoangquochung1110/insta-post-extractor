# Instagram Post Extractor

This project provides an AWS Lambda function, exposed via API Gateway, designed to extract information from public Instagram posts.

## Architecture

![Architecture Diagram](https://static.ssan.me/IG+Post+Extractor+Diagram.png)

## Features

*   Accepts an Instagram post URL.
*   Fetches the post's metadata (specifically the `og:title`).
*   Uses AWS Bedrock (Language Model) to attempt to extract address-like text from the title.
*   Returns a JSON response containing Google Maps links for any extracted addresses.

## Deployment

The infrastructure (Lambda, API Gateway, CloudWatch Logs) is managed using Terraform. The Lambda function code needs to be packaged into a zip file and uploaded to S3 for deployment (see `INSTALL.md` for packaging steps).

## Local Testing

### Prerequisites

- Docker (required to run AWS SAM locally)
- AWS SAM CLI

### Running tests

Use the provided Makefile to execute the local test suite:

```bash
make test
```

This command will spin up an AWS SAM container via Docker and run the positive and negative test cases defined in `tests/events`.

## Infrastructure as Code (IaC) Best Practices

This project showcases several Infrastructure as Code best practices using Terraform. Here are the key highlights:

### Modular Project Structure

We maintain a clear separation between application code and infrastructure code:

```
project-root/
├── src/                     # Application code
│   └── functions/           # Lambda function code
└── terraform/               # Infrastructure code
    ├── environments/        # Environment-specific configurations
    │   └── dev/             # Dev environment
    └── modules/             # Reusable infrastructure components
        ├── api_gateway/
        ├── cloudwatch/
        ├── iam/
        └── lambda/
```

This separation ensures:
- Clear boundaries between application logic and infrastructure
- Independent lifecycles for code and infrastructure changes
- Easier collaboration between developers and infrastructure engineers

### Modules: Building Blocks for Reuse

We leverage Terraform modules to create reusable infrastructure components:

```
module "api_gateway" {
  source           = "../../modules/api_gateway"
  api_name         = "${local.project}Gateway"
  api_description  = "Serverless backend for Ig post extractor"
  environment      = local.environment
  lambda_alias_arn = module.lambda.alias_arns["ig_post_extractor_dev"]
}
```

Our module design provides:
- Encapsulation of related resources (e.g., Lambda + permissions)
- Consistent patterns across environments
- Simplified environment configurations

### State Management: One Environment, One State

Each environment has its own dedicated state file:

```
terraform {
  backend "s3" {
    bucket  = "ig-post-extractor-terraform-state"
    key     = "dev/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}
```

This approach ensures:
- Complete isolation between environments
- Reduced risk when applying changes
- Appropriate access controls for different environments

### Dynamic Resource Creation with Maps and For-Each

We use Terraform's `for_each` with maps to dynamically create resources:

```
resource "aws_lambda_function" "functions" {
  for_each = var.functions
  
  function_name = each.value.function_name
  s3_bucket     = each.value.s3_bucket
  s3_key        = each.value.s3_key
  handler       = each.value.handler
  runtime       = each.value.runtime
  # Additional attributes...
}
```

This pattern provides:
- Concise, DRY infrastructure definitions
- Easily extensible resource configurations
- Improved maintainability for similar resources

### Outputs: The Glue Between Modules

Well-defined outputs connect our modules together:

```
# In module definition
output "alias_arns" {
  description = "Map of function alias ARNs"
  value = {
    for key, alias in aws_lambda_alias.function_aliases :
    key => alias.arn
  }
}

# In environment configuration
module "api_gateway" {
  # ...
  lambda_alias_arn = module.lambda.alias_arns["ig_post_extractor_dev"]
}
```

This approach:
- Creates clear interfaces between modules
- Documents dependencies explicitly
- Minimizes tight coupling between infrastructure components

### CI/CD Integration

Our infrastructure changes follow the same CI/CD process as our application code:

```yaml
terraform-plan:
  name: Terraform Plan
  runs-on: ubuntu-latest
  steps:
    # ...
    - name: Terraform Plan
      run: |
        terraform plan -input=false -out=tfplan \
          -var="artifact_bucket=${{ env.S3_BUCKET }}" \
          -var="artifact_prefix=${{ needs.build.outputs.s3-key }}" \
          -detailed-exitcode
```

This integration provides:
- Automated validation of infrastructure changes
- Preview of changes in pull requests
- Consistent deployment process across environments
- Approval gates for production changes

By following these practices, we maintain a scalable, maintainable, and secure infrastructure that can evolve alongside our application code.
