resource "aws_instance" "server" {
  ami                         = "ami-02e136e904f3da870"
  instance_type               = "t2.medium"
  key_name                    = "master-key"
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.instance-sg.id]
}
