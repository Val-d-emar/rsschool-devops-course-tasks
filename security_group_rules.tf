# security_group_rules.tf

# SSH-доступ от bastion_sg к private_sg
resource "aws_security_group_rule" "ssh_bastion_to_private" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
}


# resource "aws_security_group_rule" "icmp_bastion_to_private" {
#   count                    = length(aws_subnet.private)
#   type                     = "ingress"
#   from_port                = -1
#   to_port                  = -1
#   protocol                 = "icmp"
#   security_group_id        = aws_security_group.private_sg.id
#   cidr_blocks              = [aws_subnet.public[0].cidr_block]
# }

# resource "aws_security_group_rule" "icmp_bastion_to_private" {
#   for_each          = toset(var.private_subnets)
#   type              = "ingress"
#   from_port         = -1
#   to_port           = -1
#   protocol          = "icmp"
#   security_group_id = aws_security_group.private_sg.id
#   cidr_blocks       = [each.key]
# }

# ICMP правило (ping) от Bastion SG подсети
resource "aws_security_group_rule" "icmp_bastion_to_private" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = aws_security_group.private_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
}


resource "aws_security_group_rule" "icmp_private_outbound" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  security_group_id = aws_security_group.private_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# resource "aws_security_group_rule" "icmp_private_outbound" {
#   for_each          = toset(var.private_subnets)
#   type              = "egress"
#   from_port         = -1
#   to_port           = -1
#   protocol          = "icmp"
#   security_group_id = aws_security_group.private_sg.id
#   cidr_blocks       = [each.key]
# }
