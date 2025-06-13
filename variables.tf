# Переменная для AMI ID
variable "ami_id" {
  description = "Debian 12 (HVM)"
  type        = string
  # Используйте актуальный AMI ID для вашего региона (например, Amazon Linux 2 AMI)
  # Убедитесь, что AMI ID соответствует вашему региону AWS.
  # Вы можете найти актуальные AMI ID в консоли AWS EC2 или в AWS CLI.
  default = "ami-0548d28d4f7ec72c5"
}

# Переменная для типа экземпляра EC2
variable "instance_type" {
  description = "Тип экземпляра EC2"
  type        = string
  default     = "t3.micro" # Free Tier
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "state_bucket" {
  type    = string
  default = "mybucketterraformname"
}
