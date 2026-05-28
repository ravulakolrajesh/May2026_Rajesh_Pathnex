# Using Variable "create_network" to check if Resources Exists or tell to Create Resources
# ==========================================
# 1. CONTROLLER VARIABLES
# ==========================================
variable "create_network" {
  type        = bool
  default     = false  # Set to true to CREATE new resources, false to LOOK UP existing ones
  description = "Toggle whether to create a new network or discover an existing one"
}

variable "vpc_name_tag" {
  type        = string
  default     = "Production-VPC"
}

variable "subnet_name_tag" {
  type        = string
  default     = "Production-Public-Subnet-A"
}

# ==========================================
# 2. DATA SOURCES (Only run if create_network is FALSE)
# ==========================================
data "aws_vpc" "existing" {
  count = var.create_network ? 0 : 1 # If creating, do not query
  filter {
    name   = "tag:Name"
    values = [var.vpc_name_tag]
  }
}

data "aws_subnet" "existing" {
  count  = var.create_network ? 0 : 1
  vpc_id = data.aws_vpc.existing[0].id
  filter {
    name   = "tag:Name"
    values = [var.subnet_name_tag]
  }
}

# ==========================================
# 3. RESOURCES (Only run if create_network is TRUE)
# ==========================================
resource "aws_vpc" "new" {
  count      = var.create_network ? 1 : 0
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.vpc_name_tag
  }
}

resource "aws_subnet" "new" {
  count             = var.create_network ? 1 : 0
  vpc_id            = aws_vpc.new[0].id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = var.subnet_name_tag
  }
}

resource "aws_security_group" "docker_sg" {
  name        = "dockerhost-sg"
  # DYNAMIC VPC SELECTION: Pick the new VPC ID if created, otherwise pick the existing data source ID
  vpc_id      = var.create_network ? aws_vpc.new[0].id : data.aws_vpc.existing[0].id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================================
# 4. FINAL COMPUTE DEPLOYMENT
# ==========================================
resource "aws_instance" "m7iflexlarge" {
  ami           = "ami-07a00cf47dbbc844c"
  instance_type = "m7i-flex.large"
  key_name      = "ec2_pem"

  # DYNAMIC SUBNET SELECTION: Coalesces target IDs natively
  subnet_id              = var.create_network ? aws_subnet.new[0].id : data.aws_subnet.existing[0].id
  vpc_security_group_ids = [aws_security_group.docker_sg.id]

  tags = {
    Name = "dockerhost"
  }
}
