# slurm_in_docker
## install steps
- clone this repo
```
git@github.com:hyxcl/slurm_in_docker.git
```
-  modify the slurm config files according to your cluster.   
    in slurm.conf, modify bellow part:
    ```
    ClusterName=gb200
    SlurmctldHost=dgxa100
    NodeName=node[1-2] Gres=gpu:8 CPUs=80 Boards=1 Sockets=2 CoresPerSocket=20 ThreadsPerCore=2 RealMemory=409600
    NodeName=dgxa100 Gres=gpu:8 CPUs=80 Boards=1 Sockets=2 CoresPerSocket=20 ThreadsPerCore=2 RealMemory=409600
    PartitionName=su Nodes=ALL Default=YES MaxTime=INFINITE State=UP
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