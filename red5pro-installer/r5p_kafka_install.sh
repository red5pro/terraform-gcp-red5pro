#!/bin/bash
######################################
# Install and configure Kafka Server
######################################
# KAFKA_ARCHIVE_URL="https://downloads.apache.org/kafka/3.8.0/kafka_2.13-3.8.0.tgz"
# KAFKA_CLUSTER_ID="kafka-id"

CURRENT_DIRECTORY=$(pwd)
packages=(ripgrep kafkacat)
kafka_log_dir="/var/log/kafka"

export DEBIAN_FRONTEND=noninteractive

log_i() {
    log
    printf "\033[0;32m [INFO]  --- %s \033[0m\n" "${@}"
}
log_w() {
    log
    printf "\033[0;35m [WARN] --- %s \033[0m\n" "${@}"
}
log_e() {
    log
    printf "\033[0;31m [ERROR]  --- %s \033[0m\n" "${@}"
}
log() {
    echo -n "[$(date '+%Y-%m-%d %H:%M:%S')]"
}

install_pkg() {
    for i in {1..5}; do
        local install_issuse=0
        apt-get -y update --fix-missing &>/dev/null

        for index in ${!packages[*]}; do
            log_i "Install utility ${packages[$index]}"
            apt-get install -y ${packages[$index]} &>/dev/null
        done

        for index in ${!packages[*]}; do
            PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ${packages[$index]} | grep "install ok installed")
            if [ -z "$PKG_OK" ]; then
                log_i "${packages[$index]} utility didn't install, didn't find MIRROR !!! "
                install_issuse=$((${install_issuse} + 1))
            else
                log_i "${packages[$index]} utility installed"
            fi
        done

        if [ ${install_issuse} -eq 0 ]; then
            break
        fi
        if [ $i -ge 5 ]; then
            log_e "Something wrong with packages installation!!! Exit."
            exit 1
        fi
        sleep 20
    done
}

install_jdk() {
    log_i "Adding Amazon Corretto GPG key..."
    curl -fsSL https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg || {
        log_e "Failed to download or save Corretto GPG key."
        return 1
    }

    log_i "Adding Corretto APT repository..."
    echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | \
        tee /etc/apt/sources.list.d/corretto.list > /dev/null

    log_i "Updating APT cache..."
    apt-get update || {
        log_e "APT update failed."
        return 1
    }

    log_i "Installing Amazon Corretto JDK 17..."
    apt-get install -y java-17-amazon-corretto-jdk || {
        log_e "JDK installation failed."
        return 1
    }

    log_i "Amazon Corretto JDK 17 installed successfully."
}

install_google_cloud_ops_agent(){
    log_i "Installing Google Cloud Ops Agent..."
    
    # Check if running on Google Cloud Platform
    if curl -s -f -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone > /dev/null 2>&1; then
        log_i "Detected Google Cloud Platform environment"
        
        # Add Google Cloud repository
        curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
        if [ $? -eq 0 ]; then
            bash add-google-cloud-ops-agent-repo.sh --also-install
            if [ $? -eq 0 ]; then
                log_i "Google Cloud Ops Agent installed successfully"
                
                # Start and enable the service
                systemctl start google-cloud-ops-agent
                systemctl enable google-cloud-ops-agent
                
                # Clean up the installation script
                rm -f add-google-cloud-ops-agent-repo.sh
            else
                log_e "Failed to install Google Cloud Ops Agent"
                rm -f add-google-cloud-ops-agent-repo.sh
                return 1
            fi
        else
            log_e "Failed to download Google Cloud Ops Agent installation script"
            return 1
        fi
    else
        log_w "Not running on Google Cloud Platform, skipping Google Cloud Ops Agent installation"
    fi
}

download_kafka_archive() {
    log_i "Downloading Kafka archive from: $KAFKA_ARCHIVE_URL"
    
    local MAX_RETRIES=5
    local COUNT=0

    until wget -q "$KAFKA_ARCHIVE_URL"; do
        COUNT=$((COUNT + 1))
        echo "Download failed. Attempt $COUNT of $MAX_RETRIES"
        if [ "$COUNT" -ge "$MAX_RETRIES" ]; then
            log_e "Download failed after $MAX_RETRIES attempts. URL: $KAFKA_ARCHIVE_URL"
            exit 1
        fi
        sleep 2
    done

    kafka_archive=$(find . -maxdepth 1 -name 'kafka_*.tgz' -print -quit)

    if [[ -n "$kafka_archive" ]]; then
        kafka_archive=$(basename "$kafka_archive")
        log_i "Kafka archive downloaded: $kafka_archive"
    else
        log_e "No Kafka archive (kafka_*.tgz) found after download."
        ls -lo
        exit 1
    fi
}

set_config() {
    local key="$1"
    local value="$2"

    log_i "Setting configuration: $key=$value"

    if grep -q "^[#]*\s*$key=" "$kafka_config_file"; then
        sed -i "s|^[#]*\s*$key=.*|$key=$value|" "$kafka_config_file"
    else
        echo "$key=$value" >>"$kafka_config_file"
    fi
}

