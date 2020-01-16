pipeline {
 agent any

 stages {
 stage(‘Begin’) {
 steps {
 echo "Job starting..."

 }
 }
 stage(‘Set Terraform path’) {
 steps {
 script {
 def tfHome = tool name: ‘Terraform’
 env.PATH = “${tfHome}:${env.PATH}”
 }
 sh ‘terraform — version’


 }
 }

 stage(‘Provision infrastructure’) {

 steps {
 dir(‘execute’)
 {
 sh ‘terraform init’
 sh ‘terraform plan -out=plan’
 // sh ‘terraform destroy -auto-approve’
 sh ‘terraform apply plan’
 }


 }
 }



 }
}
