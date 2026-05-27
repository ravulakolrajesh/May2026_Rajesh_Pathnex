# aws sts get-caller-identity returns the identity details (UserId, Account, and ARN) of the IAM user or role executing the command.
# ssh-keygen -t rsa -b 4096 -f ~/.ssh/terraform-aws-key -N ""
  ls -la ~/.ssh/terraform-aws-key*
  chmod 600 ~/.ssh/terraform-aws-key

# VPC block
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Create Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Environment = var.environment
    Type        = "Public"
  }
}

# Create Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "${var.project_name}-private-subnet"
    Environment = var.environment
    Type        = "Private"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# Create Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

  enable_dns_hostnames = true: Required for instances to get public DNS names
  map_public_ip_on_launch = true: Automatically assigns public IPs

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create Security Group
resource "aws_security_group" "web_server" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web server allowing SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  # SSH access
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-web-sg"
    Environment = var.environment
  }
}

# Data source to get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)

  tags = {
    Name        = "${var.project_name}-key"
    Environment = var.environment
  }
}

# Create EC2 Instance
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_server.id]
  key_name               = aws_key_pair.deployer.key_name

  # User data script to install Nginx
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              
              # Create custom welcome page
              echo "<h1>Welcome to ${var.project_name}</h1>" > /var/www/html/index.html
              echo "<p>Deployed with Terraform on AWS</p>" >> /var/www/html/index.html
              echo "<p>Instance ID: $(ec2-metadata --instance-id | cut -d ' ' -f 2)</p>" >> /var/www/html/index.html
              echo "<p>Availability Zone: $(ec2-metadata --availability-zone | cut -d ' ' -f 2)</p>" >> /var/www/html/index.html
              EOF

  tags = {
    Name        = "${var.project_name}-web-server"
    Environment = var.environment
  }
}

# S3 block
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key           = "terraform.tfstate"
    region        = "ap-south-1"
    dynamodb_table = "terraform-lock"
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
}

# example IAM policy
resource "aws_iam_policy" "example_policy" {
  name        = "example_policy"
  description = "IAM policy for EC2 access and S3 logging"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["ec2:Describe*", "s3:PutObject"],
      Effect   = "Allow",
      Resource = "*"
    }]
  })
}

# ASG to adjust compute resources based on demand
resource "aws_autoscaling_group" "web_asg" {
  min_size = 1
  max_size = 5
  launch_configuration = aws_launch_configuration.web.id
}
