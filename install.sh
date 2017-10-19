#!/bin/sh

# sleep for 10 seconds to wait for the network to fully start
sleep 10

DIR=/mnt/mmcblk0p4
SCRIPT=letsencrypt.sh

if [ -z $DIR/$SCRIPT  ]
then 
curl -o $DIR/SCRIPT https://raw.githubusercontent.com/shmick/hm-letsencrypt/master/$SCRIPT
chmod +x $DIR/$SCRIPT
fi
