# -------------------------------
# VARIABLES SECTION
# -------------------------------
variable "aws_region" {
  default = "us-west-1"
}

variable "bucket_name_prefix" {
  default = "harshbucket"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "availability_zone" {
  default = "us-west-1a"
}

# -------------------------------
# MAIN RESOURCES
# -------------------------------
provider "aws" {
  region = var.aws_region
}

resource "random_id" "rand" {
  byte_length = 4
}

resource "aws_s3_bucket" "harsh_bucket" {
  bucket = "${var.bucket_name_prefix}-${random_id.rand.hex}"
  tags = {
    Name        = "HarshBucket"
    Environment = "Dev"
  }
}

resource "aws_vpc" "harsh_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "HarshVPC"
  }
}

resource "aws_subnet" "harsh_subnet" {
  vpc_id                  = aws_vpc.harsh_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "HarshSubnet"
  }
}

resource "aws_internet_gateway" "harsh_igw" {
  vpc_id = aws_vpc.harsh_vpc.id
  tags = {
    Name = "HarshIGW"
  }
}

resource "aws_route_table" "harsh_rt" {
  vpc_id = aws_vpc.harsh_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.harsh_igw.id
  }

  tags = {
    Name = "HarshRouteTable"
  }
}

resource "aws_route_table_association" "harsh_rta" {
  subnet_id      = aws_subnet.harsh_subnet.id
  route_table_id = aws_route_table.harsh_rt.id
}

resource "aws_security_group" "harsh_sg" {
  name        = "harsh-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.harsh_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "HarshSecurityGroup"
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.harsh_bucket.bucket
}
