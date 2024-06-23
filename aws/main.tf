provider "aws" {
  region = "ap-southeast-1"
  # profile = "cilsy"
}

provider "random" {
  # No configuration required for the random provider
}

# Define a list of user names
locals {
  user_names = [for i in range(60) : "user_${i}"]
}

# Reference the existing IAM group named "Student"
data "aws_iam_group" "student_group" {
  group_name = "Student"
}

# Create IAM users
resource "aws_iam_user" "example_user" {
  for_each = toset(local.user_names)
  name     = each.value
  force_destroy = true
}

# Add IAM users to the existing "Student" group
resource "aws_iam_user_group_membership" "example_user_membership" {
  for_each = toset(local.user_names)
  user     = each.value
  groups   = [data.aws_iam_group.student_group.group_name]
  depends_on = [aws_iam_user.example_user]
}

# Create access keys for each user
resource "aws_iam_access_key" "example_user_key" {
  for_each = toset(local.user_names)
  user     = each.value
  depends_on = [aws_iam_user.example_user]
}

# Set the password using AWS CLI
resource "null_resource" "set_password" {
  for_each = toset(local.user_names)

  provisioner "local-exec" {
    command = "aws iam create-login-profile --user-name ${each.value} --password 'qHEb5pcTFBYhdQg9MnXZ7vx8'"
  }

  depends_on = [aws_iam_user.example_user]
}

# Output the data to a local JSON file
resource "local_file" "output_json" {
  content = jsonencode([
    for k, v in aws_iam_access_key.example_user_key : {
      user_name         = k
      access_key        = v.id
      secret_access_key = v.secret
      console_login_url = "https://console.aws.amazon.com/"
      password          = "qHEb5pcTFBYhdQg9MnXZ7vx8"
      account_id = "613281539635"
    }
  ])
  filename = "${path.module}/output.json"
  depends_on = [aws_iam_access_key.example_user_key]
}

output "output_file_path" {
  value = local_file.output_json.filename
}
