# slurm_in_docker
## install steps
- clone this repo
    ```
    git clone https://github.com/hyxcl/slurm_in_docker.git
    ```
- pull slurm docker image. or you can also build it from the docker/Dockerfile
    ```
    docker pull hyxcl001/slurm:25.11.2-v3
    ```
-  modify the slurm config files according to your cluster.   
    in slurm.conf, modify bellow part:
    ```
    ClusterName=gb200
    SlurmctldHost=masternode
    NodeName=nvl721001-T[01-18] Gres=gpu:4 CPUs=144 Boards=1 Sockets=2 CoresPerSocket=72 ThreadsPerCore=1 RealMemory=921600
    PartitionName=ALL Nodes=ALL Default=YES MaxTime=INFINITE State=UP
    ```
    in gres.conf, also modify according to your server.

- modify the slurm.sh scripts.     
    the part you need to modify is the `MOUNT_POINT` and the `SCRIPTS_PATH`

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
