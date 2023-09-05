pipeline {
    agent any

    stages("Rent and configure VPN server.") {
        stage("Checkout source code.") {
            steps {
                git url: "https://www.github.com/leomichalski/aws-ec2-vpn.git", branch: "main"
            }
        }

        stage("Initialize Terraform.") {
            environment {
                AWS_ACCESS_KEY_ID = credentials("AWS_ACCESS_KEY_ID")
                AWS_SECRET_ACCESS_KEY = credentials("AWS_SECRET_ACCESS_KEY")

                S3_BACKEND_BUCKET = credentials("S3_BACKEND_BUCKET")
                S3_BACKEND_KEY_PATH = credentials("S3_BACKEND_KEY_PATH")
                REGION = credentials("REGION")
                ENCRYPT = credentials("ENCRYPT")
                S3_BACKEND_DYNAMODB_TABLE = credentials("S3_BACKEND_DYNAMODB_TABLE")

            }
            steps {
                script {
                    dir("infrastructure") {
                        sh '''#!/bin/bash
                            terraform init -backend-config="bucket=${S3_BACKEND_BUCKET}" \
                                           -backend-config="key=${S3_BACKEND_KEY_PATH}" \
                                           -backend-config="region=${REGION}" \
                                           -backend-config="encrypt=${ENCRYPT}" \
                                           -backend-config="dynamodb_table=${S3_BACKEND_DYNAMODB_TABLE}"
                        '''
                    }
                }
            }
        }

        stage("Rent the VPN server.") {
            environment {
                AWS_ACCESS_KEY_ID = credentials("AWS_ACCESS_KEY_ID")
                AWS_SECRET_ACCESS_KEY = credentials("AWS_SECRET_ACCESS_KEY")

                TF_VAR_default_ssh_key_name = credentials("SSH_KEY_NAME")
                TF_VAR_default_ssh_public_key = credentials("SSH_PUBLIC_KEY")

                TF_VAR_region = credentials("REGION")
                TF_VAR_availability_zone = credentials("AVAILABILITY_ZONE")
                TF_VAR_project_tag = "my-vpn-tag"
            }
            steps {
                script {
                    dir("infrastructure") {
                        sh '''#!/bin/bash
                            terraform apply --auto-approve
                        '''
                    }
                }
            }
        }
    }
}
