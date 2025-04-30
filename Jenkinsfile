pipeline {
    agent any

    environment {
        IMAGE_NAME = 'gym-website'
        CONTAINER_NAME = 'gym-container'
        HOST_PORT = '8080'
        CONTAINER_PORT = '80'
        DOCKER_HOST = 'unix:///var/run/docker.sock'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Harshkumar50/Docker_project.git'
            }
        }

        stage('Check Docker Environment') {
            steps {
                script {
                    // Check Docker installation
                    def dockerVersion = sh(script: 'docker --version', returnStatus: true)
                    if (dockerVersion != 0) {
                        error 'Docker is not properly installed!'
                    }

                    // Check Docker socket permissions
                    def dockerAccess = sh(script: 'docker ps', returnStatus: true)
                    if (dockerAccess != 0) {
                        echo 'Warning: Jenkins user may not have Docker permissions'
                        echo 'Temporary workaround: Adjusting socket permissions (not recommended for production)'
                        sh 'sudo chmod 777 /var/run/docker.sock || true'
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    // Build with error handling
                    try {
                        sh "docker build -t ${IMAGE_NAME} ."
                    } catch (Exception e) {
                        echo "Build failed: ${e.getMessage()}"
                        error 'Docker build failed'
                    }
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // Clean up any existing container
                    sh "docker rm -f ${CONTAINER_NAME} || true"
                    
                    // Run container with health check
                    sh """
                        docker run -d \
                            --name ${CONTAINER_NAME} \
                            -p ${HOST_PORT}:${CONTAINER_PORT} \
                            --health-cmd "curl -f http://localhost:${CONTAINER_PORT} || exit 1" \
                            --health-interval=5s \
                            --health-retries=3 \
                            ${IMAGE_NAME}
                    """
                    
                    // Verify container is running
                    def containerStatus = sh(
                        script: "docker inspect -f '{{.State.Status}}' ${CONTAINER_NAME}",
                        returnStdout: true
                    ).trim()
                    
                    if (containerStatus != "running") {
                        error "Container failed to start. Status: ${containerStatus}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful! Access your application at:"
            echo "http://localhost:${HOST_PORT}"
            echo "Or if running remotely:"
            echo "http://${env.JENKINS_URL}:${HOST_PORT}"
        }
        failure {
            echo '❌ Deployment failed. Performing cleanup...'
            script {
                sh "docker rm -f ${CONTAINER_NAME} || true"
                sh "docker rmi ${IMAGE_NAME} || true"
                // Additional cleanup if needed
            }
        }
        cleanup {
            cleanWs()
        }
    }
}