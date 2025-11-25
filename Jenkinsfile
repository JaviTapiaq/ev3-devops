// Jenkinsfile
// Integrantes: Javiera Tapia Quintana Rut:
//              Joaquin Diez Gioia Rut:
pipeline {
    agent any

    environment {
        APP_NAME = "vulnerable_flask_app"
        PORT = "5000"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                echo 'Clonando repositorio...'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Construyendo imagen Docker...'
                bat "docker build -t ${APP_NAME} ."
            }
        }

        stage('Security Audit & Fix') {
            steps {
                echo 'Ejecutando auditoría de seguridad con pip-audit...'
                bat """
                docker run --rm ${APP_NAME} pip-audit > pip_audit_report.txt || echo "Se encontraron vulnerabilidades"
                """
                archiveArtifacts artifacts: 'pip_audit_report.txt', allowEmptyArchive: true
            }
        }

        stage('Run Container') {
            steps {
                echo 'Levantando contenedor de la app...'
                bat "docker run -d --name ${APP_NAME}_container -p ${PORT}:${PORT} ${APP_NAME}"
            }
        }

        stage('OWASP ZAP Security Scan') {
            steps {
                echo 'Ejecutando OWASP ZAP...'
                // Escaneo rápido y generación de reporte
                bat """
                zap-cli quick-scan --self-contained --start-options '-config api.disablekey=true' http://localhost:${PORT} -r zap_report.html
                """
                archiveArtifacts artifacts: 'zap_report.html', allowEmptyArchive: true
            }
        }
    }

    post {
        always {
            echo 'Limpiando contenedor si existe...'
            bat "docker rm -f ${APP_NAME}_container || echo Contenedor no encontrado"
        }
    }
}





