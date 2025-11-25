// Jenkinsfile
// Integrantes: Javiera Tapia Quintana Rut:
//              Joaquin Diez Gioia Rut:
pipeline {
    agent any

    environment {
        //nombre de la imagen Docker a construir
        IMAGE_NAME = "vulnerable_flask_app"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/JaviTapiaq/ev3-devops.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                //construye imagen usando Docker
                bat "docker build -t %IMAGE_NAME% ."
            }
        }

        stage('Run Container') {
            steps {
                // Corre el contenedor en segundo plano
                bat "docker run -d -p 5000:5000 --name %IMAGE_NAME% %IMAGE_NAME%"
            }
        }

        stage('Smoke Tests') {
            steps {
                //verifica que la app está corriendo
                bat "curl http://localhost:5000/"
            }
        }
    }

    post {
        always {
            //elimina el contenedor si existe
            bat "docker rm -f %IMAGE_NAME% || echo Container not found"
        }
    }
}
