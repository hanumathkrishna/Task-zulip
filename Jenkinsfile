pipeline {
  agent any

  environment {
    DOCKER_IMAGE = "hanumath/zulip-task"
    DOCKER_CRED = credentials('dockerhub')
    HELM_CHART_PATH = "helm/zulip"
    K8S_NAMESPACE = "default"
  }

  stages {
    stage('Checkout Code') {
      steps {
        checkout scm
        script {
          env.GIT_SHA = sh(returnStdout: true, script: "git rev-parse --short=8 HEAD").trim()
          env.IMAGE_TAG = "${env.GIT_SHA}"
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          sh """
            echo "Building Docker image ${DOCKER_IMAGE}:${IMAGE_TAG}"
            docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} -f Dockerfile .
          """
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh """
            echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
            docker push hanumath/zulip-task:${GIT_COMMIT:0:7}
          """
        }
      }
    }

    stage('Deploy to Kubernetes via Helm') {
      steps {
        script {
          echo "Deploying Zulip to Kubernetes via Helm..."
          sh """
            helm upgrade --install zulip-task ${HELM_CHART_PATH} \
              --namespace ${K8S_NAMESPACE} --create-namespace \
              --set image.repository=${DOCKER_IMAGE} \
              --set image.tag=${IMAGE_TAG} \
              --wait --timeout 10m
          """
        }
      }
    }
  }
}
