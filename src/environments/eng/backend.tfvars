#-------------------------------------------------------------------------------------------------------
# Specify the Required Arguments to Configure the S3 Remote Backend
#-------------------------------------------------------------------------------------------------------
bucket         = "terraform-remote-state"
key            = "shared-resources/terraform.tfstate"
dynamodb_table = "terraform-remote-state"
encrypt        = true
region         = "<AWS_REGION>"
