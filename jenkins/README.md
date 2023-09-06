# Setup the VPN server with a Jenkins trigger

## Host a local Jenkins instance for testing purposes
If there's not a separate server hosting Jenkins, or if the server shouldn't be used yet, here's quick way to get Jenkins up and running for testing purposes.

```
# Navigate to this directory
cd jenkins

# Build the docker image
docker build . -t leomichalski/jenkins:latest

# Host a local Jenkins instance (warning: stop it with "docker stop" so it won't restart on reboot)

docker run -d -p 8080:8080 -p 50000:50000 --restart=on-failure -v jenkins_home:/var/jenkins_home --name jenkins-server --privileged leomichalski/jenkins:latest

# Run the following command, then wait for the "initialAdminPassword" to appear on the screen. Then copy it.
docker logs -f jenkins-server

# Jenkins web interface accessible at http://localhost:8080 . Use the "initialAdminPassword" to log in.
```

## Setup a Jenkins pipeline

When creating a new pipeline, it's possible to just copy and paste the Jenkinsfile that's in this folder. An approach more suitable to production would be to choose the option "Pipeline script from SCM", so "Jenkinsfiles" are versioned.

## Generate SSH keys.

```
ssh-keygen -t rsa -b 4096
```

## Create Jenkins credentials

| ID                        | Content                                                                                                                   | Kind        |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------|-------------|
| AWS_ACCESS_KEY_ID         | Previously generated IAM user AWS access key id.                                                                          | Secret text |
| AWS_SECRET_ACCESS_KEY     | Previously generated IAM user AWS secret access key.                                                                      | Secret text |
| REGION                    | Chosen region (e.g "sa-east-1").                                                                                          | Secret text |
| AVAILABILITY_ZONE         | The availability zone must be in the chosen region (e.g. "sa-east-1a").                                                    | Secret text |
| S3_BACKEND_DYNAMODB_TABLE | Dynamo DB table name (e.g "my-terraform-state-lock").                                                                     | Secret text |
| S3_BACKEND_BUCKET         | S3 bucket name (e.g "my-terraform-state").                                                                                | Secret text |
| S3_BACKEND_KEY_PATH       | Path to the Terraform state file (e.g. "path/to/terraform.tfstate") in the S3 bucket.                                      | Secret text |
| ENCRYPT                   | It enables server side encryption of the Terraform state file. Set the value to "true" (case sensitive).                  | Secret text |
| SSH_PUBLIC_KEY            | Previously generated SSH public key (the ".pub" file). Terraform copies it to the VPN server.                             | Secret text |
| SSH_PRIVATE_KEY_PATH      | Previously generated SSH private key (the file without an extension). Necessary to configure the VPN server with Ansible. | Secret file |
| SSH_KEY_NAME              | The key name of the previously generated SSH keys (same as the private key filename, not the whole path).                 | Secret text |

## Run the pipeline

Option 1: Click the "Build Now" button to run the pipeline.

Option 2: Configure it to run based on another trigger (such as commits or pull requests).
