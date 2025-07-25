# Configure AWS provider
     provider "aws" {
       region = "ap-south-1"
     }
     # Create Ansible inventory file
     resource "local_file" "ansible_inventory" {
       content = templatefile("./templates/hosts.tpl", {
         keyfile     = var.pemfile,
         demoservers = aws_instance.ansible_nodes.*.public_ip
       })
       filename = "./ansible/hosts.cfg"
     }
     # Create EC2 Ansible target nodes (slaves)
     resource "aws_instance" "ansible_nodes" {
       count                      = var.servercount
       ami                        = var.amiid
       instance_type              = "t2.medium"
       key_name                   = var.pemfile
       associate_public_ip_address = true
       vpc_security_group_ids     = [aws_security_group.allow_all.id]
       user_data = <<-EOF
     #!/bin/bash
     sudo apt update
     sudo apt install -y python3
     EOF
       tags = {
         Name = count.index == 0 ? "k8s" : "Jenkins"
       }
     }
     # Security group to allow necessary traffic
     resource "aws_security_group" "allow_all" {
       name        = "allow_all"
       description = "Allow SSH, Jenkins, Kubernetes, and HTTP traffic"
       ingress {
         from_port   = 22
         to_port     = 22
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
       }
       ingress {
         from_port   = 8080
         to_port     = 8080
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"] # Jenkins
       }
       ingress {
         from_port   = 80
         to_port     = 80
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"] # Node.js app
       }
       ingress {
         from_port   = 10250
         to_port     = 10250
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"] # Kubernetes
       }
       egress {
         from_port   = 0
         to_port     = 0
         protocol    = "-1"
         cidr_blocks = ["0.0.0.0/0"]
       }
     }
     # Output public IPs of target nodes
     output "target_node_ips" {
       value = aws_instance.ansible_nodes[*].public_ip
     }
