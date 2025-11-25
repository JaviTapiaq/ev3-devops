// Jenkinsfile
// Integrantes: Javiera Tapia Quintana Rut:
//              Joaquin Diez Gioia Rut:
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "vulnerable_flask_app"
        CONTAINER_NAME = "vulnerable_flask_app"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t %DOCKER_IMAGE% ."
            }
        }

        stage('Run Container') {
            steps {
                bat "docker run -d -p 5000:5000 --name %CONTAINER_NAME% %DOCKER_IMAGE%"
            }
        }

        stage('Smoke Tests') {
            steps {
                // acceso a contenedor
                bat "curl http://host.docker.internal:5000/"
            }
        }
    }

    post {
        always {
            bat "docker rm -f %CONTAINER_NAME% || echo Container not found"
        }
    }
}
