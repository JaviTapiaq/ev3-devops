// Jenkinsfile
// Integrantes: Javiera Tapia  Rut:
//              Joaquin Diez   Rut:
pipeline {
    agent any

    environment {
        APP_IMAGE = "vulnerable_flask_app"
        APP_CONTAINER = "vulnerable_flask_app_container"
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
                bat "docker build -t %APP_IMAGE% ."
                bat "docker run --rm %APP_IMAGE% python create_db.py"
            }
        }

        stage('Security Audit (pip-audit)') {
            steps {
                echo "Ejecutando pip-audit..."
                script {
                    bat "docker run --rm %APP_IMAGE% pip-audit -f json 1>pip_audit_report.json || echo 'pip-audit detectó vulnerabilidades'"
                    bat "docker run --rm %APP_IMAGE% pip-audit 1>pip_audit_report.txt || echo 'pip-audit detectó vulnerabilidades'"
                    echo "Se encontraron vulnerabilidades, revisa los reportes."
                }
                archiveArtifacts artifacts: 'pip_audit_report.*', allowEmptyArchive: true
            }
        }

        stage('Run Application Container') {
            steps {
                echo "Ejecutando contenedor de la aplicación..."
                bat "docker run -d --name %APP_CONTAINER% -p 5000:5000 %APP_IMAGE%"
            }
        }

        stage('OWASP ZAP Security Scan') {
            steps {
                echo "Ejecutando OWASP ZAP Scan..."
                script {
                    bat """
                    docker pull owasp/zap2docker-stable
                    docker run --rm -t -v %CD%:/zap/wrk/:rw owasp/zap2docker-stable zap-baseline.py -t http://host.docker.internal:5000 -r owasp_zap_report.html || echo 'ZAP scan finalizado con posibles alertas'
                    """
                }
                archiveArtifacts artifacts: 'owasp_zap_report.html', allowEmptyArchive: true
            }
        }
    }

    post {
        always {
            echo "Limpiando contenedores e imágenes..."
            bat "docker rm -f %APP_CONTAINER% || echo Contenedor no encontrado"
            bat "docker rmi -f %APP_IMAGE% || echo Imagen no encontrada"
        }
    }
}
