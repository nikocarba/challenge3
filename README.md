# Data challenge

This project uses Terraform to create AWS resources and facilitates data loading onto S3 for later analysis. It sets up the necessary infrastructure and scripts to automate the data pipeline.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [Setup](#setup)
- [Usage](#usage)

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) v0.12 or later
- AWS account with appropriate permissions
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured

## Architecture
This project provisions the following AWS resources:
- S3 bucket: To store data files
- IAM roles and policies: To manage permissions
- AWS Glue: To orchestrate the ETL process
- CloudWatch: For logging and monitoring
- Terraform: For deploying resources in AWS through IaC
- Athena: For querying data

![image](https://github.com/user-attachments/assets/14ca3a80-36c9-4c4a-929b-1b463ab1060a)

## Setup

1. **Create a User for Terraform (OPTIONAL):**
   Create an IAM user in AWS with the following policy to allow Terraform to manage resources:
   ```json
	{
	    "Version": "2012-10-17",
	    "Statement": [
	        {
	            "Effect": "Allow",
	            "Action": [
	                "s3:*",
	                "s3-object-lambda:*"
	            ],
	            "Resource": "*"
	        },
			{
	            "Effect": "Allow",
	            "Action": "iam:PassRole",
	            "Resource": "*",
	            "Condition": {
	                "StringEquals": {
	                    "iam:PassedToService": "glue.amazonaws.com"
	                }
	            }
	        },
			{
	            "Effect": "Allow",
	            "Action": [
	                "glue:CreateJob",
	                "glue:GetJobs",
	                "glue:BatchGetJobs",
	                "glue:UpdateJob",
	                "glue:DeleteJob",
	                "glue:GetTags",
                	"glue:GetJob",
                	"glue:TagResource"
	            ],
	            "Resource": "*"
	        },
			{
	            "Effect": "Allow",
	            "Action": [
	                "secretsmanager:GetResourcePolicy",
	                "secretsmanager:UntagResource",
	                "secretsmanager:DescribeSecret",
	                "secretsmanager:PutSecretValue",
	                "secretsmanager:CreateSecret",
	                "secretsmanager:DeleteSecret",
	                "secretsmanager:TagResource",
	                "secretsmanager:UpdateSecret",
	                "secretsmanager:GetSecretValue",
	                "secretsmanager:ListSecrets"
	            ],
	            "Resource": "*"
	        },
			{
	            "Effect": "Allow",
	            "Action": [
	                "iam:GetRole",
	                "iam:UpdateAssumeRolePolicy",
	                "iam:ListRoleTags",
	                "iam:UntagRole",
	                "iam:TagRole",
	                "iam:ListRoles",
	                "iam:CreateRole",
	                "iam:DeleteRole",
	                "iam:AttachRolePolicy",
	                "iam:PutRolePolicy",
	                "iam:ListInstanceProfilesForRole",
	                "iam:PassRole",
	                "iam:DetachRolePolicy",
	                "iam:ListAttachedRolePolicies",
	                "iam:DeleteRolePolicy",
	                "iam:UpdateRole",
	                "iam:ListRolePolicies",
	                "iam:GetRolePolicy"
	            ],
	            "Resource": "*"
	        }
	    ]
	}
   ```

2. **Configure AWS Credentials:**
   Use the AWS CLI to configure credentials for Terraform to use. The account used for this configuration will be needed for the following steps, so it should have permissions to deploy the entire architecture. You may use the user created on the previous step.
   ```sh
   aws configure
   ```
   Enter your AWS Access Key ID, Secret Access Key, default region name, and output format when prompted.

3. **Clone the repository:**
   ```sh
   git clone https://github.com/nikocarba/challenge.git
   cd challenge
   ```

4. **Initialize Terraform:**
   ```sh
   terraform init
   ```

5. **Plan and apply the Terraform configuration:**
   ```sh
   terraform plan
   terraform apply
   ```

## Usage

1. **Trigger the AWS Glue job:**
   The Glue job can be manually triggered, or you can set up an event source (e.g., S3 upload event) to automatically trigger it.
   ```sh
   aws glue start-job-run --job-name "load-to-s3-dataengineer-challenge-ncarballal"
   ```
   
3. **Monitor the process:**
   Use CloudWatch to monitor the logs and ensure the data loading process completes successfully.

4. **Validate data in s3:**
   Once the job finished executing, validate data in Snowflake using the following queries:
   ```sql
   -- Count the number of rows in the table
   SELECT COUNT(*) FROM "default"."fakebank";

   -- Retrieve the first 10 rows
   SELECT * FROM "default"."fakebank" limit 10;
   ```
