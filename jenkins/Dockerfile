FROM jenkins/jenkins:lts-jdk11

ENV DEBIAN_FRONTEND noninteractive

USER root

# Install Terraform
RUN apt-get update \
    && apt-get -y install --no-install-recommends wget lsb-release \
    && wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install --no-install-recommends -y terraform \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install pip
RUN apt-get update \
    && apt-get -y install --no-install-recommends python3-pip \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Ansible
RUN pip install ansible-core

USER jenkins

# Install necessary Ansible package
RUN ansible-galaxy collection install community.general

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
