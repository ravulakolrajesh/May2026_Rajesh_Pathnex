provider "aws" {
  region = "ap-south-1"
}

data "aws_ssm_parameter" "ubuntu_lts" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/gen_ec2_key.pub") # Path to your local public key file
}

# ---------------- creating VPC ----------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# ---------------- creating Internet Gateway ----------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# ---------------- creating a Subnet ----------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block             = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone      = "ap-south-1a"
}

# ---------------- creating a Route Table ----------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------------- Security Group ----------------
resource "aws_security_group" "ssh" {
  name = "allow-ssh"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
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

# ---------------- EC2 ----------------
resource "aws_instance" "ubuntu" {
  ami                         = data.aws_ssm_parameter.ubuntu_lts.value
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids     = [aws_security_group.ssh.id]

  associate_public_ip_address = true
}

output "public_ip" {
  value = aws_instance.ubuntu.public_ip
