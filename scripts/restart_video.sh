#!/bin/bash

if screen -ls | grep video; then
    screen -X -S video_brf quit
    screen -X -S video_brt quit
    screen -X -S video quit
fi

# this is followed up in start_video.sh
cp /home/pi/vidformat.param /home/pi/vidformat.param.bak

if [ "$#" == 8 ]; then
    echo $1 > /home/pi/vidformat.param
    echo $2 >> /home/pi/vidformat.param
    echo $3 >> /home/pi/vidformat.param
    echo $4 >> /home/pi/vidformat.param
    echo $5 >> /home/pi/vidformat.param
    echo $6 >> /home/pi/vidformat.param
    echo $7 >> /home/pi/vidformat.param
    echo $8 >> /home/pi/vidformat.param
else
    echo "Invalid number of parameters [$#]: $@"
fi

sudo -H -u pi screen -dm -S video /home/pi/companion/tools/streamer.py
