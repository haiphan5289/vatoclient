node {
    stage('Checkout') {
        checkout([$class: 'GitSCM', branches: [[name: '*/$branch']], 
            doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], 
            userRemoteConfigs: [[credentialsId:'/$githubToken' , url: 'https://github.com/vatoio/client-ios']]])
    }
    stage('Environment/Bundles Setup') {
        sh "pod install --repo-update"
    }
    stage('Clean') {
        sh 'fastlane clean_xcode'
    }
    stage('Code Sign') {
        sh 'fastlane codesign method:"adhoc"'
    }
    stage('Create Build') {   
        sh 'fastlane create_build'
    }
}