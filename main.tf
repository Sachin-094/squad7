provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "squad7-vpc"
  }
}

resource "aws_internet_gateway" "main_ig" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.3.0/24"
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.4.0/24"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table_association" "public_subnet1_association" {
  route_table_id     = aws_route_table.public_route_table.id
  subnet_id         = aws_subnet.public_subnet1.id
}

resource "aws_route_table_association" "public_subnet2_association" {
  route_table_id     = aws_route_table.public_route_table.id
  subnet_id         = aws_subnet.public_subnet2.id
}

resource "aws_route" "public_route" {
  route_table_id     = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id         = aws_internet_gateway.main_ig.id
}

resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
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

  tags = {
    Name = "Web-sg"
  }
}

# created IAM rols and attached a policy to it
resource "aws_iam_role" "example_role" {
  name = "examplerole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "example_attachment" {
  role       = aws_iam_role.example_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "example_profile" {
  name = "example_profile"
  role = aws_iam_role.example_role.name
}

# created s3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket  = "my-bucket-name-sachiny"
  tags    = {
	Name          = "MyS3Bucket"
	Environment    = "Test"
  }
}
