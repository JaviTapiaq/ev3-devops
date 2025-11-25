// Jenkinsfile
// Integrantes: Javiera Tapia Quintana Rut:
//              Joaquin Diez Gioia Rut:
pipeline {
    agent any

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t vulnerable_flask_app .'
            }
        }

        stage('Security Audit') {
            steps {
                script {
                    echo "Ejecutando auditoría de seguridad con pip-audit..."
                    // Ejecuta pip-audit directamente sobre la imagen y elimina el contenedor después
                    bat 'docker run --rm vulnerable_flask_app pip install pip-audit && docker run --rm vulnerable_flask_app pip-audit'
                }
            }
        }

        stage('Run Container') {
            steps {
                bat 'docker run -d -p 5000:5000 --name vulnerable_flask_app vulnerable_flask_app'
            }
        }

        stage('Smoke Tests') {
            steps {
                script {
                    bat """
                    @echo off
                    setlocal enabledelayedexpansion
                    set URL=http://host.docker.internal:5000/
                    set RETRIES=10

                    for /L %%i in (1,1,!RETRIES!) do (
                        curl !URL! -s -o NUL
                        if !errorlevel! == 0 (
                            echo Flask container is ready
                            exit /b 0
                        )
                        echo Waiting for Flask... retry %%i
                        timeout /t 2 >nul
                    )
                    echo Flask container did not start in time
                    exit /b 1
                    """
                }
            }
        }
    }

    post {
        always {
            bat 'docker rm -f vulnerable_flask_app || echo Container not found'
        }
    }
}


