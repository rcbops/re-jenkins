pipeline {
    agent any
    stages {
        stage('Checkout'){
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "./build-image.sh"
            }
        }
        stage('Publish Docker Image') {
            environment {
                // creates DOCKER_HUB_CREDENTIALS_USR
                // and DOCKER_HUB_CREDENTIALS_PSW
                DOCKER_HUB_CREDENTIALS=credentials('dockerhubrpcjirasvc')
                version="0.0.2"
            }
            steps {
                sh """
                    # --password-stdin not available on long running slaves.
                    docker login -p "${DOCKER_HUB_CREDENTIALS_PSW}" -u "${DOCKER_HUB_CREDENTIALS_USR}"
                    ./publish-image.sh
                """
            }
        }
    }
}
