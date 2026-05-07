resource "aws_iam_role" "full_access_role" {
  name = "${var.prefix}S3FullAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_s3_full" {
  role       = aws_iam_role.full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "profile_s3_full" {
  name = "${var.prefix}S3FullAccessProfile"
  role = aws_iam_role.full_access_role.name
}
