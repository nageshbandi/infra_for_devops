# Start with minimal Alpine
FROM alpine:3.20

# Install core utilities and sudo
RUN apk update && \
    apk add --no-cache \
        sudo \
        bash \
        curl \
        wget \
        ncurses \
        netcat-openbsd \
        openrc \
        openssh \
        git \
        helm \
        kubectl \
        py3-pip \
        go \
        python3 \
        util-linux \
        jq \
        tar \
        gzip \
        gcompat \
        ca-certificates \
        busybox-extras \
        bash-completion \
        mysql-client \
        unzip

# Create user 'nagbandi' with sudo privileges
RUN adduser -D nagbandi && \
    echo "nagbandi ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER nagbandi
WORKDIR /home/nagbandi

# Install Helm, Terraform, Terragrunt, Kafka CLI tools, AWS CLI, and GCP CLI

# Switch to root for installation (sudo needed for package managers)
USER root

# Install Terraform
ENV TERRAFORM_VERSION=1.8.5
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/terraform && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
# Install Terragrunt
RUN wget -O /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v0.48.0/terragrunt_linux_amd64 && \
    chmod +x /usr/local/bin/terragrunt

# Install AWS CLI v2 (official installer)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install

# Install Google Cloud SDK (gcloud CLI)
# RUN echo -e "https://packages.cloud.google.com/apt cloud-sdk main" >> /etc/apk/repositories && \
#     apk add --no-cache python3 py3-pip && \
#     pip install --upgrade pip && \
#     pip install google-cloud-sdk && \
#     ln -s /usr/lib/python3.*/site-packages/googlecloudsdk/bin/gcloud /usr/local/bin/gcloud

# Kafka utilities (e.g., kafka-console-producer/consumer)
# Use official binaries for Kafka tools
RUN wget https://archive.apache.org/dist/kafka/3.6.2/kafka_2.13-3.6.2.tgz -O /tmp/kafka.tgz \
    && tar -xzvf /tmp/kafka.tgz -C /opt \
    && ln -s /opt/kafka_2.13-3.6.2/bin/* /usr/local/bin


# Clean up
RUN rm -rf /tmp/*

# Create volume mounts for persistent config files
VOLUME ["/home/nagbandi/.aws", "/home/nagbandi/.config/gcloud"]

# Restore to user
USER nagbandi
WORKDIR /home/nagbandi

# Entrypoint: Start a shell, override with your own command as needed
ENTRYPOINT ["/bin/bash"]
