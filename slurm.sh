#!/bin/bash
# Usage: ./slurm-master.sh slurmctld|slurmd

MOUNT_POINT=${MOUNT_POINT:-/path/to/shared/filesystem}
SCRIPTS_PATH=${SCRIPTS_PATH:-/path/to/scripts}
# Get service type from argument (required)
SERVICE=$1

# Validate service type is provided
if [ -z "$SERVICE" ]; then
    echo "Error: Service type is required"
    echo "Usage: ./slurm-master.sh slurmctld|slurmd"
    exit 1
fi

# Validate service type
if [ "$SERVICE" != "slurmctld" ] && [ "$SERVICE" != "slurmd" ]; then
    echo "Error: Service type must be either 'slurmctld' or 'slurmd'"
    exit 1
fi

docker run -itd --rm --privileged=true \
    --net=host --ipc=host \
    --ulimit stack=67108864 --ulimit memlock=-1 \
    --security-opt seccomp=unconfined \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/bin/docker:/usr/bin/docker \
    -v /var/lib/docker:/var/lib/docker \
    -v $SCRIPTS_PATH/slurm.conf:/etc/slurm/slurm.conf \
    -v $SCRIPTS_PATH/gres.conf:/etc/slurm/gres.conf \
    -v $SCRIPTS_PATH/hosts:/etc/hosts \
    -v $MOUNT_POINT:$MOUNT_POINT \
    --gpus all \
    --name $SERVICE \
    slurm:23.02.8-v2 \
    $SERVICE