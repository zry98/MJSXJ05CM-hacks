#!/bin/sh

# sync time
NTP_PEER="pool.ntp.org"
/mnt/data/bin/ntpd -p ${NTP_PEER}
sleep 10

# start services
perpctl A fetch_av miio_sdcard miio_record miio_algo motor-controller framegrabber rtsp-server onvif-server
