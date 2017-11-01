#
# Variables
#

variable "region" { default = "us-east-1" }

#
# AWS Provider
#

provider "aws" {
    region = "${var.region}"
    shared_credentials_file = "~/.aws/credentials"
}

#
# Networking
#

resource "aws_vpc" "devops-lab" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "devops-lab-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.devops-lab.id}"

  tags {
    Name = "devops-lab-igw"
  }
}

resource "aws_route_table" "rt-lab" {
  vpc_id = "${aws_vpc.devops-lab.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "devops-lab-rt-out"
  }
}

resource "aws_subnet" "public1" {
  vpc_id = "${aws_vpc.devops-lab.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private1" {
  vpc_id = "${aws_vpc.devops-lab.id}"
  cidr_block = "10.0.2.0/24"
}

resource "aws_route_table_association" "public1_a" {
  subnet_id      = "${aws_subnet.public1.id}"
  route_table_id = "${aws_route_table.rt-lab.id}"
}

resource "aws_security_group" "allow_from_home" {
  name = "allow_from_home"
  description = "allow connections from home"
  vpc_id = "${aws_vpc.devops-lab.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["179.111.8.17/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_from_home"
  }
}

#
# Compute resources
#

# Jenkins

resource "aws_instance" "jenkins" {
    ami = "ami-258a265f"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.public1.id}"
    key_name = "devops-lab"
    vpc_security_group_ids = ["${aws_security_group.allow_from_home.id}"]

    tags {
      Name = "jenkins-lab"
    }
}

resource "aws_eip" "jenkins-eip" {
    instance = "${aws_instance.jenkins.id}"
    vpc = true
}

# Ansible

resource "aws_instance" "ansible" {
    ami = "ami-258a265f"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.public1.id}"
    key_name = "devops-lab"
    vpc_security_group_ids = ["${aws_security_group.allow_from_home.id}"]

    tags {
      Name = "ansible-lab"
    }
}

#
# Route 53
#

data "aws_route53_zone" "brunopadz" {
  name         = "brunopadz.com."
  private_zone = false
}

resource "aws_route53_record" "jenkins" {
  zone_id = "${data.aws_route53_zone.brunopadz.zone_id}"
  name    = "jenkins.${data.aws_route53_zone.brunopadz.name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.jenkins.public_ip}"]
}
