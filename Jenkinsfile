// Jenkinsfile
// Integrantes: Javiera Tapia Quintana Rut:
//              Joaquin Diez Gioia Rut:
pipeline {
    agent any

    environment {
        APP_NAME = 'vulnerable_flask_app'
        APP_PORT = '5000'
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
                bat "docker build -t ${APP_NAME} ."
            }
        }

        stage('Security Audit & Fix') {
            steps {
                echo 'Ejecutando auditoría de seguridad con pip-audit...'
                bat "docker run --rm ${APP_NAME} pip-audit"
                
                echo 'Actualizando pip si es necesario...'
                bat "docker run --rm ${APP_NAME} python -m pip install --upgrade pip"

                echo 'Rebuild de la imagen con pip actualizado...'
                bat "docker build -t ${APP_NAME} ."
            }
        }

        stage('Run Container') {
            steps {
                echo 'Iniciando contenedor...'
                bat "docker run -d --name ${APP_NAME}_container -p ${APP_PORT}:${APP_PORT} ${APP_NAME}"
            }
        }

        stage('Smoke Tests') {
            steps {
                echo 'Ejecutando pruebas básicas (Smoke Tests)...'
                bat "timeout /t 5"
                bat "curl -f http://localhost:${APP_PORT} || (echo \"Smoke Test falló\" & exit 1)"
            }
        }

        stage('OWASP ZAP Security Scan') {
            steps {
                echo 'Ejecutando pruebas de seguridad automatizadas con OWASP ZAP...'
                bat """
                docker run --rm -v %cd%:/zap/wrk/:rw -t owasp/zap2docker-stable zap-baseline.py -t http://host.docker.internal:${APP_PORT} -r zap_report.html
                """
            }
        }
    }

    post {
        always {
            echo 'Limpiando contenedor si existe...'
            bat "docker rm -f ${APP_NAME}_container || echo Contenedor no encontrado"
            
            echo 'Archivando reporte OWASP ZAP...'
            archiveArtifacts artifacts: 'zap_report.html', allowEmptyArchive: true
        }

        success {
            echo 'Pipeline finalizado correctamente.'
        }

        failure {
            echo 'Pipeline falló. Revisa los logs y el reporte de OWASP ZAP.'
        }
    }
}



