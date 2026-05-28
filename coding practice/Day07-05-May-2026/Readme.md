aws ec2 describe-vpcs --query "Vpcs[*].{VpcId:VpcId,Name:Tags[?Key=='Name'].Value | [0]}" --output table
aws ec2 describe-subnets --query "Subnets[*].{SubnetId:SubnetId,VpcId:VpcId,Name:Tags[?Key=='Name'].Value | [0],CIDR:CidrBlock}" --output table
aws ec2 describe-security-groups --query "SecurityGroups[*].{GroupId:GroupId,GroupName:GroupName,VpcId:VpcId}" --output table
aws ec2 describe-key-pairs --query "KeyPairs[*].KeyName" --output text

# discover.tf
# ===========

provider "aws" {
  region = "us-east-1" # Set your target operational region
}

# Fetches a list of ALL VPC IDs in the account
data "aws_vpcs" "all" {}

# Fetches a list of ALL Subnet IDs in the account
data "aws_subnets" "all" {}

# Outputs the discovered IDs directly to your terminal screen
output "discovered_vpcs" {
  value = data.aws_vpcs.all.ids
}

output "discovered_subnets" {
  value = data.aws_subnets.all.ids
}
