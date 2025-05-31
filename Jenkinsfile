// Jenkinsfile

def imageName = "vite-react-app"
def imageTag = "latest"

pipeline {
    agent any

    tools {
        nodejs 'node24'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                echo 'Código fuente clonado.'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Instalando dependencias y ejecutando pruebas...'
                sh 'node -v' // Verifica la versión de Node
                sh 'npm -v'  // Verifica la versión de npm
                sh 'npm ci'
                sh 'npm test'
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo 'Ejecutando pruebas unitarias...'
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Construyendo la imagen Docker: ${imageName}:${imageTag}"
                script { // Necesario para usar variables y lógica de Groovy con los pasos de Docker
                    // Utiliza el paso 'docker.build()' del plugin Docker Pipeline
                    def customImage = docker.build("${imageName}:${imageTag}", "--pull --no-cache .")
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "Desplegando/Actualizando en Kubernetes..."
                sh 'kubectl version --client'
                sh "kubectl apply -f k8s/deployment.yaml"
                sh "kubectl apply -f k8s/service.yaml"
                sh "kubectl rollout status deployment/vite-react-app-deployment --timeout=120s || true"
                sh "kubectl rollout restart deployment/vite-react-app-deployment"
                echo "Deployment completado. Revisa los pods:"
                sh "kubectl get pods -l app=vite-react-app"
            }
        }
    }

    post {
        always {
            echo 'Pipeline finalizado.'
        }
        success {
            echo 'Pipeline ejecutado con éxito!'
        }
        failure {
            echo 'Pipeline falló!'
        }
    }
}