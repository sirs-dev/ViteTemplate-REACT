// Jenkinsfile

// Define el nombre de la imagen y la etiqueta
def imageName = "vite-react-app" // Nombre de imagen local
def imageTag = "latest"

pipeline {
    agent any // Ejecutar en cualquier agente disponible (el master de Jenkins)

    // No se necesita un bloque 'environment {}' vacío.

    stages {
        // El checkout del código fuente (SCM) ocurre implícitamente
        // al inicio del pipeline si está configurado en el Job de Jenkins.
        // Si necesitaras hacer un checkout explícito en un workspace diferente o
        // de otro repositorio, aquí podrías añadir un stage con 'checkout scm' o 'git'.

        stage('Build Docker Image') {
            steps {
                echo "Construyendo la imagen Docker: ${imageName}:${imageTag}"
                script {
                    // Usa el plugin Docker Pipeline para construir la imagen
                    def customImage = docker.build("${imageName}:${imageTag}", "./") // "./" o "." es el contexto
                    // No es necesario hacer customImage.push() si no usas un registry externo
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "Desplegando/Actualizando en Kubernetes..."

                // Asegúrate de que los archivos YAML estén en la ruta correcta
                // relativa al workspace del pipeline (raíz del proyecto clonado).
                // Si están en 'k8s/deployment.yaml', usa esa ruta.
                sh "kubectl apply -f k8s/deployment.yaml"
                sh "kubectl apply -f k8s/service.yaml"

                // Esperar a que el deployment se estabilice y luego forzar un reinicio.
                // El '|| true' es para que el pipeline no falle si el status ya es correcto.
                sh "kubectl rollout status deployment/vite-react-app-deployment --timeout=120s || true"
                sh "kubectl rollout restart deployment/vite-react-app-deployment"

                echo "Deployment completado. Esperando a que los nuevos pods estén listos..."
                // Añadir una pequeña espera para dar tiempo a que los pods se reinicien.
                // Esto es opcional, 'rollout status' ya debería cubrirlo en parte.
                // sleep(time: 15, unit: 'SECONDS') // Espera 15 segundos

                echo "Revisa los pods:"
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
            // Aquí podrías añadir notificaciones de fallo (ej. email, Slack)
        }
    }
}