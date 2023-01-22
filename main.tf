locals {
  vpc_id           = "vpc-007afb7c04e0b015d"
  subnet_id        = "subnet-06e8b47bd6fec15e9"
  ssh_user         = "ec2-user"
  key_name         = "Vamsi_N.V"
  private_key_path = "./Vamsi_N.V.pem"
}

provider "aws" {
  region = "us-east-1"
  access_key = "AKIAWQQGMZNVYZSBP36W"
  secret_key = "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"
}

resource "aws_security_group" "tomcat" {
  name   = "tomcat_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                         = "ami-0b5eea76982371e91"
  subnet_id                   = local.subnet_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.tomcat.id]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.nginx.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} tomcat.yml"
  }
}

output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}
