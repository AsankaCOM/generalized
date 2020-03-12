#
#
#
# IAM Roles
#

resource "aws_iam_role" "ec2_s3_ssm_access_role" {

  name               = "s3-ssm-role"
  assume_role_policy = <<POLICY
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
POLICY
}

resource "aws_iam_instance_profile" "instance_profile" {

  name  = "instance_profile"
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
  role = aws_iam_role.ec2_s3_ssm_access_role.name
  policy = <<EOF
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