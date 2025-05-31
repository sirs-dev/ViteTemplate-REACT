// Jenkinsfile

def imageName = "vite-react-app"
def imageTag = "latest"

pipeline {
    agent any // Ejecuta en el nodo maestro de Jenkins donde está montado el docker.sock

    stages {
        stage('Checkout Code') {
            steps {
                // El checkout implícito es suficiente, o puedes mantener tu 'checkout scm' si lo prefieres
                // Para simplificar, podemos confiar en el checkout implícito que Jenkins hace
                // al inicio de un pipeline definido desde SCM.
                // Si quieres ser explícito:
                // checkout scm
                echo 'Código fuente clonado.'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Instalando dependencias del proyecto...'
                // Si tu Dockerfile ya hace 'npm ci', este paso podría ser redundante
                // para el build de la imagen, pero es bueno para ejecutar tests primero.
                // Si solo es para el build, y tu Dockerfile lo maneja, puedes omitir este sh.
                sh 'npm ci'
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
                    // O simplemente:
                    // def customImage = docker.build("${imageName}:${imageTag}", ".")

                    // Opcional: Puedes verificar si la imagen se construyó
                    // if (customImage) {
                    //    echo "Imagen Docker ${customImage.id} construida con éxito."
                    // } else {
                    //    error "La construcción de la imagen Docker falló."
                    // }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "Desplegando/Actualizando en Kubernetes..."
                // Asegúrate de que k8s/deployment.yaml y k8s/service.yaml existan en tu workspace
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