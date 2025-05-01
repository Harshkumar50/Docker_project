pipeline {
    agent any

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/Harshkumar50/Docker_project'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('gym-website')
                }
            }
        }

        stage('Run with Docker Compose') {
            steps {
                sh 'docker-compose up -d'
            }
        }

        stage('Post-Build Verification') {
            steps {
                sh 'curl -I http://localhost:8080'
            }
        }
    }
}
