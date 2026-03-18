# slurm_in_docker
## Prerequisites
- [Docker](https://docs.docker.com/get-docker/)
- [The NVIDIA container toolkit 2](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker) 
-  no need to install enroot , pyxis in node.
## install steps
- clone this repo
    ```
    git clone https://github.com/hyxcl/slurm_in_docker.git
    ```
- pull slurm docker image. or you can also build it from the docker/Dockerfile
    - x86_64 系统：
        ```
        docker pull hyxcl001/slurm:25.11.2-v3
        ```
    - ARM (aarch64) 系统：
        ```
        docker pull hyxcl001/slurm:25.11.2-arm
        ```
-  modify the config files according to your cluster.   
    1. in `slurm.conf`, modify bellow part:
        ```
        ClusterName=gb200
        SlurmctldHost=masternode
        NodeName=nvl721001-T[01-18] Gres=gpu:4 CPUs=144 Boards=1 Sockets=2 CoresPerSocket=72 ThreadsPerCore=1 RealMemory=921600
        PartitionName=ALL Nodes=ALL Default=YES MaxTime=INFINITE State=UP
        ```
    2. in `gres.conf`, also modify according to your server.
    3. in `hosts`, add the hostname and IP mapping for all nodes, for example:
        ```
        10.0.0.1  masternode
        10.0.0.2  node01
        10.0.0.3  node02
        ```

- modify the slurm.sh scripts.     
    set `MOUNT_POINT` to a shared storage path accessible by all nodes (e.g. NFS/Lustre mount):
    ```
    export MOUNT_POINT=/your/shared/path
    ```

- launch slurmctld container in master nodes.
    ```
    bash slurm.sh slurmctld
    ```
- launch slurmd container in all compute nodes, each one like:
    ```
    bash slurm.sh slurmd
    ```
## launch jobs
- in the master node. go into the container using `docker exec -it slurmctld bash`,  and then submit slurm jobs in the container.
## Known Issue
- sometimes after job finish, part of the nodes failed to delete enroot container, need to manually delete it. suggest to add a cleanup step in each job, you can refer to the nccl.sub in example.
