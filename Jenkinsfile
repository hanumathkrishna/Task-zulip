pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "hanumath/zulip-task:latest"
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Zulip Docker image..."
                    sh """
                        docker build -t ${DOCKER_IMAGE} -f Dockerfile-postgresql .
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Zulip Docker image to Docker Hub..."
                    sh """
                        echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                        docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes (via Helm)') {
            steps {
                script {
                    echo "Deploying Zulip to Kubernetes using Helm..."
                    sh """
                        helm upgrade --install zulip-task ./helm/zulip \
                            --set image.repository=${DOCKER_IMAGE.split(':')[0]} \
                            --set image.tag=${DOCKER_IMAGE.split(':')[1]} \
                            --namespace default --create-namespace
                    """
                }
            }
        }
    }
}

