# deploy-docker-openvpn
## Description

A way to deploy [kylmanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn) in AWS EC2 using Terraform and Puppet.

docker-openvpn is a great project that defines a [Docker container](https://www.docker.com/) that runs [OpenVPN](https://openvpn.net/). If you're looking for a way to set up your own VPN, this is a really good option.

Running OpenVPN in a container is just [a great idea](https://github.com/kylemanna/docker-openvpn#benefits-of-running-inside-a-docker-container).

This project deploys a [Fedora Cloud](https://alt.fedoraproject.org/cloud/) server. I've configured firewall rules and SELinux to secure things as much as possible.


## Prerequisites
### Terraform

[Terraform](https://www.terraform.io/) is a cool project from [Hashicorp](https://www.hashicorp.com/) that allows you to define a stack of infrastructure in code, then [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) that infrastructure. Download and install it.

### AWS

The point of this project is to set up an OpenVPN box in [AWS](https://aws.amazon.com/), so obviously you need an AWS account. For this project, you will also need 
 * [access keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey).
 * [EC2 key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html). This is just a regular SSH key pair, but you have to upload the public key to AWS.

### FQDN

While you don't technically need a 'friendly' name for your VPN, this project depends on your having one. You could work your way around this, but I didn't think it too burdensome to require one. You'll need to be able to assign the IP address of your VPN to this [FQDN](https://en.wikipedia.org/wiki/Fully_qualified_domain_name) after you're assigned one during provisioning.



## Make it so
### Configuration

First, you need to edit a couple of text files. I include a some examples in the project; just edit these and rename them.

#### terraform.tfvars
This file defines some variables so Terraform can deploy your EC2 instance in AWS.
```
aws_access_key = "foo"
aws_secret_key = "secretfoo"
region - "us-east-1"
base_image = "ami-e5ad85f2"
instance_type = "t2.micro"
ssh_key = "/path/to/your_private_key.pem"
ssh_key_name = "your_private_key"
```

**aws_access_key** - Your Access Key ID.

**aws_secret_key** - Your Secret Access Key.

**region** - AWS region to deploy to.

**base_image** - AMI ID of the Fedora Cloud image in your region. The included ID is Fedora 25 in us-east-1.

**instance_type** - EC2 instance type. t2.micro is probably fine for personal use.

**ssh_key** - Path to your local secret EC2 (SSH) Key.

**ssh_key_name** - Name of the Key Pair in EC2.


#### files_to_provision/vpn.yaml
```yaml
---
vpn_url: myvpn.example.com
clients:
  - my-laptop
  - my-phone
  - my-tablet
```

**vpn_url** - The FQDN you'll assign to your VPN.

**clients** - A list of client configs you want to generate. This could be a single client config if that's what you want.

Note! yaml is very sensitive to syntax, so watch your spaces and indents.


### Deploy to AWS
```shell
terraform plan
```

This will tell you what Terraform is going to do.

```shell
terraform apply
```

This will deploy your VPN in AWS. At the end of the run, it will output the IP address of your EC2 instance.


### Configure your VPN
```shell
ssh -i /path/to/your_private_key.pem fedora@your.ip.address
sudo /opt/docker-openvpn/quickstart.sh
```

Answer the prompts and configure your VPN.

Note that the CA setup phase can take a long time. Be patient.


### Client setup
Client configs for each of the clients you defined will be on your EC2 instance. Retrieve them
```shell
scp -i /path/to/your_private_key.pem fedora@your.ip.address:your_client.ovpn .
```

and set up your client.
