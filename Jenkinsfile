pipeline {
  agent {
    docker {
      image 'dockter-tom'
      args '-p 3000:3000'
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