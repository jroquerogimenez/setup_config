Check existing volumes:

$ lsblk
$ lsblk -f

Make filesystem
$ sudo mkfs -t xfs /dev/nvme1n1
$ sudo mkfs -t xfs /dev/nvme2n1

Mount filesystem
$ sudo mount /dev/nvme1n1 /data
$ sudo mount /dev/nvme2n1 /data_2

Change owner
$ sudo chown -R ubuntu: /data
$ sudo chown -R ubuntu: /data_2



