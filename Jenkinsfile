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
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Unit Tests (Basic)') {
            steps {
                sh 'echo "Running basic test..."'
                sh 'python create_db.py'
            }
        }

        stage('Run container') {
            steps {
                sh 'docker rm -f $CONTAINER_NAME || true'
                sh 'docker run -d --name $CONTAINER_NAME -p 5000:5000 $IMAGE_NAME'
            }
        }

        stage("Smoke Tests") {
            steps {
                sh 'sleep 5'
                sh 'curl -Is http://localhost:5000 | head -n 1'
            }
        }

        stage('Deploy') {
            steps {
                echo "Application is deployed locally in Docker"
            }
        }
    }
}
