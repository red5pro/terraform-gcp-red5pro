#!/bin/bash

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
    exit 1
}
log() {
    echo -n "[$(date '+%Y-%m-%d %H:%M:%S')]"
}

NAME=$1
ZONE=$2

if [[ -z "$NAME" ]]; then
    log_e "NAME variable is not set!"
fi
if [[ -z "$ZONE" ]]; then
    log_e "ZONE variable is not set!"
fi

NODES_DISK_NAME=("$NAME-node-origin-image" "$NAME-node-edge-image" "$NAME-node-relay-image" "$NAME-node-transcoder-image" "$NAME-stream-manager")

for disk_name in "${NODES_DISK_NAME[@]}"; do
    gcloud compute disks list --filter="name=($disk_name)" | grep "$disk_name" | awk '{print$1}' >> disk_details.txt
done

while read -r line; do
    log_i "Deleting disk for node: $line"
    gcloud compute disks delete $line --zone=$ZONE --quiet
    if [ $? -eq 0 ]; then
        log_i "Node disk deleted successfully!"
    else
        log_w "Unable to delete disk for node: $line"
    fi
done < disk_details.txt

if [[ -f disk_details.txt ]]; then
    rm disk_details.txt
fi