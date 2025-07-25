pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = 'true'
    }

    stages {
        stage('Clone Repo') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Run Ansible') {
            steps {
                sh 'ansible-playbook -i ansible/hosts.cfg playbooks/install_jenkins.yml'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f playbooks/k8s-deploy/'
            }
        }
    }
}
