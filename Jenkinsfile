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
                echo "Clonando repositorio..."
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
                bat """
                    docker run --rm ${IMAGE_NAME} pip-audit > pip_audit_report.txt 2>&1 || echo "Se encontraron vulnerabilidades"
                """
                //se archiva reporte de pip-audit
                archiveArtifacts artifacts: 'pip_audit_report.txt', fingerprint: true
            }
            //no falla el pipeline aunque haya vulnerabilidades
            post {
                always {
                    echo "pip-audit terminado. Revisar pip_audit_report.txt"
                }
            }
        }

        stage('Run Container') {
            steps {
                echo "Ejecutando contenedor..."
                bat """
                    docker run -d --name ${CONTAINER_NAME} -p 5000:5000 ${IMAGE_NAME}
                """
            }
        }

        stage('OWASP ZAP Security Scan') {
            steps {
                echo "Ejecutando escaneo OWASP ZAP..."
                //comandos zap
                bat """
                    zap.sh -daemon -port 8080 -host 0.0.0.0
                    zap-cli quick-scan http://localhost:5000
                    zap-cli report -o zap_report.html -f html
                """
                //se archiva reporte de OWASP ZAP
                archiveArtifacts artifacts: 'zap_report.html', fingerprint: true
            }
        }
    }

    post {
        always {
            echo "Limpiando contenedores y recursos..."
            bat "docker rm -f ${CONTAINER_NAME} || echo Contenedor no encontrado"
            bat "docker rmi -f ${IMAGE_NAME} || echo Imagen no encontrada"
        }
    }
}





