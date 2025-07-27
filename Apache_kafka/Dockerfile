# Start with a minimal base image with networking tools
FROM alpine:latest

# Install required packages: bash, curl, openjdk (Kafka needs Java), and network tools
RUN apk add --no-cache bash curl openjdk17 wget iputils net-tools

# Set environment variables
ENV KAFKA_VERSION=3.7.2 \
    SCALA_VERSION=2.13 \
    KAFKA_HOME=/opt/kafka
#https://downloads.apache.org/kafka/3.7.2/kafka_2.13-3.7.2.tgz
# Download and extract Kafka
RUN mkdir -p $KAFKA_HOME && \
    wget -q https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    tar -xzf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz --strip-components=1 -C $KAFKA_HOME && \
    rm kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

# Add Kafka to PATH
ENV PATH="$KAFKA_HOME/bin:$PATH"

# Default command
CMD ["bash"]
