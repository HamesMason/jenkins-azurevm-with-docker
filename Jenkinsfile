pipeline {
 agent any

 stages {
  stage('Begin') {
    steps {
      echo "Job starting..."
      }
    }

 stage('Set Terraform path') {
 steps {
  sh ‘terraform — version’
  }
 }

 stage('Provision infrastructure') {

 steps {
 sh ‘terraform init’
 sh ‘terraform plan -out=plan’
 // sh ‘terraform destroy -auto-approve’
 sh ‘terraform apply plan’


 }
 }



 }
}
