pipeline {
    agent {
        node {
            label "pubcloud_multiuse"
        }
    }
    stages {
        stage('Checkout'){
            steps {
                checkout scm
            }
        }
        stage('Lint'){
            steps {
                sh "./lint.sh"
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "./build-image.sh"
            }
        }
        stage('Publish Docker Image') {
            when {
                // only publish on merge to master
                expression { env.BRANCH_NAME == "master" }
            }
            environment {
                // creates DOCKER_HUB_CREDENTIALS_USR
                // and DOCKER_HUB_CREDENTIALS_PSW
                DOCKER_HUB_CREDENTIALS=credentials('dockerhubrpcjirasvc')
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
