// pipeline {
//     agent any

//     environment {
//         IMAGE_NAME = 'gym-website'
//         CONTAINER_NAME = 'gym-container'
//         HOST_PORT = '8080'
//         CONTAINER_PORT = '80'
//     }

//     stages {
//         stage('Clone Repo') {
//             steps {
//                 git branch: 'main', url: 'https://github.com/Harshkumar50/Docker_project.git'
//             }
//         }

//         stage('Check Docker Installation') {
//             steps {
//                 sh 'docker --version || echo "Docker is not installed!"'
//             }
//         }

//         stage('Docker Build') {
//             steps {
//                 sh 'docker build -t $IMAGE_NAME .'
//             }
//         }

//         stage('Deploy Container') {
//             steps {
//                 script {
//                     // Stop and remove existing container if it exists
//                     sh "docker rm -f $CONTAINER_NAME || true"

//                     // Run new container
//                     sh """
//                         docker run -d \
//                         --name $CONTAINER_NAME \
//                         -p $HOST_PORT:$CONTAINER_PORT \
//                         $IMAGE_NAME
//                     """
//                 }
//             }
//         }
//     }

//     post {
//         success {
//             echo "✅ Frontend deployed has been successfully at http://localhost:$HOST_PORT"
//         }
//         failure {
//             echo '❌ Deployment failed. Cleaning up...'
//             sh "docker rm -f $CONTAINER_NAME || true"
//         }
//         cleanup {
//             cleanWs()
//         }
//     }
// }    
pipeline {
    agent any

    environment {
        IMAGE_NAME = 'gym-website'
        CONTAINER_NAME = 'gym-container'
        HOST_PORT = '8080'
        CONTAINER_PORT = '80'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Harshkumar50/Docker_project.git'
            }
        }

        stage('Check Docker Installation') {
            steps {
                sh 'docker --version || echo "Docker is not installed!"'
            }
        }

        stage('Setup Docker Permissions') {
            steps {
                script {
                    // Add Jenkins user to docker group (requires sudo access)
                    sh '''
                        sudo usermod -aG docker jenkins || true
                        sudo systemctl restart docker || true
                    '''
                    // Alternative: Change socket permissions (less secure)
                    sh 'sudo chmod 777 /var/run/docker.sock || true'
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    // Build with explicit permissions
                    sh 'docker build -t $IMAGE_NAME . || echo "Build failed"'
                    
                    // Alternative approach using docker-agent
                    // docker.build("$IMAGE_NAME")
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // Stop and remove existing container if it exists
                    sh "docker rm -f $CONTAINER_NAME || true"

                    // Run new container with retry logic
                    retry(3) {
                        sh """
                            docker run -d \
                            --name $CONTAINER_NAME \
                            -p $HOST_PORT:$CONTAINER_PORT \
                            $IMAGE_NAME
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Frontend deployed successfully at http://localhost:$HOST_PORT"
        }
        failure {
            echo '❌ Deployment failed. Cleaning up...'
            script {
                sh "docker rm -f $CONTAINER_NAME || true"
                sh "docker rmi -f $IMAGE_NAME || true"
            }
        }
        cleanup {
            cleanWs()
        }
    }
}