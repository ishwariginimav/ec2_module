data "aws_ami" "amzlinux" {
   most_recent = true
   owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amzlinux.id
  instance_type = "t3.micro"
  subnet_id = "subnet-0b7dc7f609b45ea12"
  key_name = "IshKeyPair"
  associate_public_ip_address = true
  security_groups = [aws_security_group.allow_tls.id]

  tags = {
    Name = "Jenkins_ec2"
    Componant = "Jenkins"
    Env = "dev"
  }
  provisioner "local-exec" {
    command =   <<-EOT
        sleep 60;
        ansible-playbook jenkins.yaml --ssh-common-args='-o StrictHostKeyChecking=no' --key-file IshKeyPair.pem -i ${self.public_ip}, -vv
        EOT
    working_dir = "${path.module}"
  }
}

data "aws_vpc" "selected"{
    filter{
        name = "tag:Name"
        values = ["dev"]
    }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}