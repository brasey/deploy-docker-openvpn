variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {}
variable "base_image" {}
variable "instance_type" {}
variable "ssh_key" {}
variable "ssh_key_name" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

resource "aws_security_group" "vpn" {
  name = "VPN instance"
  description = "Open inbound SSH"
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "udp"
    from_port = 1194
    to_port = 1194
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vpn" {
  ami = "${var.base_image}"
  instance_type = "${var.instance_type}"
  associate_public_ip_address = "true"
  security_groups = ["${aws_security_group.vpn.name}"]
  key_name = "${var.ssh_key_name}"
  tags {
    Name = "docker-openvpn"
    created_by = "terraform"
  }

  provisioner "file" {
    source = "./files_to_provision/"
    destination = "/tmp"
    connection {
      host = "${self.public_ip}"
      user = "fedora"
      private_key = "${file(var.ssh_key)}"
    }
  }

  provisioner "remote-exec" {
    scripts = [ "./scripts/configure_node.sh" ]
    connection {
      host = "${self.public_ip}"
      user = "fedora"
      private_key = "${file(var.ssh_key)}"
    }
  }
}

output "address" {
  value = "${aws_instance.vpn.public_ip}"
}
