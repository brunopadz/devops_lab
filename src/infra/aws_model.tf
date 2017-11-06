variable "region" { default = "sa-east-1" }
resource "aws_vpc" "fleeb-lab" { cidr_block = "10.0.0.0/16" }
resource "aws_internet_gateway" "igw" { vpc_id = "${aws_vpc.fleeb-lab.id}" }
resource "aws_route_table" "rt-lab" { vpc_id = "${aws_vpc.fleeb-lab.id}" route { cidr_block = "0.0.0.0/0" gateway_id = "${aws_internet_gateway.igw.id}" }
resource "aws_subnet" "public1" { vpc_id = "${aws_vpc.fleeb-lab.id}" cidr_block = "10.0.1.0/24" map_public_ip_on_launch = true }
resource "aws_subnet" "private1" { vpc_id = "${aws_vpc.fleeb-lab.id}" cidr_block = "10.0.2.0/24" }
resource "aws_route_table_association" "public1_a" { subnet_id = "${aws_subnet.public1.id}" route_table_id = "${aws_route_table.rt-lab.id}" }
resource "aws_security_group" "fleeb_secgp" { name = "fleeb_secgp" description = "created with fleeb" vpc_id = "${aws_vpc.fleeb-lab.id}" ingress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] } egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = [0.0.0.0/0"] } }
