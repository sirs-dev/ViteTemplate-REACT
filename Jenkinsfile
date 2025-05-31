// Jenkinsfile

// Define el nombre de la imagen y la etiqueta
def imageName = "vite-react-app" 
def imageTag = "latest"
// Si en el futuro usas Docker Hub, sería:
// def imageName = "TU_USUARIO_DOCKERHUB/vite-react-app"

pipeline {
    agent any // Ejecutar en cualquier agente disponible (en este caso, el master de Jenkins)

    environment {
        // Si usaras Docker Hub, aquí definirías el ID de la credencial
        // DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Clonando el repositorio...'
                checkout scm // Clona el repositorio configurado en el job de Jenkins
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Construyendo la imagen Docker: ${imageName}:${imageTag}"
                // Usamos sh porque estamos montando el docker.sock,
                // lo que permite al Jenkins ejecutar comandos docker directamente en el host.
                // El Dockerfile multi-etapa se encargará de la construcción de Node y Nginx.
                sh "docker build -t ${imageName}:${imageTag} ."
            }
        }

        // Opcional: Stage para subir a Docker Hub (comentado por ahora)
        /*
        stage('Push Docker Image') {
            when { expression { return env.DOCKER_CREDENTIALS_ID != null && env.DOCKER_CREDENTIALS_ID != "" } }
            steps {
                echo "Subiendo la imagen Docker: ${imageName}:${imageTag} a Docker Hub..."
                script {
                    docker.withRegistry('https://registry.hub.docker.com', DOCKER_CREDENTIALS_ID) {
                        docker.image("${imageName}:${imageTag}").push()
                    }
                }
            }
        }
        */

        stage('Deploy to Kubernetes') {
            steps {
                echo "Desplegando/Actualizando en Kubernetes..."
                // Asegúrate de que kubectl está en el PATH del agente Jenkins
                // o que el plugin Kubernetes CLI está configurado y se usa correctamente.
                // Como estamos usando Docker Desktop, Jenkins (corriendo en Docker)
                // necesitará acceso a la configuración de kubectl del host o tener kubectl instalado y configurado.

                // Para que Jenkins use el kubectl del host (Docker Desktop):
                // Una opción es montar el .kube/config dentro del contenedor Jenkins,
                // o ejecutar kubectl desde un script que lo configure.
                // Dado que montamos docker.sock, Jenkins está actuando como un cliente Docker en el host.
                // El kubectl también debe actuar como un cliente en el host.
                // El plugin 'Kubernetes CLI' ayuda a gestionar esto.

                // Si los archivos YAML están en una subcarpeta k8s/, ajusta la ruta.
                // Ejemplo: sh "kubectl apply -f k8s/deployment.yaml"
                sh "kubectl apply -f k8s/deployment.yaml"
                sh "kubectl apply -f k8s/service.yaml"

                // Forzar un reinicio de los pods del deployment para que tomen la nueva imagen :latest
                // Esto es importante si imagePullPolicy es IfNotPresent y solo actualizas el tag 'latest'.
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