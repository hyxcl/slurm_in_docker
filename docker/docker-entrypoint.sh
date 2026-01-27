#!/bin/bash
set -x

sudo service munge start

if [ "$1" = "slurmdbd" ]
then
    echo "---> Starting the Slurm Database Daemon (slurmdbd) ..."
    {
        . /etc/slurm/slurmdbd.conf
        until echo "SELECT 1" | mysql -h $StorageHost -u$StorageUser -p$StoragePass 2>&1 > /dev/null
        do
            echo "-- Waiting for database to become active ..."
            sleep 2
        done
    }
    echo "-- Database is now active ..."

    exec /usr/sbin/slurmdbd -Dvvv
fi

if [ "$1" = "slurmctld" ]
then
    echo "---> Starting the Slurm Controller Daemon (slurmctld) ..."
    service slurmctld start
fi

if [ "$1" = "slurmd" ]
then
    echo "---> Starting the Slurm Node Daemon (slurmd) ..."
    service slurmd start
fi

tail -f /dev/null
