# AWS provider configuration
provider "aws" {
  region = var.aws_region
}

module "transaction_service" {
  source = "./transaction_service"
}

module "notification_service" {
  source = "./notification_service"
}

module "user_service" {
  source = "./user_service"
}