def getEnvFromBranch(branch) {
  if (branch == 'main') {
    return 'some-address-ip'
  } else if (branch == 'test'){
    return 'another-address-ip'
  } else {
    return 'default-address-ip'
 }
}
def choosed_agent = getEnvFromBranch(env.BRANCH_NAME)

pipeline {
    agent {
        label "${choosed_agent}"
    }
	options {
      gitLabConnection('gitlab')
      gitlabBuilds(builds: ['Build', 'Test', 'Deploy'])
    }
    stages {
        stage('Build') {
            steps {
                // Get some code from a GitLab repository
                updateGitlabCommitStatus name: 'Build', state: 'pending'
				sh '''
                    . /home/ubuntu/virtual_environments/venv_importItem/bin/activate
                    pip install -r requirements.txt
                '''
                updateGitlabCommitStatus name: 'Build', state: 'success'
            }
        }
		stage('Test') {
            steps {
                echo "This is test stage"
            }
			post {
				failure {
					echo "[INFO] Unit Tests failed or code coverage is not 100%"
                    archiveArtifacts artifacts: 'coverage.json'
                    updateGitlabCommitStatus name: 'Test', state: 'failed'
				}
                success {
					echo "Success"
				}
			}
        }
		stage('Deploy') {
            when { 
                anyOf { 
                    branch 'main'; 
                    branch 'test' 
                } 
            }
            steps {
                updateGitlabCommitStatus name: 'Deploy', state: 'pending'
                sh 'sudo systemctl stop itemImport.service'
                sh 'sudo rm -rf /opt/importItem/'
                sh 'sudo mkdir /opt/importItem'
                sh 'sudo mv * /opt/importItem'                
                sh 'sudo cp /home/ubuntu/.config/importItem/* /opt/importItem/config'
				sh 'sudo chmod +x /opt/importItem/run_importItem.sh'
                sh 'sudo systemctl start itemImport.service'
                echo 'New version installed'
                updateGitlabCommitStatus name: 'Deploy', state: 'success'
            }
        }
        stage('Deploy - dev') {
            when { 
                not { 
                    anyOf { 
                        branch 'main'; 
                        branch 'test' 
                    } 
                } 
            }
            steps {
                updateGitlabCommitStatus name: 'Deploy', state: 'pending'
                echo 'Inform GitLab pipeline about status of dev build'
                updateGitlabCommitStatus name: 'Deploy', state: 'success'
            }
        }
    }
	post {
        always {
            cleanWs deleteDirs: true, notFailBuild: true
        }
		failure{			
			emailext body: "Job Failed<br>URL: ${env.BUILD_URL}", 
                    recipientProviders: [[$class: 'DevelopersRecipientProvider']],
					subject: "Job: ${env.JOB_NAME}, Build: #${env.BUILD_NUMBER} - Failure !",
					attachLog: true
        }
        success{			
			emailext body: "Job builded<br>URL: ${env.BUILD_URL}", 
                    recipientProviders: [[$class: 'DevelopersRecipientProvider']],
					subject: "Job: ${env.JOB_NAME}, Build: #${env.BUILD_NUMBER} - Success !",
					attachLog: true
        }
    }
}
