#!/bin/sh

DIR=/mnt/mmcblk0p4
SCRIPT=letsencrypt.sh

if [ ! -f $DIR/$SCRIPT ]
then 
curl -so $DIR/$SCRIPT https://raw.githubusercontent.com/shmick/hm-letsencrypt/master/$SCRIPT
chmod +x $DIR/$SCRIPT
fi
