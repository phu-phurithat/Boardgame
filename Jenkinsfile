pipeline {
    agent any

    tools {
        jdk 'jdk17'
        maven 'maven3'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {
        stage('Git Checkout') {
            steps {
                checkoutSource repo: 'https://github.com/orgA/service-a.git'
            }
        }
        stage('Compile') {
            steps {
                sh 'maven compile'
            }
        }
        stage('Test') {
            steps {
                sh 'maven test'
            }
        }
        stage('File System Scan') {
            steps {
                sh 'trivy fs --format table -o trivy-fs-report.html .'
            }
        }
        stage('Sonarqube Analysis') {
            steps {
                withSonarQubeEnv(credentialsId: 'sonar') {
                    sh '''
                        $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Boardgame -Dsonar.projectKey=Boardgame \
                            -Dsonar.java.binaries=.
                    '''
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }
        stage('Build') {
            steps {
                sh 'maven package'
            }
        }
        stage('Publish To Nexus') {
            steps {
                sh 'maven test'
            }
        }
        stage('Push Docker Image') {
            script {
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                    sh 'docker push phuphurithat/boardgame'
                }
            }
        }
        stage('Deploy To Kubernetes') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'k8-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://10.128.0.5:6443') {
                    sh 'kubectl apply -f deployment-service.yaml -n webapps'
                }
            }
        }
        stage('Verify The Deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'k8-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://10.128.0.5:6443') {
                    sh 'kubectl get pods -n webapps'
                    sh 'kubectl get svc -n webapps'
                }
            }
        }
    }
    post {
        always {
            script {
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
                def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'

                def body = """
                    <html>
                    <body>
                    <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                    <h2>${jobName} - Build ${buildNumber}</h2>
                    <div style="background-color: ${bannerColor}; padding: 10px;">
                    <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                    </div>
                    <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                    </div>
                    </body>
                    </html>
                """

                emailext(
                    subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                    body: body,
                    to: 'pooh34213@gmail.com',
                    from: 'jenkins@example.com',
                    replyTo: 'jenkins@example.com',
                    mimeType: 'text/html',
                    attachmentsPattern: 'trivy-image-report.html'
                )
            }
        }
    }
}

