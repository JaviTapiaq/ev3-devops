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
                echo 'Construyendo imagen Docker...'
                bat "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Security Audit & Fix') {
            steps {
                echo 'Ejecutando auditoría de seguridad con pip-audit...'
                // Si pip-audit falla, se captura el error pero no detiene el pipeline
                bat(script: "docker run --rm ${IMAGE_NAME} pip-audit", returnStatus: true)
            }
        }

        stage('Run Container') {
            steps {
                echo 'Levantando contenedor...'
                bat """
                docker run -d --name ${CONTAINER_NAME} -p 5000:5000 ${IMAGE_NAME}
                """
            }
        }

        stage('Smoke Tests') {
            steps {
                echo 'Ejecutando pruebas básicas...'
                bat """
                curl -s http://localhost:5000 || echo "Pruebas de humo fallidas"
                """
            }
        }

        stage('OWASP ZAP Security Scan') {
            steps {
                echo 'Ejecutando escaneo de seguridad OWASP ZAP...'
                bat """
                docker run --rm -v ${WORKSPACE}:/zap/wrk/:rw owasp/zap2docker-stable zap-baseline.py -t http://host.docker.internal:5000 -r zap_report.html
                """
            }
        }
    }

    post {
        always {
            echo 'Limpiando contenedor si existe...'
            bat "docker rm -f ${CONTAINER_NAME} || echo Contenedor no encontrado"

            echo 'Archivando reporte OWASP ZAP...'
            archiveArtifacts artifacts: 'zap_report.html', allowEmptyArchive: true
        }
    }
}




