pipeline {
  agent {
    docker {
      image 'dockter-tom'
    }
    
  }
  stages {
    stage('Build') {
      steps {
        sh 'build-dockter-tom.sh'
      }
    }
  }
}