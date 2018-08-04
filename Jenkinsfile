pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                sh "sudo docker build -t github.com/rcbops/re-jenkins:0.0.1 ."
            }
        }
        stage('Publich Docker Image') {
            steps {
                sh "sudo docker push github.com/rcbops/re-jenkins:0.0.1"
            }
        }
    }
}
