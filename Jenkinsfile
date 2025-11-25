// Jenkinsfile
// Integrantes: Javiera Tapia Quintana Rut:
//              Joaquin Diez Gioia Rut:
pipeline {
    agent any

    environment {
        IMAGE_NAME = "vulnerable_flask_app"
        CONTAINER_NAME = "vulnerable_flask_app_container"
        APP_PORT = "5000"
        ZAP_REPORT = "zap_report.html"
        PIP_AUDIT_JSON = "pip_audit_report.json"
        PIP_AUDIT_TXT = "pip_audit_report.txt"
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

        stage('Security Audit (pip-audit)') {
            steps {
                echo "Ejecutando pip-audit..."
                // Ejecuta pip-audit y genera reportes JSON y TXT
                bat """
                    docker run --rm ${IMAGE_NAME} pip-audit -f json > ${PIP_AUDIT_JSON} 2>&1 || echo "Se encontraron vulnerabilidades"
                    docker run --rm ${IMAGE_NAME} pip-audit > ${PIP_AUDIT_TXT} 2>&1 || echo "Se encontraron vulnerabilidades"
                """
                archiveArtifacts artifacts: "${PIP_AUDIT_JSON},${PIP_AUDIT_TXT}", fingerprint: true
            }
            post {
                always {
                    echo "pip-audit finalizado. Revisar reportes."
                }
            }
        }

        stage('Run Application Container') {
            steps {
                echo "Ejecutando contenedor de la aplicación..."
                // Limpieza previa por si ya estaba corriendo
                bat "docker rm -f ${CONTAINER_NAME} || echo Contenedor no encontrado"
                bat """
                    docker run -d --name ${CONTAINER_NAME} -p ${APP_PORT}:${APP_PORT} ${IMAGE_NAME}
                """
            }
        }

        stage('OWASP ZAP Security Scan') {
            steps {
                echo "Ejecutando escaneo OWASP ZAP..."
                bat """
                    REM Iniciar ZAP en modo daemon
                    zap.sh -daemon -port 8080 -host 0.0.0.0
                    REM Espera breve para asegurar que ZAP esté listo
                    timeout /t 5
                    REM Ejecuta escaneo rápido sobre la app
                    zap-cli quick-scan http://localhost:${APP_PORT}
                    REM Genera reporte en HTML
                    zap-cli report -o ${ZAP_REPORT} -f html
                """
                archiveArtifacts artifacts: "${ZAP_REPORT}", fingerprint: true
            }
        }

    }

    post {
        always {
            echo "Limpiando contenedores e imagenes..."
            bat "docker rm -f ${CONTAINER_NAME} || echo Contenedor no encontrado"
            bat "docker rmi -f ${IMAGE_NAME} || echo Imagen no encontrada"
        }
        success {
            echo "Pipeline finalizado correctamente."
        }
        failure {
            echo "Pipeline finalizado con fallos. Revisar reportes de seguridad."
        }
    }
}





