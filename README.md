In this repo, we’ll create an EC2 instance in a VPC with a security group. A user data file will do the following actions:
•	Rename the server
•	Set the DNS address
•	Set time zone
•	Install Active Directory Domain Services
•	Promoting Server to Domain Controller
•	Install and configure the DHCP role

It’s supposed that you have configured your AWS CLI
You have to give several values to variables, perhaps in a terraform.tfvars. Here is an example of the content of this file:
key_name = "your-instance-key"

cidr = "30.0.0.0/16"

public_subnets = ["30.0.1.0/24"]

private_subnets = ["30.0.20.0/24"]

azs = ["us-east-2a", "us-east-2b", "us-east-2c"]

cidr_blocks_ingress = ["10.20.0.0/24", "10.20.50.0/24", "67.71.112.88/32"]

cidr_blocks_egress = ["0.0.0.0/0"]


####values of variables used in the user_data template ##########
private_ip = "30.0.20.20"

ServerName = "SRVADDS01"

DomainName = "yourproject.com"

ForestMode = "Win2012R2"

DomainMode = "Win2012R2"

DatabasePath = "C:\\ADDS\\NTDS"

SYSVOLPath = "C:\\ADDS\\SYSVOL"

LogPath = "C:\\ADDS\\Logs"

Password = "terraform2020"

AdminSafeModePassword = "Secureterraform2020"

TimeZoneID = "Eastern Standard Time"

####Value for differents tags#############

tags = {
  Terraform   = "true"
  Name        = "yourproject"
  Owner       = "fopingn"
  Environment = "dev"
}

vpc_tags = {
  Name = "vpc_adds-servers"
}

igw_tags = {
  Name = "igw_adds-servers"
}

public_subnet_tags = {
  Name = "public_subnet-adds-servers"
}

private_subnet_tags = {
  Name = "private_subnet-adds-servers"
}

Deploy the code:

```
terraform init
terraform apply

Clean up when you're done:
terraform destroy
```
