# terraform-project

## Table of Contents

## Terraform Overview

Terraform is an open-source Infrastructure as Code (IaC) tool that enables you to define, provision, and manage cloud resources across multiple providers using a declarative language. It supports integration with various cloud platforms, including AWS, Azure, Google Cloud, and more.

### Key Features

- **Multi-Cloud Support**: Seamlessly provision and manage resources across different cloud providers.
- **Infrastructure as Code**: Define infrastructure using a high-level configuration language.
- **Version Control**: Easily integrate with version control systems for collaboration and change tracking.
- **Modular Architecture**: Create reusable modules for consistent infrastructure deployment.

### Benefits

1. **Consistency**: Ensure uniform infrastructure across environments.
2. **Automation**: Streamline provisioning and reduce manual errors.
3. **Scalability**: Easily scale infrastructure up or down as needed.
4. **Cost Efficiency**: Optimize resource utilization and manage costs effectively.
5. **Collaboration**: Enhance team workflows and knowledge sharing.


Terraform's ability to work with multiple cloud providers and its declarative approach to infrastructure management make it a powerful tool for modern DevOps practices and cloud-native development.


### clone this repository into your local pc
Make sure you are logged to your azure account using az login (if you dont have az CLI, download it from [text](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli))


## terraform.tfvars
Before running any commands you need to insert credentials for the variables that are set in variables.tf:
VM_USER     = 
VM_PASSWORD = 
my_publicIP = 
DB_USER     = 
DB_PASSWORD = 
## terraform set up
cd into infrastructure folder and use the following commands:
-  terraform init
- terraform plan
- terraform apply


## After the infrastructure is built
Go to azure portal and connect through azure bastion to the 
private VM with the credentials you gave it

then run the following commands:
- git clone https://github.com/danielbiton342/flask-psql.git
- export DB_PASSWORD="your password"
- sudo chmod +x psql_setup.sh
- cd flask-psql && sudo ./psql_setup.sh

## App VM
In order to ssh into the public vm use the following command:
- ssh -i ~/terraform-project/infrastructure/flaskvm_key.pem terademo@"public ip"
- export DB_PASSWORD="your password"
- sudo chmod +x ~/flask-psql/app_setup.sh
- sudo ./app_setup.sh


## Clean up
```bash
terraform destroy
```
