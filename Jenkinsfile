// MIT License
//
// Copyright (c) 2025 Rubrik
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

pipeline {
    agent any
    tools {
        terraform 'terraform-1.13.1'
    }
    triggers {
        cron(env.BRANCH_NAME == 'main' ? 'H 04 * * *' : '')
    }
    parameters {
        booleanParam(name: 'DRY_RUN', defaultValue: false)
        booleanParam(name: 'VERBOSE', defaultValue: false)
    }
    environment {
        // AWS provider.
        AWS_ACCESS_KEY        = credentials('tf-examples-aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('tf-examples-aws-secret-access-key')
        AWS_DEFAULT_REGION    = credentials('tf-examples-aws-default-region')

        // Google provider.
        GOOGLE_APPLICATION_CREDENTIALS = credentials('tf-examples-gcp-service-account')

        // RSC provider.
        RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS = credentials('tf-examples-polaris-service-account')

        // Terraform test variables.
        TF_VAR_aws_account_id   = credentials('tf-examples-aws-account-id')
        TF_VAR_aws_account_name = credentials('tf-examples-aws-account-name')
        TF_VAR_gcp_project_id   = credentials('tf-examples-gcp-project-id')
    }
    stages {
        stage('Test') {
            steps {
                sh './run_tests.sh ${params.DRY_RUN ? "-n" : ""} ${params.VERBOSE ? "-v" : ""}'
            }
        }
    }
    post {
        cleanup {
            cleanWs()
        }
    }
}
