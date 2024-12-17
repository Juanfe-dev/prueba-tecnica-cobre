pipeline {
    agent { label 'master' }
    stages {
        stage ('test') {
            steps {
                dir("prueba-tecnica-cobre"){
                    sh "mvn clean test -Dtest=GeneralRunner -Dtest-suite=acceptance -DwithTags='acceptance'"
                }
            }
        }
        stage ('Build application') {
            steps {
                echo 'mvn clean install -Dmaven.test.skip=true'
            }
        }
        stage ('Create docker image') {
            steps {
                echo 'creando docker'
            }
        }
    }
}