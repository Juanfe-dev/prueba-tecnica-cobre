pipeline {

    agent any

    triggers {
            githubPush()
    }

    stages {

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