pipeline {
    agent any
    options {
        skipDefaultCheckout(true)
    }

    stages {
        stage('clone git repository') {
            steps {
                script {
                    scmVars  = checkout scm
                }
            }
        }

        stage('set env') {
            steps {
                script {
                    DOCKER_IMG_NAME ='cmf-mockup-api'
                    CONTAINER_PORT  ='3000'
                    HOST_PORT       ='9001'
                    DOCKER_REGISTRY ='157.230.44.41:5000'
                    BUILD_ENV ='?'
                    VERSION ='1.0.0'
                    DATE_VERSION = sh script: 'date -u +\'%Y%m%d\'', returnStdout: true
                    DATE_VERSION = DATE_VERSION.trim()
                    COMMIT_NO = sh script: 'git rev-parse --short HEAD', returnStdout: true
                    COMMIT_NO = COMMIT_NO.trim()
                    DOCKER_TAG      ='?'
                    TARGET_HOST     ='?'
                    PM2_FILE        ='?'
                    DOCKER_MAPPING_PORT =  HOST_PORT+':'+CONTAINER_PORT
                    MOUNT_PATH      ='/app/log/'+DOCKER_IMG_NAME+':/app/'+DOCKER_IMG_NAME+'/logs:Z'

                    if(scmVars.GIT_BRANCH  ==~ /.*\/master/){
                        TARGET_HOST = 'ct_server_02'               
                        PM2_FILE    = 'pm2.json'
                        DOCKER_TAG  = 'PROD'
                        BUILD_ENV = 'production'
                    } else {
                       TARGET_HOST = 'ct_server_02'
                        PM2_FILE    = 'pm2.json'
                        DOCKER_TAG  = 'DEV'
                        BUILD_ENV = 'dev'
                    }

                    println 'DOCKER_IMG_NAME='   + DOCKER_IMG_NAME
                    println 'DOCKER_TAG='        + DOCKER_TAG
                    println 'DOCKER_REGISTRY='   + DOCKER_REGISTRY
                    println 'TARGET_HOST='       + TARGET_HOST
                    println 'DOCKER_MAPPING_PORT='       + DOCKER_MAPPING_PORT
                    println 'MOUNT_PATH='        + MOUNT_PATH
                    println 'COMMIT_NO=' + COMMIT_NO

                    commitHash = sh script: 'git rev-parse --short HEAD', returnStdout: true
                    commitHash = commitHash.trim()
                    committer = sh script: 'git log -1 --pretty=format:\'%an\'', returnStdout: true
                    committer = committer.trim()
                }
            }

        }

      
        stage('check files') {
            steps {
                sh "pwd"
                sh "ls -lh"
            }
        }

        stage('build container image') {
            steps {
                script {
                    app = docker.build(
                        "${DOCKER_REGISTRY}/${DOCKER_IMG_NAME}:${DOCKER_TAG}",
                        "--build-arg PM2_FILE=${PM2_FILE} \
                         --build-arg CONTAINER_PORT=${CONTAINER_PORT} \
                         --build-arg BUILD_ENV=${BUILD_ENV} \
                         --build-arg VERSION=${VERSION} \
                         --build-arg DATE_VERSION=${DATE_VERSION} \
                         --build-arg COMMIT_NO=${COMMIT_NO} .")
                    // app = docker.build("${DOCKER_REGISTRY}/${DOCKER_IMG_NAME}:${DOCKER_TAG}")
                }
            }
        }

        stage('test container image') {
            steps {
                script {
                    app.inside {
                        sh 'hostname'
                        sh 'ls -lrt'
                        sh 'printenv'
                        sh 'echo "Tests container: passed"'
                    }
                }
            }
        }

        stage('push image to container registry') {
            steps {
                script {
                     withDockerRegistry(
                        credentialsId: 'DockerRegistry',
                        url: "http://${DOCKER_REGISTRY}") {
                            app.push("${DOCKER_TAG}")
                    }
                }
            }
        }
        stage('deploy to target host') {
            steps {
            sshPublisher(
                publishers: [
                    sshPublisherDesc(
                        configName: "${TARGET_HOST}", 
                        transfers: [
                            sshTransfer(
                                excludes: '',
                                execCommand: "docker rm -f ${DOCKER_IMG_NAME} || echo 'ignore' \
                                && docker rmi ${DOCKER_REGISTRY}/${DOCKER_IMG_NAME}:${DOCKER_TAG} || echo 'ignore' \
                                && docker pull ${DOCKER_REGISTRY}/${DOCKER_IMG_NAME}:${DOCKER_TAG} \
                                && docker run -d --restart always --name ${DOCKER_IMG_NAME} -p ${DOCKER_MAPPING_PORT} -p 9011:9011 \
                                    -v ${MOUNT_PATH} --hostname ${DOCKER_IMG_NAME} ${DOCKER_REGISTRY}/${DOCKER_IMG_NAME}:${DOCKER_TAG} ",
                                execTimeout: 120000,
                                flatten: false,
                                makeEmptyDirs: false,
                                noDefaultExcludes: false,
                                patternSeparator: '[, ]+',
                                remoteDirectory: '',
                                remoteDirectorySDF: false,
                                removePrefix: '',
                                sourceFiles: ''
                            )
                        ],
                        usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false
                    )
                ]
            )
            }
        }

    }

    post {
        always {
            script {
                sh "docker rmi ${DOCKER_REGISTRY}/${DOCKER_IMG_NAME}:${DOCKER_TAG} || echo 'ignore'"
            }
            deleteDir()
        }
        // success {
        //     sendToLine(DOCKER_IMG_NAME, TARGET_HOST, DOCKER_TAG, scmVars.GIT_BRANCH , committer , commitHash , "success")
        // }
        // unstable {
        //     sendToLine(DOCKER_IMG_NAME, TARGET_HOST, DOCKER_TAG, scmVars.GIT_BRANCH , committer , commitHash  , "fail")
        // }
        // failure {
        //     sendToLine(DOCKER_IMG_NAME, TARGET_HOST, DOCKER_TAG, scmVars.GIT_BRANCH , committer , commitHash  , "fail")
        // }

    }
}

// def sendToLine(node, TARGET_HOST, DOCKER_TAG, branch , committer , commitHash , status ) {
//     def message = " " ;
//     def msg = "message=\n[NODE]=> "+ node+
//                         "\n[AUTHOR]=> "+committer +
//                         "\n[COMMIT]=> "+commitHash+
//                         "\n[TARGET_HOST]=> "+TARGET_HOST+
//                         "\n[ENV]=> "+DOCKER_TAG+
//                         "\n[DEPLOY STATUS]=> "+status

//     if ( status == 'success' ) {
//         message =  message  + "-F '"+msg+"' -F 'stickerPackageId=2' -F 'stickerId=516'"
//     }else {
//         message = message + "-F '"+msg+"' -F 'stickerPackageId=2' -F 'stickerId=165'"
//     }

//     sh '#!/bin/sh -e\n' + "curl -X POST -H 'Authorization: Bearer Jz0cveBYFJsepSC7cLoOQdGuPlqkbPxNmMiax1VgEvx'"+message +" https://notify-api.line.me/api/notify"
// }

