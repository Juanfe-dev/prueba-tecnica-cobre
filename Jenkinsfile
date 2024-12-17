pipeline {

    agent any
     tools {
            jdk 'JDK-11.0.23'
            maven 'apache-maven-3.9.9'
        }
    triggers {
            githubPush()
    }

    stages {

         stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/Juanfe-dev/prueba-tecnica-cobre.git'
            }
        }

        stage('Maven build') {
            steps {
                sh "mvn clean install -DskipTests"
            }
        }

        stage('test') {
            steps {
                script {
                    sh "mvn clean test -Dtest=GeneralRunner -Dtest-suite=acceptance -DwithTags=EditCSV"
                }
            }
        }

        stage('generate reports') {
            steps {
                cucumber buildStatus: "UNSTABLE",
                fileIncludePattern: "**/*.html",
                jsonReportDirectory: "target/cucumber-html-reports"
            }
        }
    }

}