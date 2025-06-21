# nacl.tf

# locals {
#   public_count  = length(aws_subnet.public)
#   private_count = length(aws_subnet.private)
# }

# # NACL для публичных подсетей (открыт полностью)
# resource "aws_network_acl" "public" {
#   count      = local.public_count
#   vpc_id     = aws_vpc.main.id
#   subnet_ids = [aws_subnet.public[count.index].id]
#   tags       = { Name = "task2-public-nacl-${count.index}" }
# }

# resource "aws_network_acl_rule" "public_inbound" {
#   count          = local.public_count
#   network_acl_id = aws_network_acl.public[count.index].id
#   rule_number    = 100
#   egress         = false
#   protocol       = "-1"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 0
#   to_port        = 0
# }

# resource "aws_network_acl_rule" "public_outbound" {
#   count          = local.public_count
#   network_acl_id = aws_network_acl.public[count.index].id
#   rule_number    = 100
#   egress         = true
#   protocol       = "-1"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 0
#   to_port        = 0
# }

# # NACL для приватных подсетей (разрешаем трафик к NAT и в локальную сеть)
# resource "aws_network_acl" "private" {
#   count      = local.private_count
#   vpc_id     = aws_vpc.main.id
#   subnet_ids = [aws_subnet.private[count.index].id]
#   tags       = { Name = "task2-private-nacl-${count.index}" }
# }

# # Разрешаем исходящий трафик от приватных подсетей
# resource "aws_network_acl_rule" "private_outbound" {
#   count          = local.private_count
#   network_acl_id = aws_network_acl.private[count.index].id
#   rule_number    = 100
#   egress         = true
#   protocol       = "-1"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 0
#   to_port        = 0
# }

# # Разрешаем входящий трафик от NAT-инстанса (ENI-level)
# resource "aws_network_acl_rule" "private_inbound" {
#   count          = local.private_count
#   network_acl_id = aws_network_acl.private[count.index].id
#   rule_number    = 100
#   egress         = false
#   protocol       = "-1"
#   rule_action    = "allow"
#   cidr_block     = aws_subnet.public[count.index % local.public_count].cidr_block
#   # cidr_block = aws_subnet.public[count.index].cidr_block
#   from_port  = 0
#   to_port    = 0
# }


# // Разрешить ответы из интернета на эфемерные порты
# resource "aws_network_acl_rule" "private_inbound_ephemeral_replies" {
#   count          = local.private_count
#   network_acl_id = aws_network_acl.private[count.index].id
#   rule_number    = 100 // Номер правила должен быть уникальным для направления
#   egress         = false
#   protocol       = "tcp" // Или "-1" если нужен UDP и т.д.
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 1024
#   to_port        = 65535
# }
# // Разрешить трафик из VPC (например, от бастиона)
# resource "aws_network_acl_rule" "private_inbound_from_vpc" {
#   count          = local.private_count
#   network_acl_id = aws_network_acl.private[count.index].id
#   rule_number    = 110
#   egress         = false
#   protocol       = "-1"
#   rule_action    = "allow"
#   cidr_block     = var.vpc_cidr // CIDR всего VPC
#   from_port      = 0
#   to_port        = 0
# }

# nacl.tf

locals {
  public_count  = length(aws_subnet.public)  # Предположим, это равно количеству публичных подсетей из variables.tf (например, 2)
  private_count = length(aws_subnet.private) # Предположим, это равно количеству приватных подсетей из variables.tf (например, 2)
}

# NACL для публичных подсетей (открыт полностью)
resource "aws_network_acl" "public" {
  count      = local.public_count
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public[count.index].id]
  tags       = { Name = "task2-public-nacl-${count.index}" }
}

resource "aws_network_acl_rule" "public_inbound" {
  count          = local.public_count
  network_acl_id = aws_network_acl.public[count.index].id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "public_outbound" {
  count          = local.public_count
  network_acl_id = aws_network_acl.public[count.index].id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# NACL для приватных подсетей
resource "aws_network_acl" "private" {
  count      = local.private_count
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.private[count.index].id]
  tags       = { Name = "task2-private-nacl-${count.index}" }
}

# --- ПРАВИЛА ДЛЯ ПРИВАТНЫХ NACL ---

# ИСХОДЯЩИЕ (Egress = true)
resource "aws_network_acl_rule" "private_outbound" {
  count          = local.private_count
  network_acl_id = aws_network_acl.private[count.index].id
  rule_number    = 100 # Номер 100 для исходящих - нормально, т.к. направление другое
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0" # Разрешить весь исходящий трафик (к NAT и т.д.)
  from_port      = 0
  to_port        = 0
}

# ВХОДЯЩИЕ (Egress = false)

# Правило 100: Разрешить весь трафик от публичной подсети, где может быть NAT-инстанс
resource "aws_network_acl_rule" "private_inbound_from_nat_subnet" { # Изменено имя для ясности
  count          = local.private_count
  network_acl_id = aws_network_acl.private[count.index].id
  rule_number    = 100 # Первое уникальное правило для входящего трафика
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  # Разрешает трафик от публичной подсети, которая находится в той же "группе" AZ,
  # или от первой публичной подсети, если public_count=1
  cidr_block = aws_subnet.public[count.index % local.public_count].cidr_block
  from_port  = 0
  to_port    = 0
}

# Правило 105: Разрешить ответы из интернета на эфемерные порты (для NAT)
resource "aws_network_acl_rule" "private_inbound_ephemeral_replies" {
  count          = local.private_count
  network_acl_id = aws_network_acl.private[count.index].id
  rule_number    = 105 # Уникальный номер для входящего правила
  egress         = false
  protocol       = "tcp" # Обычно TCP достаточно для ответов веб-запросов
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0" # Ответы приходят с реальных IP серверов
  from_port      = 1024
  to_port        = 65535
}

# Правило 110: Разрешить весь трафик изнутри VPC
resource "aws_network_acl_rule" "private_inbound_from_vpc" {
  count          = local.private_count
  network_acl_id = aws_network_acl.private[count.index].id
  rule_number    = 110 # Уникальный номер для входящего правила
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr # CIDR всего VPC
  from_port      = 0
  to_port        = 0
}
