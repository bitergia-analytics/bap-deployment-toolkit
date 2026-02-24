resource "aws_vpc" "bap" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = false
  enable_dns_support   = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.bap.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-public-subnet"
  }
}

resource "aws_internet_gateway" "bap" {
  vpc_id = aws_vpc.bap.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.bap.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bap.id
  }

  tags = {
    Name = "${var.prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group for SSH access
resource "aws_security_group" "ssh" {
  name        = "${var.prefix}-allow-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.bap.id

  ingress {
    description = "SSH from specific ranges"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_source_ranges
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-allow-ssh"
  }
}

# Security Group for Public Web access (HTTP/HTTPS)
resource "aws_security_group" "web" {
  name        = "${var.prefix}-allow-web"
  description = "Allow HTTP and HTTPS inbound traffic"
  vpc_id      = aws_vpc.bap.id

  ingress {
    description = "Allow Ping (ICMP)"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.web_source_ranges
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.web_source_ranges
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-allow-web"
  }
}

# Security Group for Internal Communication
resource "aws_security_group" "internal" {
  name        = "${var.prefix}-allow-internal"
  description = "Allow internal traffic between BAP instances"
  vpc_id      = aws_vpc.bap.id

  ingress {
    description = "Allow all internal traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-allow-internal"
  }
}
