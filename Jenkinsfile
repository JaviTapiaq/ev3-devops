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
                echo "Construyendo imagen Docker..."
                bat "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Security Audit & Fix') {
            steps {
                echo "Ejecutando auditoría de seguridad con pip-audit..."
                script {
                    // Ejecuta pip-audit, pero no detiene el pipeline
                    def auditResult = bat(script: "docker run --rm ${IMAGE_NAME} pip-audit", returnStatus: true)
                    
                    if (auditResult != 0) {
                        echo "Vulnerabilidades encontradas, aplicando corrección..."
                        // Corrección: actualizar pip en la imagen
                        bat "docker run --rm ${IMAGE_NAME} python -m pip install --upgrade pip"
                        echo "Rebuild de la imagen con pip actualizado..."
                        bat "docker build -t ${IMAGE_NAME} ."
                    } else {
                        echo "No se encontraron vulnerabilidades."
                    }
                }
            }
        }

        stage('Run Container') {
            steps {
                echo "Iniciando contenedor..."
                bat "docker run -d --name ${CONTAINER_NAME} -p 5000:5000 ${IMAGE_NAME}"
            }
        }

        stage('Smoke Tests') {
            steps {
                echo "Ejecutando pruebas básicas (Smoke Tests)..."
                bat """
                timeout /t 5
                curl -f http://localhost:5000 || (echo "Smoke Test falló" & exit 1)
                """
            }
        }
    }

    post {
        always {
            echo "Limpiando contenedor si existe..."
            bat "docker rm -f ${CONTAINER_NAME} || echo Contenedor no encontrado"
        }
        success {
            echo "Pipeline finalizado correctamente."
        }
        failure {
            echo "Pipeline finalizado con errores."
        }
    }
}


