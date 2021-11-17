# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = var.aws_vpc_cidr
  tags = {
    Name = var.aws_vpc_name
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

# Set Default route on dmz network to the Standalone gateway
resource "aws_route_table" "dmzrt" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_network_interface.mgmt_nic2.id
    }
  }
# Assign DMZ route table to DMZ subnet
resource "aws_route_table_association" "dmz1association" {
    subnet_id      = aws_subnet.dmz1.id
    route_table_id = aws_route_table.dmzrt.id
  }

# Define an external subnet for the security layer facing internet in the primary availability zone
resource "aws_subnet" "external1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.aws_external1_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.primary_az
  tags = {
    Name = "Terraform_external1"
  }
}

# Define an internal subnet for the security layer facing internal networks in the primary availability zone
resource "aws_subnet" "internal1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.aws_internal1_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.primary_az
  tags = {
    Name = "Terraform_internal1"
  }
}

# Define a dmz subnet for the security layer facing dmz network in the primary availability zone
resource "aws_subnet" "dmz1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.aws_dmz1_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.primary_az
  tags = {
    Name = "Terraform_dmz1"
  }
}

# Our default security group to access
resource "aws_security_group" "permissive" {
  name        = "terraform_permissive_sg"
  vpc_id      = aws_vpc.default.id

  # access from the internet
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
} 

# Our SSH security group to access
resource "aws_security_group" "ssh_access" {
  name        = "terraform_ssh_sg"
  vpc_id      = aws_vpc.default.id

  # access from the internet
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
} 

# Our default RDP security group to access
resource "aws_security_group" "rdp" {
  name        = "terraform_rdp_sg"
  vpc_id      = aws_vpc.default.id

  # access from the internet
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
} 
