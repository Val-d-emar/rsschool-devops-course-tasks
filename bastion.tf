// bastion.tf
resource "aws_instance" "bastion" {
  ami                         = "ami-0914547665e6a707c" # Example AMI ID for eu-north-1
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  tags = {
    Name = "task2-bastion"
  }
}
