#!/bin/bash
# Usage: ./slurm-master.sh slurmctld|slurmd
set -x 
SCRIPTS_PATH=${SCRIPTS_PATH:-$(cd "$(dirname "$0")" && pwd)}

MOUNT_POINT=${MOUNT_POINT:-/tmp}
echo "MOUNT_POINT=$MOUNT_POINT (set a shared storage path accessible by all nodes, e.g. export MOUNT_POINT=/your/nfs/path)"

ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
    SLURM_IMAGE=${SLURM_IMAGE:-hyxcl001/slurm:25.11.2-arm}
else
    SLURM_IMAGE=${SLURM_IMAGE:-hyxcl001/slurm:25.11.2-v3}
fi
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

# Set GPU flag only for slurmd
GPU_FLAG=""
if [ "$SERVICE" == "slurmd" ]; then
    GPU_FLAG="--gpus all"
fi


docker run -itd --rm --privileged=true \
    --net=host --ipc=host \
    --cgroupns=host \
    --ulimit stack=67108864 --ulimit memlock=-1 \
    --security-opt seccomp=unconfined \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/bin/docker:/usr/bin/docker \
    -v /var/lib/docker:/var/lib/docker \
    -v $SCRIPTS_PATH/slurm.conf:/etc/slurm/slurm.conf \
    -v $SCRIPTS_PATH/gres.conf:/etc/slurm/gres.conf \
    -v $SCRIPTS_PATH/hosts:/etc/hosts \
    -v $MOUNT_POINT:$MOUNT_POINT  $GPU_FLAG \
    --name $SERVICE \
    hyxcl001/slurm:25.11.2-v3 \
    $SERVICE
    #--entrypoint /bin/bash \
    #-v /run/dbus/system_bus_socket:/run/dbus/system_bus_socket \
    #-v /sys/fs/cgroup:/sys/fs/cgroup:rw \
