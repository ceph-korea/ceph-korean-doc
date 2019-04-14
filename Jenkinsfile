pipeline {
    agent any

    stages {
        stage('Install Dependencies') {
            steps {
                echo 'Installing Dependencies...'
                sh 'git submodule update --init'
            }
        }
        stage('Build') {
            steps {
                echo 'Building...'
                sh './build.sh'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                sh 'yes | cp -rf ./ceph/build-doc/output/html/* /usr/share/nginx/html/'
            }
        }
        stage('Reload nginx') {
            steps {
                echo 'Restarting nginx...'
                sh 'systemctl reload nginx'
            }
        }
    }
}
