pipeline {
  agent { label 'docker-host' } // change if your agent label is different; can be 'master' if controller is used
  environment {
    IMAGE_NAME = "local-testfile"
    IMAGE_TAG  = "${IMAGE_NAME}:${BUILD_NUMBER}"
    CONTAINER_NAME = "testfile-container"
    DEPLOY_DIR = "/var/lib/jenkins/deploy-testfile"
  }
  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          // Build the docker image (multi-stage Dockerfile will compile + package)
          sh """
            docker build -t ${IMAGE_TAG} .
          """
        }
      }
    }

    stage('Stop & Remove Old Container') {
      steps {
        sh """
          # stop old container if running
          if docker ps -q -f name=${CONTAINER_NAME} >/dev/null 2>&1; then
            echo "Stopping existing container ${CONTAINER_NAME}"
            docker stop ${CONTAINER_NAME} || true
          fi
          # remove container if exists (including exited)
          if docker ps -aq -f name=${CONTAINER_NAME} >/dev/null 2>&1; then
            echo "Removing existing container ${CONTAINER_NAME}"
            docker rm ${CONTAINER_NAME} || true
          fi
        """
      }
    }

    stage('Run Container') {
      steps {
        sh """
          # Run container detached. Note: the app prints "hello world" and exits. We still run for demo and capture logs next.
          docker run --name ${CONTAINER_NAME} ${IMAGE_TAG} >/dev/null 2>&1 || true
          # give container a moment
          sleep 1
        """
      }
    }

    stage('Show Logs / Smoke Check') {
      steps {
        sh """
          echo "=== container logs ==="
          docker logs ${CONTAINER_NAME} || true
          echo "======================"

          # Check if "hello world" was printed; fail the build if not
          if docker logs ${CONTAINER_NAME} 2>/dev/null | grep -q "hello world"; then
            echo "Smoke check OK: found 'hello world' in logs"
          else
            echo "Smoke check FAILED: 'hello world' not found in container logs" >&2
            exit 1
          fi
        """
      }
    }
  }

  post {
    success {
      echo "Build & run completed: ${IMAGE_TAG}"
    }
    failure {
      echo "Build or smoke check failed. See logs above."
    }
    always {
      // optional cleanup: remove image older than some builds - keep minimal here
      sh 'docker image prune -f || true'
    }
  }
}
