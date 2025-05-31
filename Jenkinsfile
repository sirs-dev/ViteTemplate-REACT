// Jenkinsfile

def imageName = "vite-react-app"
def imageTag = "latest"

pipeline {
    agent any

    stages {
        // El checkout del código fuente (SCM) ocurre implícitamente

        stage('Build Docker Image DEBUG') { // <--- NOMBRE DEL STAGE CAMBIADO PARA DEPURAR
            steps {
                echo "DEBUG: Iniciando stage de construcción de imagen."
                script {
                    try {
                        echo "DEBUG: Intentando verificar la versión de Docker a través del plugin..."
                        // Intenta un comando Docker simple a través del plugin para ver si el plugin está activo
                        docker.image('alpine').pull() // Intenta jalar una imagen pequeña
                        echo "DEBUG: docker.image('alpine').pull() funcionó."

                        echo "DEBUG: Ahora intentando docker.build("${imageName}:${imageTag}", "./")"
                        // El segundo argumento de docker.build puede incluir argumentos adicionales para el comando docker build
                        // Por ejemplo, si tu Dockerfile está en otro lugar o tiene un nombre diferente:
                        // def myImage = docker.build("${imageName}:${imageTag}", "-f path/to/MyDockerfile ./app_context")
                        def myImage = docker.build("${imageName}:${imageTag}", "--pull=true -f Dockerfile ./") // Asegura pull de base, usa Dockerfile en contexto actual
                        echo "DEBUG: docker.build parece haber funcionado. ID de imagen: ${myImage.id}"

                    } catch (e) {
                        echo "DEBUG: ERROR en el bloque script/try: ${e.toString()}"
                        // No uses currentBuild.result = 'FAILURE' aquí directamente, 'error' ya lo hace.
                        error "Fallo en el stage de construcción de imagen: ${e.getMessage()}"
                    }
                }
                echo "DEBUG: Finalizando stage de construcción de imagen."
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "Desplegando/Actualizando en Kubernetes..."
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