pipeline {
    agent any

    environment {
        IMAGE_NAME = 'gym-website'
        CONTAINER_NAME = 'gym-container'
        HOST_PORT = '8080'
        CONTAINER_PORT = '80'
    }

    stages {
        stage('Check Docker Access') {
            steps {
                script {
                    // Verify Docker access
                    def hasDockerAccess = sh(
                        script: 'docker ps >/dev/null 2>&1',
                        returnStatus: true
                    ) == 0
                    
                    if (!hasDockerAccess) {
                        echo "WARNING: No Docker access - trying to fix permissions"
                        // Try to fix permissions (works only if container runs as root)
                        sh '''
                            chmod 777 /var/run/docker.sock || \
                            echo "Could not modify Docker socket permissions"
                        '''
                        // Verify again
                        hasDockerAccess = sh(
                            script: 'docker ps >/dev/null 2>&1',
                            returnStatus: true
                        ) == 0
                        if (!hasDockerAccess) {
                            error 'CRITICAL: Jenkins has no Docker access. Aborting.'
                        }
                    }
                }
            }
        }

        stage('Build and Deploy') {
            when {
                expression { env.DOCKER_ACCESS == 'true' }
            }
            steps {
                script {
                    // Build with error handling
                    try {
                        sh "docker build -t ${IMAGE_NAME} ."
                        sh "docker rm -f ${CONTAINER_NAME} || true"
                        sh """
                            docker run -d \
                                --name ${CONTAINER_NAME} \
                                -p ${HOST_PORT}:${CONTAINER_PORT} \
                                ${IMAGE_NAME}
                        """
                    } catch (Exception e) {
                        error "Deployment failed: ${e.getMessage()}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up workspace"
            cleanWs()
        }
    }
}