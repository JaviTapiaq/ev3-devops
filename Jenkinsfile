// Jenkinsfile
// Integrantes: Javiera Tapia Quintana Rut:
//              Joaquin Diez Gioia Rut:
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'vulnerable_flask_app'
        ZAP_IMAGE = 'owasp/zap2docker-stable:2.16.0'
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
                bat "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Security Audit & Fix') {
            steps {
                echo 'Ejecutando auditoría de seguridad con pip-audit...'
                bat """
                docker run --rm ${DOCKER_IMAGE} pip-audit || echo "Se encontraron vulnerabilidades"
                """
            }
        }

        stage('Run Container') {
            steps {
                echo 'Levantando contenedor...'
                bat "docker run -d --name ${DOCKER_IMAGE}_container -p 5000:5000 ${DOCKER_IMAGE}"
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
                docker pull ${ZAP_IMAGE}
                docker run --rm -v ${WORKSPACE}:/zap/wrk/:rw ${ZAP_IMAGE} zap-baseline.py -t http://host.docker.internal:5000 -r zap_report.html || echo "Escaneo ZAP falló"
                """
            }
            post {
                always {
                    echo 'Archivando reporte OWASP ZAP...'
                    archiveArtifacts artifacts: 'zap_report.html', allowEmptyArchive: true
                }
            }
        }
    }

    post {
        always {
            echo 'Limpiando contenedor si existe...'
            bat "docker rm -f ${DOCKER_IMAGE}_container || echo Contenedor no encontrado"
        }
    }
}





