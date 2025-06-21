// route_tables.tf
# Таблица маршрутов для публичных подсетей (через IGW)
locals {
  nat_eni = aws_instance.nat.primary_network_interface_id
}

# Публичная маршрутная таблица
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "task2-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Приватная маршрутная таблица
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "task2-private-rt" }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Маршрут через NAT-инстанс (ENI)
# resource "aws_route" "private_nat" {
#   count                  = length(aws_subnet.private)
#   route_table_id         = aws_route_table.private.id
#   destination_cidr_block = "0.0.0.0/0"
#   network_interface_id   = local.nat_eni
# }

resource "aws_route" "private_default_via_nat" { // Более понятное имя
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = local.nat_eni // или aws_instance.nat.primary_network_interface_id
}