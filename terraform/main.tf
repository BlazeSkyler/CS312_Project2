terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_key_pair" "pub_key" {
  key_name   = "pub_key"
  public_key = var.public_key
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "mc_sec_group" {
  name        = "mc-group"
  description = "Allow Minecraft connections"
  vpc_id      = aws_default_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.mc_sec_group.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.mc_sec_group.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# resource "aws_vpc_security_group_ingress_rule" "http" {
#   security_group_id = aws_security_group.mc_sec_group.id
#   from_port         = 80
#   to_port           = 80
#   ip_protocol       = "tcp"
#   cidr_ipv4         = "0.0.0.0/0"
# }

resource "aws_vpc_security_group_ingress_rule" "mc_port" {
  security_group_id = aws_security_group.mc_sec_group.id
  from_port         = 25565
  to_port           = 25565
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.mc_sec_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "mc_server" {
  ami                    = "ami-0a605bc2ef5707a18"
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.mc_sec_group.id]
  key_name               = aws_key_pair.pub_key.key_name

  tags = {
    Name = "Minecraft_Server_2"
  }

  provisioner "file" {
    connection {
      host = "${self.public_dns}"
      user = "ubuntu"
      type = "ssh"
      private_key = "${file("~/.ssh/id_rsa")}"
      timeout = "2m"
    }
    source = "../docker-mc/docker-compose.yml"
    destination = "/home/ubuntu/docker-compose.yml"
  }

  provisioner "remote-exec" {
    connection {
      host = "${self.public_dns}"
      user = "ubuntu"
      type = "ssh"
      private_key = "${file("~/.ssh/id_rsa")}"
      timeout = "2m"
    }
    inline = [
      "./${file("../docker-mc/docker_install.sh")}"
      ]
  }

  provisioner "remote-exec" {
    connection {
      host = "${self.public_dns}"
      user = "ubuntu"
      type = "ssh"
      private_key = "${file("~/.ssh/id_rsa")}"
      timeout = "2m"
    }
    inline = [
      "./${file("../docker-mc/start_server.sh")}"
      ]
  }
}