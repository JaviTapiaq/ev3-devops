// Jenkinsfile
// Integrantes: Javiera Tapia  Rut:
//              Joaquin Diez   Rut:
pipeline {
    agent any

    environment {
        IMAGE_NAME = "vulnerable_flask_app"
        COMPOSE_DIR = "C:\Users\jppaz\OneDrive\Escritorio\monitoring"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build & Up Docker Compose') {
            steps {
                dir("${COMPOSE_DIR}") {
                    echo "Construyendo imagen de la app y levantando servicios con docker-compose..."
                    bat "docker-compose build ${IMAGE_NAME}"
                    bat "docker-compose up -d"
                    echo "Esperando a que la app esté lista..."
                    bat "timeout /t 5"
                }
            }
        }

        stage('Security Audit & Fix') {
            steps {
                dir("${COMPOSE_DIR}") {
                    echo "Ejecutando pip-audit en la app..."
                    script {
                        def auditResult = bat(script: "docker-compose run --rm ${IMAGE_NAME} pip-audit", returnStatus: true)
                        if (auditResult != 0) {
                            echo "Vulnerabilidades encontradas, actualizando pip..."
                            bat "docker-compose run --rm ${IMAGE_NAME} python -m pip install --upgrade pip"
                            echo "Reconstruyendo imagen de la app..."
                            bat "docker-compose build ${IMAGE_NAME}"
                            bat "docker-compose up -d ${IMAGE_NAME}"
                        } else {
                            echo "No se encontraron vulnerabilidades."
                        }
                    }
                }
            }
        }

        stage('OWASP ZAP Security Scan') {
            steps {
                dir("${COMPOSE_DIR}") {
                    echo "Ejecutando escaneo OWASP ZAP..."
                    bat """
                    docker-compose run --rm zap \
                    zap-baseline.py -t http://${IMAGE_NAME}:5000 -r zap_report.html
                    """
                    echo "Escaneo completado. Reporte generado en zap_report.html"
                }
            }
        }

        stage('Smoke Tests') {
            steps {
                dir("${COMPOSE_DIR}") {
                    echo "Ejecutando pruebas básicas (Smoke Tests)..."
                    bat "curl -f http://${IMAGE_NAME}:5000 || (echo 'Smoke Test falló' & exit 1)"
                }
            }
        }

        stage('Monitoring Check') {
            steps {
                dir("${COMPOSE_DIR}") {
                    echo "Verificando que Prometheus y Grafana estén levantados..."
                    bat "curl -f http://localhost:9090 || echo 'Prometheus no disponible'"
                    bat "curl -f http://localhost:3000 || echo 'Grafana no disponible'"
                }
            }
        }
    }

    post {
        always {
            dir("${COMPOSE_DIR}") {
                echo "Deteniendo y limpiando todos los contenedores..."
                bat "docker-compose down"
            }
        }
        success {
            echo "Pipeline finalizado correctamente."
        }
        failure {
            echo "Pipeline finalizado con errores."
        }
    }
}
