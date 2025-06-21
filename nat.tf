# nat.tf

# Получаем последний AMI для Amazon Linux 2
data "aws_ami" "nat" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

# Security Group для NAT-инстанса
resource "aws_security_group" "nat_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = var.private_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "task2-nat-sg"
  }
}

# NAT-инстанс для выхода из приватных сетей
resource "aws_instance" "nat" {
  ami                         = data.aws_ami.nat.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.nat_sg.id]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = var.key_pair_name
  # user_data = <<-EOF
  #             #!/bin/bash
  #             echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
  #             sysctl -p /etc/sysctl.conf
  #             yum install -y iptables-services
  #             systemctl enable iptables
  #             systemctl start iptables
  #             iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  #             iptables-save > /etc/sysconfig/iptables
  #             # Для Amazon Linux 2023 используйте nftables или firewalld
  #             #yum update -y
  #             #yum install -y iptables iproute
  #             #echo "net.ipv4.ip_forward = 1" | tee -a /etc/sysctl.conf
  #             #sysctl -p
  #             #iptables -t nat -A POSTROUTING -o ens5 -s 0.0.0.0/0 -j MASQUERADE
  #             EOF
  # Примечание: для Amazon Linux 2023 синтаксис настройки NAT может отличаться (nftables/firewalld)
  user_data = <<-EOF
    #!/bin/bash
    # Включаем пересылку пакетов
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/90-nat.conf
    sysctl --system

    # Устанавливаем iptables-services
    yum install -y iptables-services

    # Ждём появления второго интерфейса (eth1)
    for i in {1..10}; do
      ETH1=\$(ip -4 addr show device-number-1 | grep -oP 'ens[0-9]+' | head -n1)
      [ -n "\$ETH1" ] && break
      sleep 3
    done

    # Определяем публичный интерфейс
    ETH0=\$(ip -4 addr show device-number-0 | grep -oP 'ens[0-9]+' | head -n1)

    # Настраиваем NAT в iptables
    iptables -t nat -A POSTROUTING -o \$ETH0 -j MASQUERADE
    iptables -A FORWARD -i \$ETH0 -o \$ETH1 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i \$ETH1 -o \$ETH0 -j ACCEPT

    # Сохраняем и запускаем iptables при загрузке
    systemctl enable iptables
    service iptables save
  EOF
  tags = {
    Name = "task2-nat"
  }
}