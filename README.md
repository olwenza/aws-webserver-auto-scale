# aws-webserver-auto-scale

# 🚀 Project Title

AWS Webserver Auto Scaling

# 📝 Overview

Setup scales aws webapp using ALB and auto scaling. The base branch 'origin/1-add-folder-structure' is a VPC with 3 subnets in 3 different availability zones. Each subnet has an ec2 instance with apach server installed.

# 🚀 Run application

1. Initialize terraform

```
terraform init
```

2. Plan terraform

```
terraform plan
```

3. Run terraform

```
terraform apply
```

4. Create a key to ssh to the ec2 server

```
aws ec2 create-key-pair \
  --key-name aws-ec2-key \
  --query 'KeyMaterial' \
  --output text > aws-ec2-key.pem
```

5. Lock down key permission

```
chmod 400 aws-ec2-key.pem
```

6. Verify key was created and is there

```
aws ec2 describe-key-pairs --query "KeyPairs[].KeyName"

```

7- Use the following command to ssh into a ec2 instance

```
ssh -i aws-ec2-key.pem ec2-user@<PUBLIC_IP>
```

ssh -i aws-ec2-key.pem ec2-user@http://34.205.87.161

# ⏬ Download

Use the follow git command to clone the project

```
git clone https://github.com/olwenza/aws-webserver-auto-scale.git
```

# ✏️ Authors

Contributors names and contact info

Ivan Augustino
[@ivanaugustino](https://www.linkedin.com/in/ivanaugustino/)

# 📄 License

This project is licensed under the MIT License.
