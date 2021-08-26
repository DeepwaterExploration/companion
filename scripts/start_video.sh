#!/bin/bash
export LD_LIBRARY_PATH=/usr/local/lib/
# set bitrate and H.264 recording settings for all connected cameras that support exploreHD
for DEVICE in $(ls /dev/video*); 
do
    .$HOME/companion/scripts/explorehd_camera_controls/explorehd_UVC_TestAP --xuset-br 1500000 $DEVICE
    .$HOME/companion/scripts/explorehd_camera_controls/explorehd_UVC_TestAP --xuset-gop 0 $DEVICE
    .$HOME/companion/scripts/explorehd_camera_controls/explorehd_UVC_TestAP --xuset-cvm 2 $DEVICE
done
if [ -z "$1" ]; then
    WIDTH=$(cat ~/vidformat.param | xargs | cut -f1 -d" ")
    HEIGHT=$(cat ~/vidformat.param | xargs | cut -f2 -d" ")
    FRAMERATE=$(cat ~/vidformat.param | xargs | cut -f3 -d" ")
    DEVICE=$(cat ~/vidformat.param | xargs | cut -f4 -d" ")
    DEVICE2=$(cat ~/vidformat.param | xargs | cut -f5 -d" ")
else
    WIDTH=$1
    HEIGHT=$2
    FRAMERATE=$3
    DEVICE=$4
    DEVICE2=$5
fi

# load gstreamer options
gstOptions=$(tr '\n' ' ' < $HOME/gstreamer2.param)
gstOptions2=$(tr '\n' ' ' < $HOME/gstreamer22.param)
# gstOptionsAHD=$(tr '\n' ' ' < $HOME/gstreamer2_AHD.param)

if [ $? != 0 ]; then
    screen -dm -S video_brf bash -c "export LD_LIBRARY_PATH=/usr/local/lib/ && gst-launch-1.0 -v v4l2src device=$DEVICE do-timestamp=true ! video/x-h264 $gstOptions"
    screen -S video_brt bash -c "export LD_LIBRARY_PATH=/usr/local/lib/ && gst-launch-1.0 -v v4l2src device=$DEVICE2 do-timestamp=true ! video/x-h264 $gstOptions2"
else
    screen -dm -S video_brf bash -c "export LD_LIBRARY_PATH=/usr/local/lib/ && gst-launch-1.0 -v v4l2src device=$DEVICE do-timestamp=true ! video/x-h264, width=$WIDTH, height=$HEIGHT, framerate=$FRAMERATE/1 $gstOptions"
    screen -S video_brt bash -c "export LD_LIBRARY_PATH=/usr/local/lib/ && gst-launch-1.0 -v v4l2src device=$DEVICE2 do-timestamp=true ! video/x-h264, width=$WIDTH, height=$HEIGHT, framerate=$FRAMERATE/1 $gstOptions2"
    # if we make it this far, it means the gst pipeline failed, so load the backup settings
    cp ~/vidformat.param.bak ~/vidformat.param && rm ~/vidformat.param.bak
fi

# cleanup
# TODO: refactor so video streams can be restarted independently
screen -X -S video_brf quit
screen -X -S video_brt quit
