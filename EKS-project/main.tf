# Create VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create subnets
resource "aws_subnet" "my_public_subnets" {
  count = var.networking.public_subnets == null || var.networking.public_subnets == "" ? 0 : length(var.networking.public_subnets)
  cidr_block = var.networking.public_subnets[count.index]
  vpc_id     = aws_vpc.eks_vpc.id
  availability_zone = var.networking.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet-${count.index}"
  }
}

resource "aws_subnet" "my_private_subnets" {
  count                   = var.networking.private_subnets == null || var.networking.private_subnets == "" ? 0 : length(var.networking.private_subnets)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.networking.private_subnets[count.index]
  availability_zone       = var.networking.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet-${count.index}"
  }
}

#Create internet gw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "EKS-IGW"
  }
}

resource "aws_eip" "elastic_ip" {
  count      = var.networking.private_subnets == null || var.networking.nat_gateways == false ? 0 : length(var.networking.private_subnets)
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "eip-${count.index}"
  }
}

resource "aws_nat_gateway" "nats" {
  count             = var.networking.private_subnets == null || var.networking.nat_gateways == false ? 0 : length(var.networking.private_subnets)
  subnet_id         = aws_subnet.my_public_subnets[count.index].id
  connectivity_type = "public"
  allocation_id     = aws_eip.elastic_ip[count.index].id
  depends_on        = [aws_internet_gateway.igw]
}

# PUBLIC ROUTE TABLES
resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route" "public_routes" {
  route_table_id         = aws_route_table.public_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_table_association" {
  count          = length(var.networking.public_subnets)
  subnet_id      = aws_subnet.my_public_subnets[count.index].id
  route_table_id = aws_route_table.public_table.id
}

# PRIVATE ROUTE TABLES
resource "aws_route_table" "private_tables" {
  count  = length(var.networking.azs)
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route" "private_routes" {
  count                  = length(var.networking.private_subnets)
  route_table_id         = aws_route_table.private_tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nats[count.index].id
}

resource "aws_route_table_association" "private_table_association" {
  count          = length(var.networking.private_subnets)
  subnet_id      = aws_subnet.my_private_subnets[count.index].id
  route_table_id = aws_route_table.private_tables[count.index].id
}

#Security group for cluster
resource "aws_security_group" "aws_security_group" {
  name = "SecurityGroup-EKS"
  description = "sg used for EKS and its nodes"
  vpc_id = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"]
    description = "Open To World on TcP" # Replace with specific IP ranges if needed
  }

    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    tags = {
    Name = "allow_tls"
  }
}

# Create EKS cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = flatten([aws_subnet.my_public_subnets.*.id, aws_subnet.my_private_subnets.*.id])
    security_group_ids  = [aws_security_group.aws_security_group.id]
  }

  #depends_on = [aws_subnet.eks_subnet_1, aws_subnet.eks_subnet_2]
}

# Create IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_policy_attachment" "eks_cluster_policy_attachment_2" {
  name       = "eks-cluster-policy-attachment-2"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  roles      = [aws_iam_role.eks_cluster.name]
}

# Create EC2 node group
resource "aws_eks_node_group" "ec2_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "ec2-workers"
  node_role_arn   = aws_iam_role.eks-node-group.arn
  subnet_ids = aws_subnet.my_private_subnets.*.id

  instance_types = ["t2.micro"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  #remote_access {
  #  ec2_ssh_key = "your-ssh-key-name"  # Replace with your SSH key name
  #}

  #additional_security_group_ids = ["sg-xxxxxxxxxxxxxxxxx"]  # Add any additional security group IDs if needed

    depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "eks-node-group" {
  name = "eks-node-group-example"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-group.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-group.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-group.name
}