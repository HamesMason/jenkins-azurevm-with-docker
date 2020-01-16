pipeline {
 agent any

 stages {
  stage('Begin') {
    steps {
      echo "Job starting..."
      echo "Connecting to azure..."
      sh 'az login --service-principal -u 305034cb-c5d4-4052-9dbf-2b5f518a65ef -p d5e9e20b-842b-4d7a-b67d-4ca117525d15 --tenant ab2991ed-49bc-4864-9116-c895d24ca7d5'
      }
    }

 stage('Set Terraform path') {
 steps {
  sh 'terraform —version'
  }
 }

 stage('Provision infrastructure') {

 steps {
 sh 'terraform init'
 sh 'terraform plan'
 // sh ‘terraform destroy -auto-approve'
 sh 'terraform apply -auto-approve'


 }
 }



 }
}
