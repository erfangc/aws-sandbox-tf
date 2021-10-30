/*
 Lambda Security Group(s)
 */
resource "aws_security_group" "lambda-sg" {
  name        = "lambda"
  description = "Security group for VPC connected Lambdas"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "lambda-allow-egress-all" {
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda-sg.id
  cidr_blocks       = [
    module.vpc.vpc_cidr_block
  ]
  type              = "egress"
}

resource "aws_security_group_rule" "lambda-allow-ingress-all" {
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda-sg.id
  cidr_blocks       = [
    module.vpc.vpc_cidr_block
  ]
  type              = "ingress"
}

/*
 Elasticsearch Domain Security Group(s)
 */
resource "aws_security_group" "elasticsearch-domain-sg" {
  name        = "elasticsearch"
  description = "Elasticsearch domain security group"
  vpc_id      = module.vpc.vpc_id
}

// allow all HTTPs traffic to come into this ES domain from within the VPC
resource "aws_security_group_rule" "elasticsearch-allow-https" {
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.elasticsearch-domain-sg.id
  cidr_blocks       = [
    module.vpc.vpc_cidr_block
  ]
  type              = "ingress"
}