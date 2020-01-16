pipeline {
 agent any

 stages {
  stage('Begin') {
    steps {
      echo "Job starting..."
      }
    }

 stage('Check terraform version') {
 steps {
  sh "terraform -version"
  }
 }

 stage('Provision infrastructure') {

 steps {
 sh "terraform init"
 sh "terraform apply -auto-approve"
  }
}
}
}
