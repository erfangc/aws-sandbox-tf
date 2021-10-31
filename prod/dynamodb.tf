locals {
  vpc_config = {
    subnet_ids        = module.vpc.private_subnets
    security_group_id = aws_security_group.lambda-sg.id
  }
}

module "assets" {
  source = "../dynamo-search-stack"

  attributes = [
    {
      name = "assetId",
      type = "S"
    }
  ]

  hash_key = "assetId"
  name     = "assets"

  elasticsearch_domain = aws_elasticsearch_domain.esd
  vpc_config           = local.vpc_config
}

module "people" {
  source     = "../dynamo-search-stack"
  attributes = [
    {
      name : "name",
      type : "S"
    }
  ]
  hash_key   = "name"
  name       = "people"
  
  elasticsearch_domain = aws_elasticsearch_domain.esd
  vpc_config           = local.vpc_config
}

module "assets-dev-sync-stack" {
  source         = "../dynamo-sync-stack"
  table          = module.assets
  target_account = var.dev_account_id
}

module "people-dev-sync-stack" {
  source         = "../dynamo-sync-stack"
  table          = module.people
  target_account = var.dev_account_id
}