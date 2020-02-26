pipelineJob('L2Demo') {
    triggers {
        scm('H/3 * * * *')
    }
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        name('origin')
                        url('https://github.com/nclouds/generalized.git')
                    }
                    branch('Layer2')
                }
            }
            scriptPath('cloudformation/ECS/application/Jenkinsfile')
        }
    }
}