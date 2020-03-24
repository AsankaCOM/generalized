locals {
    default_tags = {
        Environment = terraform.workspace
        Name        = "${var.identifier}-${terraform.workspace}"
        }

    tags         = merge(local.default_tags, var.tags)
}

resource "aws_iam_role" "ec2_s3_ssm_access_role" {
  name               = "${var.identifier}-${terraform.workspace}-s3-ssm-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags               = local.tags
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.identifier}-${terraform.workspace}-s3-ssm-role"
  role = aws_iam_role.ec2_s3_ssm_access_role.name
}

resource "aws_iam_role_policy_attachment" "instance_role_1" {
  
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.ec2_s3_ssm_access_role.name
}

resource "aws_iam_role_policy_attachment" "instance_role_2" {
  
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.ec2_s3_ssm_access_role.name
}

resource "aws_iam_role_policy" "ssm-policy" {
  name = "${var.identifier}-${terraform.workspace}-ssm-policy"
  role = aws_iam_role.ec2_s3_ssm_access_role.name
  policy = <<-EOF
  {
      "Statement": [{
          "Effect": "Allow",
          "Action": [
              "ssm:GetParameter",
              "ssm:GetParameters"
          ],
          "Resource": "*"
      }]
  }
EOF
}