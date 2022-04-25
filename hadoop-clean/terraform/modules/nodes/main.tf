resource "aws_instance" "hadoop_name_node" {
  ami                    = var.ami
  instance_type          = "t3.medium"
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.hadoop_node_sg.id]
  subnet_id              = element(var.subnet_ids, 0)
  iam_instance_profile   = aws_iam_instance_profile.hadoop_node_instance_profile.name
  hibernation            = false

  credit_specification {
    cpu_credits = "unlimited"
  }

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  tags = {
    Name      = "${var.owner}-hadoop-name-node"
    Terraform = "true"
    Project   = var.project
    Owner     = var.owner
  }
}

resource "random_shuffle" "subnets" {
  input        = var.subnet_ids
  result_count = 1
}

resource "aws_instance" "hadoop_data_node" {
  count = var.data_nodes_count

  ami                    = var.ami
  instance_type          = "t3.medium"
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.hadoop_node_sg.id]
  subnet_id              = element(random_shuffle.subnets.result,0)
  iam_instance_profile   = aws_iam_instance_profile.hadoop_node_instance_profile.name
  hibernation            = false

  credit_specification {
    cpu_credits = "unlimited"
  }

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  tags = {
    Name      = "${var.owner}-hadoop-data-node-${count.index}"
    Terraform = "true"
    Project   = var.project
    Owner     = var.owner
  }
}


resource "aws_security_group" "hadoop_node_sg" {
  name   = "${var.owner}-hadoop-node-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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

  ingress {
    description = "WebUI for NameNode"
    from_port   = 9870
    to_port     = 9870
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WebUI for NameNode"
    from_port   = 9871
    to_port     = 9871
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Hadoop Data Node"
    from_port   = 9864
    to_port     = 9864
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Hadoop Data Node"
    from_port   = 9865
    to_port     = 9865
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Hadoop Data Node"
    from_port   = 9866
    to_port     = 9866
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Hadoop Data Node"
    from_port   = 9867
    to_port     = 9867
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Secondary NameNode"
    from_port   = 9868
    to_port     = 9868
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Secondary NameNode"
    from_port   = 9869
    to_port     = 9869
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "JournalNode"
    from_port   = 8485
    to_port     = 8485
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "JournalNode"
    from_port   = 8480
    to_port     = 8480
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "JournalNode"
    from_port   = 8481
    to_port     = 8481
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Aliasmap Server"
    from_port   = 50200
    to_port     = 50200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Hadoop"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Hadoop"
    from_port   = 54311
    to_port     = 54311
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name      = "${var.owner}-hadoop-node-sg"
    Terraform = "true"
    Project   = var.project
    Owner     = var.owner
  }
}

resource "aws_iam_policy" "hadoop_node_policy" {
  name        = "${var.owner}-hadoop-node-policy"
  description = "Policy for the hadoop nodes"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:PutParameter",
          "ssm:DeleteParameter",
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:DeleteParameters"
        ],
        "Resource" : "arn:aws:ssm:eu-central-1:043751989667:parameter/akarmyzov/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "ssm:DescribeParameters",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "hadoop_node_role" {
  name = "${var.owner}-hadoop-node-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name      = "${var.owner}-hadoop-node-role"
    Terraform = "true"
    Project   = var.project
    Owner     = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "hadoop_node_policy_attachment" {
  role       = aws_iam_role.hadoop_node_role.name
  policy_arn = aws_iam_policy.hadoop_node_policy.arn
}

resource "aws_iam_instance_profile" "hadoop_node_instance_profile" {
  name = "${var.owner}-hadoop-node-instance-profile"
  role = aws_iam_role.hadoop_node_role.name
}

resource "aws_route53_record" "hadoop_name_node" {
  zone_id = var.hosted_zone_id
  name    = "nn.hadoop.akarmyzov.tl.scntl.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.hadoop_name_node.public_ip]
}

resource "aws_route53_record" "hadoop_name_node_private" {
  zone_id = var.hosted_zone_id
  name    = "nnp.hadoop.akarmyzov.tl.scntl.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.hadoop_name_node.private_ip]
}

resource "aws_route53_record" "hadoop_data_node" {
  count = var.data_nodes_count

  zone_id = var.hosted_zone_id
  name    = "dn${count.index}.hadoop.akarmyzov.tl.scntl.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.hadoop_data_node.*.public_ip[count.index]]
}
