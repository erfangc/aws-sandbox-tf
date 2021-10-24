
resource "aws_security_group" "instance-sg" {
  name   = "instance-sg"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "allow-ssh" {
  from_port         = 22
  protocol          = "tcp"
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "ingress"
  security_group_id = aws_security_group.instance-sg.id
}

resource "aws_security_group_rule" "allow-http" {
  from_port         = 80
  protocol          = "tcp"
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "ingress"
  security_group_id = aws_security_group.instance-sg.id
}

resource "aws_security_group_rule" "allow-http-3000" {
  from_port         = 3000
  protocol          = "tcp"
  to_port           = 3000
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "ingress"
  security_group_id = aws_security_group.instance-sg.id
}

resource "aws_security_group_rule" "allow-ingress-http" {
  from_port         = 80
  protocol          = "tcp"
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "egress"
  security_group_id = aws_security_group.instance-sg.id
}

resource "aws_security_group_rule" "allow-ingress-https" {
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "egress"
  security_group_id = aws_security_group.instance-sg.id
}