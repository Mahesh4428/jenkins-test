
$ terraform plan -out tfplan -var "pemfile=YOURPEMFILE" 
$ terraform apply -auto-approve tfplan
$ terraform destroy

1. clone the repo
2. copy your respective pem file to the local repo
3. run terraform 
