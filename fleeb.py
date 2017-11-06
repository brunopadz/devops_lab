# Define variables

aws_tf_fl = 'src/infra/aws.tf'
aws_tf_model = 'src/infra/aws_model.tf'
aws_region = ''

fleeb_region = 'variable "region" { default = "'
fleeb_vpc = 'resource "aws_vpc" "fleeb-lab" { cidr_block = "'
fleeb_sg = 'resource "aws_security_group" "fleeb_secgp" { name = "fleeb_secgp" description = "created with fleeb" vpc_id = "${aws_vpc.fleeb-lab.id}" ingress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["'
fleeb_sge = 'egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ['
fleeb_sg_end = '"] } '
fleeb_sge_end = '"] } }'
fleeb_end_line = '" }\n'

# Start app

print('########################################')
print('##                                    ##')
print('##              F L E E B             ##')
print('##                                    ##')
print('########################################')
print(' ')
print('Fleeb just works with AWS, other providers are coming soon! :)')
print('The default configuration is located at', aws_tf_fl)
act = input('What would you like to do?\nType print to print the config file or edit to start creating your infrastructure: \n')
if act == 'print':
    fhand = open(aws_tf_fl,'r')
    for lines in fhand:
        print(lines)
elif act == 'edit':
    fhand = open(aws_tf_model, 'r+')
    fl_aws_region = input('What region do you want to provision the infrastructure?\n')
    usr_region = fleeb_region + fl_aws_region + fleeb_end_line
    fhand = open(aws_tf_model, 'r+')
    fl_aws_vpc = input('Lets create the network. Input the CIDR for the VPC. Example: 10.20.0.0/8\n')
    usr_vpc = fleeb_vpc + fl_aws_vpc + fleeb_end_line
    print('Creating Internet Gateway for VPC with CIDR', fl_aws_vpc )
    fhand = open(aws_tf_model, 'r+')
    usr_igw = 'resource "aws_internet_gateway" "igw" { vpc_id = "${aws_vpc.fleeb-lab.id}" }\n'
    print('Creating route tables...')
    usr_rtb = 'resource "aws_route_table" "rt-lab" { vpc_id = "${aws_vpc.fleeb-lab.id}" route { cidr_block = "0.0.0.0/0" gateway_id = "${aws_internet_gateway.igw.id}" }\n'
    print('Creating public subnet...')
    usr_sub1 = 'resource "aws_subnet" "public1" { vpc_id = "${aws_vpc.fleeb-lab.id}" cidr_block = "10.0.1.0/24" map_public_ip_on_launch = true }\n'
    print('Creating private subnet...')
    usr_sub2 = 'resource "aws_subnet" "private1" { vpc_id = "${aws_vpc.fleeb-lab.id}" cidr_block = "10.0.2.0/24" }\n'
    usr_rtba = 'resource "aws_route_table_association" "public1_a" { subnet_id = "${aws_subnet.public1.id}" route_table_id = "${aws_route_table.rt-lab.id}" }\n'
    fl_aws_sg_i = input('Please specify the ingress network. Example 123.234.123.234/32.\n')
    usr_sg_i = fleeb_sg + fl_aws_sg_i + fleeb_sg_end
    fl_aws_sg_e = input('Please specify the egress network. Example 123.234.123.234/32.\n')
    usr_sg_e = fleeb_sge + fl_aws_sg_e + fleeb_sge_end
    fhand.write(usr_region)
    fhand.write(usr_vpc)
    fhand.write(usr_igw)
    fhand.write(usr_rtb)
    fhand.write(usr_sub1)
    fhand.write(usr_sub2)
    fhand.write(usr_rtba)
    fhand.write(usr_sg_i)
    fhand.write(usr_sg_e)
    fhand.write('\n')
else:
    print('ERROR!')
    quit()
