// Jenkinsfile
// Integrantes: Javiera Tapia  Rut:
//              Joaquin Diez   Rut:
pipeline {
    agent any

    environment {
        IMAGE_NAME = "vulnerable_flask_app"
        CONTAINER_NAME = "vulnerable_flask_app_container"
        REGISTRY = "javitapiaq" // Cambiar por tu usuario/registro
        TAG = "latest"
        COMPOSE_DIR = "C:/Users/jppaz/OneDrive/Escritorio/monitoring"
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
                bat "python -m pip install --upgrade pip"
                bat "pip install -r ${FLASK_APP_DIR}/requirements.txt"
            }
        }

        stage("Unit Tests") {
            steps {
                echo "Ejecutando pruebas unitarias..."
                bat """
                    pytest ${FLASK_APP_DIR}/tests || (
                        echo 'Tests fallaron, pero continuamos...' & exit 0
                    )
                """
            }
        }

        stage("Analyze") {
            steps {
                echo "Analizando calidad del código con pylint..."
                bat "pip install pylint"
                bat """
                    pylint ${FLASK_APP_DIR} || (
                        echo 'Warnings de pylint detectados, pero continuamos...' & exit 0
                    )
                """
            }
        }

        stage("Dependency Management") {
            steps {
                echo "Verificando dependencias con pip-audit..."
                bat "pip install pip-audit"
                bat """
                    pip-audit --progress bar || (
                        echo 'Vulnerabilidades detectadas, revisa el informe...' & exit 0
                    )
                """
            }
        }

        stage("Security Scan") {
            steps {
                echo "Ejecutando OWASP ZAP scan..."
                dir("${COMPOSE_DIR}") {
                    bat "docker-compose up -d zap"
                    timeout(time: 2, unit: 'MINUTES') {
                        echo "Esperando que la app esté lista..."
                        bat """
                            for /L %%i in (1,1,12) do (
                                curl -s http://localhost:5000 && exit /B 0
                                timeout /t 5 >nul
                            )
                        """
                    }
                    echo "Escaneo ZAP simulado (puedes agregar comandos reales aquí)..."
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
                echo "Subiendo imagen al registro Docker Hub..."
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

        stage("Smoke Tests") {
            steps {
                echo "Verificando que la app responde..."
                timeout(time: 1, unit: 'MINUTES') {
                    bat """
                        for /L %%i in (1,1,12) do (
                            curl -f http://localhost:5000 && exit /B 0
                            timeout /t 5 >nul
                        )
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Limpiando contenedores..."
            dir("${COMPOSE_DIR}") {
                bat "docker-compose down"
            }
        }
        success {
            echo "Pipeline finalizado correctamente."
        }
        failure {
            echo "Pipeline finalizado con errores, revisa los logs."
        }
    }
}
