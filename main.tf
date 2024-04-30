terraform {
  backend "s3" {
    bucket = "qnt-clouds-for-pe-tfstate"
    key    = "alikhan-aitbayev/terraform.tfstate"
    region = "us-east-2"
  }
}

resource "aws_security_group" "my_security_group" {
  name        = "alikhan-aitbayev-sg"
  description = "Allow SSH and app traffic"

  vpc_id = "vpc-024cf058980b63412"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["52.149.163.72/32"]
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

}


resource "aws_s3_bucket" "qnt_bucket" {
  bucket = "qnt-bucket-tf-alikhan-aitbayev"
}

resource "aws_iam_policy" "s3_full_access_policy" {
  name        = "s3-terraform-alikhan-aitbayev"
  description = "Provides full access to S3 bucket"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : [
          "arn:aws:s3:::qnt-bucket-tf-alikhan-aitbayev/*",
          "arn:aws:s3:::qnt-bucket-tf-alikhan-aitbayev"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ec2_s3_full_access_role" {
  name = "ec2_s3_full_access_role_alikhan_aitbayev"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_full_access_attachment" {
  role       = aws_iam_role.ec2_s3_full_access_role.name
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile-alikhan-aitbayev"
  role = aws_iam_role.ec2_s3_full_access_role.name
}

resource "aws_instance" "ec2-alikhan-aitbayev" {
  ami                         = "ami-09040d770ffe2224f"
  instance_type               = "t3a.small"
  subnet_id                   = "subnet-07549c87757e073ea" # or "subnet-058c0197a05db2379"
  associate_public_ip_address = true

  security_groups = [aws_security_group.my_security_group.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              # Install packages
              EOF

  tags = {
    Name    = "ec2-alikhan-aitbayev-terraform"
    env     = "dev"
    owner   = "alikhan.aitbayev@quantori.com"
    project = "INFRA"
  }
}


resource "aws_ec2_instance_state" "ec2-alikhan-aitbayev" {
  instance_id = aws_instance.ec2-alikhan-aitbayev.id
  state       = "stopped"
}

