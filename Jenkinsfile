#!/bin/env groovy
// This is a Jenkins pipeline file. It will be picked up by Jenkins and contains
// instructions this project should be built and tested.

pipeline {
    agent {
        node {
            label 'openembedded'
            customWorkspace 'topic-platform-zeus'
        }
    }

    stages {
        stage('Build') {
            steps {
                checkout scm
                sh 'scripts/autobuild.sh'
            }
        }

        stage('Publish artifacts') {
            steps {
                archiveArtifacts artifacts: 'build/artefacts/*', onlyIfSuccessful: true
            }
        }
    }
}
