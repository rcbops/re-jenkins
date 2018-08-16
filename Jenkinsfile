pipeline {
    agent any
    stages {
        stage('Checkout'){
            steps {
                githubNotify(
                    context: 'cit/pipeline',
                    description: 'RE Jenkins CI',
                    status: 'PENDING',
                    credentialsId: 'github_account_rpc_jenkins_svc',
                )
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
            }
            steps {
                sh """
                    # --password-stdin not available on long running slaves.
                    docker login -p "${DOCKER_HUB_CREDENTIALS_PSW}" -u "${DOCKER_HUB_CREDENTIALS_USR}"
                    ./publish-image.sh
                """
            }
        }
        stage('Cleanup'){
            steps{
                githubNotify(
                    context: 'cit/pipeline',
                    description: 'RE Jenkins CI',
                    status: 'SUCCESS',
                    credentialsId: 'github_account_rpc_jenkins_svc',
                )
            }
        }
    }
    post {
        failure {
            githubNotify(
                context: 'cit/pipeline',
                description: 'RE Jenkins CI',
                status: 'FAILURE',
                credentialsId: 'github_account_rpc_jenkins_svc',
            )
        }
    }
}
