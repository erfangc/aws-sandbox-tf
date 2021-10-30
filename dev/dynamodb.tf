module "assets" {
  source               = "./dynamo-search-stack"
  elasticsearch_domain = aws_elasticsearch_domain.esd.domain_name
  security_group_id    = aws_security_group.lambda-sg.id
  attributes           = [
    {
      name = "assetId",
      type = "S"
    }
  ]
  hash_key             = "assetId"
  name                 = "assets"
  subnet_ids           = module.vpc.private_subnets
}