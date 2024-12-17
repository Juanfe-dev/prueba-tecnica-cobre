pipeline {
    agent any

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Juanfe-dev/prueba-tecnica-cobre.git'
            }
        }

        stage('Install dependencies') {
            steps {
                bat 'mvn clean install -DskipTests'
            }
        }

        stage('Run Tests') {
            steps {
                bat 'mvn clean test -Dtest=GeneralRunner -Dtest-suite=acceptance -DwithTags=EditCSV'
            }
        }

       stage('Publish Cucumber Reports') {
           steps {
               cucumber buildStatus: 'UNSTABLE', jsonReportDirectory: 'target/cucumber-html-reports'
           }
       }
    }
}