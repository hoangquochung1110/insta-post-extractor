terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.32"
    }
  }

  backend "s3" {
    bucket = "ig-post-extractor-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "ap-southeast-1"
    encrypt = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}


locals {
  project     = "IgPostExtractor"
  environment = "dev"
  function_folder = "functions"
  execution_role_name = "ig_post_extractor_exec_role"

  lambda_functions = {
    ig_post_extractor = {                # ← your chosen key
      function_name = "IgPostExtractor"
      handler       = "ig_post_extractor.lambda_handler"
      runtime       = "python3.12"
      memory_size   = 128
      timeout       = 30
      s3_bucket                      = var.artifact_bucket
      s3_key    = "${local.functions_folder}/${each.key}/${var.artifact_prefix}.zip"
      publish = false
      # Define aliases for this function
      aliases = {
        dev = {
          description = "dev alias"
          # Uses $LATEST by default
        },
      }
    }
  }

  # Standard tags for all resources
  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}



module "log_group" {
  source = "../../modules/cloudwatch"

  name              = var.api_gw_log_group
  retention_in_days = 7
}

module "api_gateway" {
  source          = "../../modules/api_gateway"
  api_name        = "${local.project}Gateway"
  api_description = "Serverless backend for Ig post extractor"
  api_key_name    = var.api_key_name
  environment     = local.environment
  lambda_alias_arn = module.lambda.alias_arns["ig_post_extractor_dev"]

}

module "iam" {
  source = "../../modules/iam"
  execution_role_name = local.execution_role_name
}

module "lambda"{
  source = "../../modules/lambda"
  functions   = local.lambda_functions
  execution_role_arn = module.iam.execution_role_arn
}
