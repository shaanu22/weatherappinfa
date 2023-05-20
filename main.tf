provider "aws" {
  region = var.region
}

resource "aws_vpc" "devpro" {
  cidr_block = var.vpc-cidr
}

resource "aws_subnet" "devpro_subnet" {
  cidr_block = var.subnet-cidr
  vpc_id     = aws_vpc.devpro.id
}

resource "aws_security_group" "ubuntu_sg" {
  name_prefix = "ubuntu-"
  vpc_id      = aws_vpc.devpro.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.my_ip_cidr
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.my_ip_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "redhat_sg" {
  name_prefix = "redhat-"
  vpc_id      = aws_vpc.devpro.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.my_ip_cidr
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = var.my_ip_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ubuntu" {
  ami                         = var.ubuntu_ami
  instance_type               = var.instance-type
  key_name                    = var.instance-keyname
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.devpro_subnet.id
  security_groups             = [aws_security_group.ubuntu_sg.id]

  tags = {
    Name = "Ubuntu Instance"
  }
}

resource "aws_instance" "redhat" {
  ami                         = var.redhat_ami
  instance_type               = var.instance-type
  associate_public_ip_address = true
  key_name                    = var.instance-keyname
  subnet_id                   = aws_subnet.devpro_subnet.id
  security_groups             = [aws_security_group.redhat_sg.id]

  tags = {
    Name = "RedHat Instance"
  }
}

output "ubuntu_public_ip" {
  value = aws_instance.ubuntu.public_ip
}

output "redhat_public_ip" {
  value = aws_instance.redhat.public_ip
}

resource "aws_internet_gateway" "devpro" {
  vpc_id = aws_vpc.devpro.id

  tags = {
    Name = "devpro"
  }
}

resource "aws_route_table" "devpro" {
  vpc_id = aws_vpc.devpro.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devpro.id
  }
}

resource "aws_route_table_association" "devpro-rta" {
  subnet_id      = aws_subnet.devpro_subnet.id
  route_table_id = aws_route_table.devpro.id
}
