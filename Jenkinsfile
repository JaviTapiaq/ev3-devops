// Jenkinsfile
// Integrantes: Javiera Tapia  Rut:
//              Joaquin Diez   Rut:
pipeline {
    agent any

    environment {
        COMPOSE_DIR = "C:/Users/jppaz/OneDrive/Escritorio/monitoring"
        APP_SERVICE = "vulnerable_flask_app"
        CONTAINER_NAME = "vulnerable_flask_app_container"
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
                    bat """
                    docker-compose build ${APP_SERVICE}
                    docker-compose up -d
                    """
                }
            }
        }

        stage('Security Audit & Fix') {
            steps {
                dir("${COMPOSE_DIR}") {
                    echo "Ejecutando auditoría de seguridad con pip-audit..."
                    script {
                        // Ejecuta pip-audit en el contenedor de la app Flask
                        def auditResult = bat(script: "docker-compose run --rm ${APP_SERVICE} pip-audit", returnStatus: true)
                        
                        if (auditResult != 0) {
                            echo "Vulnerabilidades encontradas, aplicando corrección..."
                            bat "docker-compose run --rm ${APP_SERVICE} python -m pip install --upgrade pip"
                            echo "Rebuild de la app con pip actualizado..."
                            bat "docker-compose build ${APP_SERVICE}"
                            bat "docker-compose up -d"
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
                    echo "Ejecutando OWASP ZAP..."
                    // Escaneo de la app en http://localhost:5000
                    bat "docker-compose run --rm zap zap-baseline.py -t http://host.docker.internal:5000 -r zap_report.html"
                }
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

        stage('Monitoring Check') {
            steps {
                echo "Verificando que Prometheus y Grafana estén corriendo..."
                bat """
                curl -f http://localhost:9090 || echo "Prometheus no responde"
                curl -f http://localhost:3000 || echo "Grafana no responde"
                """
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

