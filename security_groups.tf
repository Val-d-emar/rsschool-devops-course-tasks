// security_groups.tf
# resource "aws_security_group" "bastion" {
#   name        = "bastion-sg"
#   description = "Allow SSH access"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "task2-bastion-sg"
#   }
# }

# security_groups.tf

# SG для Bastion — разрешает SSH с внешнего мира
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # можно ограничить своим IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# SG для приватных инстансов — разрешает SSH только от Bastion SG
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.main.id

  # ingress {
  #   from_port = 22
  #   to_port   = 22
  #   protocol  = "tcp"
  #   # cidr_blocks = ["0.0.0.0/0"]
  #   security_groups = [aws_security_group.bastion_sg.id] # Разрешаем SSH только от Bastion SG
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}
