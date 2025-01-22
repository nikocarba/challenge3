resource "aws_iam_role" "glue_role" {
  name = "${var.project}-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      },
    ]
  })

  tags = local.project_tags
}

resource "aws_iam_role_policy" "glue_policy" {
  name = "${var.project}-policy"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "glue:GetConnection",
              "glue:GetTable",
              "glue:CreateTable",
              "cloudwatch:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
              "s3:GetObject",
              "s3:PutObject"
            ]
            "Resource": "arn:aws:s3:::*${var.project}-${var.owner}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*:/aws-glue/*",
                "arn:aws:logs:*:*:*:/customlogs/*"
            ]
        }
    ]
})
}