install_kafka() {
    log_i "Kafka configuring..."
    tar -xzvf "${kafka_archive}" -C /usr/local/ >/dev/null 2>&1 # Extract the kafka archive without verbose output
    mv /usr/local/kafka_* /usr/local/kafka
    mkdir -p $kafka_log_dir
    if [[ -d "/usr/local/kafka" ]]; then
        # Set kafka log location to /var/log/kafka/kafka-logs
        if [[ ! -d "$kafka_log_dir/kafka-logs" ]]; then
            log_i "Kafka log directory doesn't exists, creating $kafka_log_dir/kafka-logs"
            mkdir -p $kafka_log_dir/kafka-logs
        fi
        chmod 777 -R $kafka_log_dir/kafka-logs

        kafka_config_file="/usr/local/kafka/config/kraft/server.properties"

        log_i "Setting up Kafka configuration file: $kafka_config_file"

        # Set Kafka log directory to /var/log/kafka/kafka-logs
        sed 's/log.dirs=.*/log.dirs=\/var\/log\/kafka\/kafka-logs/' -i "$kafka_config_file"

        # Comment out the advertised.listeners setting. It will be copied from ${CURRENT_DIRECTORY}/server.properties.
        sed -i 's/^advertised.listeners/#&/' "$kafka_config_file"

        # Set the listeners to BROKER and CONTROLLER
        sed -i 's/listeners=.*/listeners=BROKER:\/\/:9092,CONTROLLER:\/\/:9093/' "$kafka_config_file"

        # Replication and ISR
        set_config offsets.topic.replication.factor 1
        set_config group.initial.rebalance.delay.ms 0
        set_config transaction.state.log.min.isr 1
        set_config transaction.state.log.replication.factor 1

        # Retention settings
        set_config transactional.id.expiration.ms 3600000
        set_config offsets.retention.minutes 2880
        set_config log.retention.hours 24
        set_config log.retention.bytes 1073741824
        set_config log.retention.ms 300000

        # Replica settings
        set_config replica.lag.time.max.ms 10000
        set_config replica.socket.timeout.ms 3000

        # Log segment configuration
        set_config log.segment.bytes 16777216
        set_config log.segment.ms 30000

        # Log cleanup
        set_config log.cleanup.interval.ms 10000
        set_config log.delete.delay.ms 1000

        # Listener and protocol settings
        set_config inter.broker.listener.name BROKER
        set_config listener.security.protocol.map "BROKER:SASL_SSL,CONTROLLER:SASL_SSL,PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL"

        # SSL/SASL settings
        set_config ssl.keystore.type PEM
        set_config ssl.truststore.type PEM
        set_config ssl.endpoint.identification.algorithm ""
        set_config sasl.enabled.mechanisms PLAIN
        set_config sasl.mechanism.controller.protocol PLAIN
        set_config sasl.mechanism.inter.broker.protocol PLAIN

        # Broker settings
        set_config max.request.size 52428800
        set_config initial.broker.registration.timeout.ms 240000

        # Copy extra kafka configuration properties from ${CURRENT_DIRECTORY}/server.properties to "$kafka_config_file"
        if [[ -f "${CURRENT_DIRECTORY}/server.properties" ]]; then
            cat "${CURRENT_DIRECTORY}/server.properties" >>"$kafka_config_file"
        else
            log_e "Extra kafka configuration properties file ${CURRENT_DIRECTORY}/server.properties does not exists"
            exit 1
        fi

        log_i "Format Kafka storage with KAFKA_CLUSTER_ID"
        /usr/local/kafka/bin/kafka-storage.sh format -t "$KAFKA_CLUSTER_ID" -c "$kafka_config_file"

    else
        log_e "Kafka server does not exists at path /usr/local/kafka"
        exit 1
    fi

    if [[ -f "${CURRENT_DIRECTORY}/kafka.service" ]]; then
        log_i "Kafka service file exists, configuring..."
        cp "${CURRENT_DIRECTORY}/kafka.service" /etc/systemd/system/kafka.service
        systemctl daemon-reload
        systemctl enable kafka.service
    else
        log_e "Kafka service file does not exists"
        exit 1
    fi

    # Check total memory in MB
    total_memory_mb=$(free -m | awk '/^Mem:/{print $2}') # Value in MB

    # Verify minimum memory requirement
    if [ "$total_memory_mb" -lt 8192 ]; then
        log_e "Kafka requires at least 8 GB of memory. Found ${total_memory_mb} MB. Exiting."
        exit 1
    fi

    # Set Kafka heap size to 6GB
    mkdir -p /etc/sysconfig
    echo 'KAFKA_HEAP_OPTS="-Xmx6g -Xms6g"' >/etc/sysconfig/kafka
    log_i "Kafka heap size set to 6 GB"
}

start_kafka() {
    log_i "Start Kafka service"
    systemctl restart kafka.service
    if [ "0" -eq $? ]; then
        log_i "Kafka service started!"
    else
        log_e "Kafka service didn't started!"
        log_e "Job for kafka.service failed, See systemctl status kafka.service and journalctl -xe for details."
        exit 1
    fi
}

install_pkg
install_jdk
install_google_cloud_ops_agent
download_kafka_archive
install_kafka
start_kafka
