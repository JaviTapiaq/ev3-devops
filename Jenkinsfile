// Jenkinsfile
// Integrantes: Javiera Tapia Quintana Rut:
//              Joaquin Diez Gioia Rut:
pipeline {
    agent any

    environment {
        IMAGE_NAME = "vulnerable_flask_app"
        CONTAINER_NAME = "vulnerable_flask_app_container"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Security Audit') {
            steps {
                echo "Ejecutando auditoría de seguridad con pip-audit..."
                // Contenedor temporal para audit, se elimina al terminar
                bat "docker run --rm ${IMAGE_NAME} pip-audit"
            }
        }

        stage('Run Container') {
            steps {
                echo "Levantando contenedor de la aplicación..."
                // Levantar contenedor de forma persistente en background
                bat "docker run -d --name ${CONTAINER_NAME} -p 5000:5000 ${IMAGE_NAME}"
                // Se espera unos segundos para que la app inicie
                bat "timeout /t 5"
            }
        }

        stage('Smoke Tests') {
            steps {
                echo "Ejecutando tests de humo..."
                // Ejemplo: test simple de que la app responde
                bat "curl http://localhost:5000/"
            }
        }
    }

    post {
        always {
            echo "Limpiando contenedor si existe..."
            bat "docker rm -f ${CONTAINER_NAME} || echo Contenedor no encontrado"
        }
    }
}


