// Jenkinsfile
// Integrantes: Javiera Tapia  Rut:
//              Joaquin Diez   Rut:
pipeline {
    agent any

    environment {
        IMAGE_NAME = "vulnerable_flask_app"
        CONTAINER_NAME = "vulnerable_flask_app_container"
        PIP_AUDIT_JSON = "pip_audit_report.json"
        PIP_AUDIT_TXT  = "pip_audit_report.txt"
        ZAP_REPORT_HTML = "owasp_zap_report.html"
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
                script {
                    // Ejecuta pip-audit sin detener el pipeline si encuentra vulnerabilidades
                    def statusJson = bat(script: "docker run --rm ${IMAGE_NAME} pip-audit -f json > ${PIP_AUDIT_JSON}", returnStatus: true)
                    def statusTxt  = bat(script: "docker run --rm ${IMAGE_NAME} pip-audit > ${PIP_AUDIT_TXT}", returnStatus: true)

                    if (statusJson != 0 || statusTxt != 0) {
                        echo "Se encontraron vulnerabilidades, revisa los reportes."
                    }
                }
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
                bat """






