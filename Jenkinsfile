#!/bin/env groovy
// This is a Jenkins pipeline file. It will be picked up by Jenkins and contains
// instructions this project should be built and tested.

pipeline {
    agent {
        node {
            label 'openembedded'
            customWorkspace 'topic-platform-honister'
        }
    }

    stages {
        stage('Build') {
            steps {
                sh 'scripts/autobuild.sh'
            }
        }

        stage('Publish artifacts') {
              when { branch 'master' } // Only run this step on the master branch
              steps {
                archiveArtifacts artifacts: 'build/artefacts/*', onlyIfSuccessful: true
            }
        }

        stage('Push github') {
              when { branch 'master' } // Only run this step on the master branch
              steps {
                sh '''
                    git push git@github.com:topic-embedded-products/topic-platform.git HEAD:refs/heads/master
                    git push git@github.com:topic-embedded-products/topic-platform.git HEAD:refs/heads/zeus
                '''
            }
        }

        stage('Update downloads') {
            when { branch 'release' }
            steps {
                sh 'scripts/release-downloads.sh'
            }
        }
    }
}
