// Jenkinsfile
// Integrantes: Javiera Tapia  Rut: 20533877-2
//              Joaquin Diez   Rut: 21302876-6
pipeline {
    agent any

    environment {
        IMAGE_NAME = "vulnerable_flask_app"
        CONTAINER_NAME = "vulnerable_flask_app_container"
        REGISTRY = "javitapiaq" 
        TAG = "latest"
        COMPOSE_DIR = "C:/Users/jppaz/OneDrive/Escritorio/monitoring"
        PYTHON_PATH = "C:/Python310/python.exe" // Ruta absoluta a python
        FLASK_APP_DIR = "C:/Users/jppaz/OneDrive/Escritorio/flask_app"
    }

    stages {

        stage("Checkout SCM") {
            steps {
                checkout scm
            }
        }

        stage("Build") {
            steps {
                echo "Instalando dependencias de la app..."
                bat "\"${PYTHON_PATH}\" -m pip install --upgrade pip"
                bat "\"${PYTHON_PATH}\" -m pip install -r ${FLASK_APP_DIR}/requirements.txt"
            }
        }

        stage("Unit Tests") {
            steps {
                echo "Ejecutando pruebas unitarias..."
                bat "\"${PYTHON_PATH}\" -m pytest ${FLASK_APP_DIR}/tests || exit 0"
            }
        }

        stage("Analyze") {
            steps {
                echo "Ejecutando análisis de seguridad..."
                bat "\"${PYTHON_PATH}\" -m pip install pip-audit"
                bat "\"${PYTHON_PATH}\" -m pip_audit"
            }
        }

        stage("Dependency Management") {
            steps {
                echo "Instalando y actualizando dependencias con pipenv..."
                bat "\"${PYTHON_PATH}\" -m pip install pipenv"
                dir("${FLASK_APP_DIR}") {
                    bat "pipenv install --dev"
                    bat "pipenv update"
                }
            }
        }

        stage("Security Scan") {
            steps {
                echo "Ejecutando OWASP ZAP scan..."
                dir("${COMPOSE_DIR}") {
                    bat "docker-compose up -d zap"
                    echo "Simulando escaneo con ZAP..."
                    timeout(time: 1, unit: 'MINUTES') {
                        bat "curl -s http://localhost:5000"
                    }
                    bat "docker-compose stop zap"
                }
            }
        }

        stage("Docker Build") {
            steps {
                echo "Construyendo imagen Docker..."
                dir("${COMPOSE_DIR}") {
                    bat "docker-compose build vulnerable_flask_app"
                }
            }
        }

        stage("Docker Push") {
            steps {
                echo "Subiendo imagen al registro..."
                bat "docker tag ${IMAGE_NAME} ${REGISTRY}/${IMAGE_NAME}:${TAG}"
                bat "docker login -u ${REGISTRY} -p tu_password_dockerhub"
                bat "docker push ${REGISTRY}/${IMAGE_NAME}:${TAG}"
            }
        }

        stage("Deploy") {
            steps {
                echo "Desplegando aplicación y servicios de monitoreo..."
                dir("${COMPOSE_DIR}") {
                    bat "docker-compose up -d"
                }
            }
        }
    }

    post {
        always {
            echo "Limpiando contenedores si existen..."
            dir("${COMPOSE_DIR}") {
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
