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
                //espera hasta que Flask esté listo
                script {
                    def retries = 15
                    def ready = false
                    for (int i = 0; i < retries; i++) {
                        def result = bat(script: "curl -s -o NUL -w \"%{http_code}\" http://host.docker.internal:5000/", returnStdout: true).trim()
                        if (result == "200") {
                            ready = true
                            break
                        }
                        sleep 2
                    }
                    if (!ready) {
                        error "Flask container no respondió en el tiempo esperado"
                    }
                }
            }
        }
    }

    post {
        always {
            bat "docker rm -f %CONTAINER_NAME% || echo Container not found"
        }
    }
}
