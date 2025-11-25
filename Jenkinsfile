// Jenkinsfile
// Integrantes: Javiera Tapia Quintana Rut:
//              Joaquin Diez Gioia Rut:

pipeline {
    agent any

    environment {
        IMAGE_NAME = "vulnerable_flask_app"
        CONTAINER_NAME = "vuln_flask"
        PORT = "5000"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/JaviTapiaq/ev3-devops.git'
            }
        }

        stage('Build') {
            steps {
                bat 'docker build -t %IMAGE_NAME% .'
            }
        }

        stage('Unit Tests (Basic)') {
            steps {
                bat 'echo Running basic test...'
                bat 'python create_db.py'
            }
        }

        stage('Run container') {
            steps {
                bat 'docker rm -f %CONTAINER_NAME% || exit 0'
                bat 'docker run -d --name %CONTAINER_NAME% -p 5000:5000 %IMAGE_NAME%'
            }
        }

        stage("Smoke Tests") {
            steps {
                bat 'timeout /t 5 /nobreak'
                bat 'curl -Is http://localhost:5000 | findstr "HTTP/"'
            }
        }

        stage('Deploy') {
            steps {
                echo "Application is deployed locally in Docker"
            }
        }
    }
}
