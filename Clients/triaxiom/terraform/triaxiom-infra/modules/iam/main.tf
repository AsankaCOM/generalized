#
#
#
# IAM Roles
#

resource "aws_iam_role" "ec2_s3_access_role" {

  name               = "s3-role"
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
  role = aws_iam_role.ec2_s3_access_role.name
}

resource "aws_iam_role_policy_attachment" "instance_role_1" {
  
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.ec2_s3_access_role.name
}