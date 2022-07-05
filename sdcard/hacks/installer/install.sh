#!/bin/sh
# shellcheck disable=SC1090,SC2039

CONFIG_FILE="/mnt/sdcard/hacks/installer/config.sh"
PERSISTENT_CONFIG_FILE="/mnt/data/config/config.sh"
LOG_FILE="/mnt/sdcard/hacks/installer/installer.log"
DATA_BLOCK="/dev/mtdblock3"
CONFIG_BLOCK="/dev/mtdblock4"

# redirect stdout and stderr to the log file
exec 1>>${LOG_FILE}
exec 2>&1

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] ${1}" >>${LOG_FILE}
}

die() {
  log "$1"
  exit 1
}

# check if there is a new config file on sdcard
if [ -f ${CONFIG_FILE} ] && [ -f ${PERSISTENT_CONFIG_FILE} ]; then
  if (cmp -s ${CONFIG_FILE} ${PERSISTENT_CONFIG_FILE}); then
    log "Hack already installed and no new config found on SD card"
    exit 0
  fi
fi

log "Start installing hack"

# load configs
if [ -f ${CONFIG_FILE} ]; then
  source ${CONFIG_FILE}
else
  die "Can't load config file (${CONFIG_FILE})"
fi

# deactivate all services
no_stop="mortox"
for service in /etc/perp/*; do
  sleep 1
  if (echo "${no_stop}" | grep -w "$(basename ${service})" &>/dev/null); then
    continue
  fi
  perpctl X ${service} || die "Can't deactivate ${service}"
done
killall -9 miio_record # it's still alive

/etc/init.d/S99netcheck stop
/etc/init.d/S61crond stop
#/etc/init.d/S15watchdog stop # this causes reboot
killall imi_watchdog
/etc/init.d/S11mdev stop
/etc/init.d/S01logging stop
sleep 5
log "Services stopped"

# backup NVRAM
nvram_config_file="/mnt/data/.config.nvram"
if [ -f "${nvram_config_file}" ]; then
  mortoxc sync nvram
  dd if=${nvram_config_file} of=${CONFIG_BLOCK} bs=64K count=1
fi
perpctl X mortox && log "mortox service stopped" || die "Can't stop mortox service"

# stop perp service
/etc/init.d/S50perp stop && log "perp service stopped" || die "Can't stop perp service"
sleep 5
rm -f /var/run/perp/perp*
# stop remaining services using data block
killall -9 wpa_supplicant hostapd dhcpd ntpd wpa_cli miio_cloud

# unmount data block and later remount it back to make sure no process is still using it
for _ in $(seq 10); do
  sleep 5
  umount -f ${DATA_BLOCK} && break
done

# check if data block is still mounted
if (grep -qs "${DATA_BLOCK} " /proc/mounts); then
  die "Can't unmount data block"
else
  log "Data block unmounted"
fi

# remount data block
cat ${DATA_BLOCK} >data.bin && log "Data block backed up"
mount -a

# check if data block is remounted
if (grep -qs "${DATA_BLOCK} " /proc/mounts); then
  log "Data block remounted"
else
  die "Can't remount data block"
fi

# remove useless Xiaomi binaries
# keep miio_algo for auto night-vision switching, miio_sdcard for sdcard checking, miio_record for recording
cd /mnt/data/bin || die "Can't open /mnt/data/bin"
rm -f agent_client ipc_client log2mi.sh log2tf.sh miio_agent miio_client miio_client_helper_nomqtt.sh miio_cloud miio_devicekit miio_log miio_md miio_nas miio_nas_syncer miio_ota miio_qrcode miio_recv_line miio_send_line miio_stream play_audio_test post-ota.sh pre-ota.sh shbf_client

# add hacks
ln -sf /mnt/sdcard/hacks/framegrabber/bin/ipc019/framegrabber framegrabber
ln -sf /mnt/sdcard/hacks/rtsp-server/bin/rtspserver rtspserver
ln -sf /mnt/sdcard/hacks/motor-control/bin/motord motord
ln -sf /mnt/sdcard/hacks/onvif-server/bin/onvif_srvd onvif_srvd
ln -sf /mnt/sdcard/hacks/bin/busybox ntpd

# remove useless Xiaomi perp services
# keep miio_algo for auto night-vision switching, miio_sdcard for sdcard checking, miio_record for recording
cd /mnt/data/etc/perp || die "Can't open /mnt/data/etc/perp"
rm -rf miio_agent miio_client miio_client_helper miio_cloud miio_devicekit miio_nas miio_ota miio_qrcode miio_stream

# add hack perp services
cp -rf /mnt/sdcard/hacks/installer/etc/* /mnt/data/etc/
chmod +t /mnt/data/etc/perp/*
chmod +x /mnt/data/etc/perp/*/rc.main
chmod +x /mnt/data/etc/init.sh

# add hack configs
mkdir -p /mnt/data/config
echo "0 0 " >/mnt/data/config/position
cp -f /mnt/sdcard/hacks/rtsp-server/config/config.json /mnt/data/config/rtsp.json
cp -f ${CONFIG_FILE} ${PERSISTENT_CONFIG_FILE}

# clear crontab
cp -f /mnt/sdcard/hacks/installer/etc/crontab /mnt/data/etc/crontab

# set timezone
ln -sf /usr/share/zoneinfo/${TIMEZONE} /mnt/data/etc/TZ

# restore NVRAM
chmod 777 ${nvram_config_file}
dd if=${CONFIG_BLOCK} of=${nvram_config_file} bs=64K count=1
chmod 000 ${nvram_config_file}
log "NVRAM restored"

# restart perp service
/etc/init.d/S50perp start && log "perp service restarted" || die "Can't restart perp service"
sleep 5
perpctl A mortox && log "mortox reactivated" || die "Can't reactivate mortox"
mortoxc sync nvram && log "NVRAM synced" || die "Can't sync NVRAM"
sleep 5

# save configs to NVRAM
mortoxc set nvram default motor "[51,51]"
mortoxc set nvram default timezone "/usr/share/zoneinfo/${TIMEZONE}"
mortoxc set nvram default light "${LED_INDICATOR}"
mortoxc set nvram default full_color "${FULL_COLOR}"
if [ "${NIGHT_VISION}" == "on" ]; then
  NIGHT_MODE="2"
elif [ "${NIGHT_VISION}" == "off" ]; then
  NIGHT_MODE="1"
else # auto
  NIGHT_MODE="0"
fi
mortoxc set nvram default night_mode "${NIGHT_MODE}"
mortoxc set nvram default wdr "${WDR}"
mortoxc set nvram default watermark "${WATERMARK}"
mortoxc set nvram default flip "${VIDEO_FLIP}"
mortoxc set nvram default miio_ssid "${WIFI_SSID}"
mortoxc set nvram default key_mgmt "${WIFI_SECURITY}"
mortoxc set nvram default miio_passwd "${WIFI_PASSWORD}"
mortoxc set nvram default bind_status "ok"
mortoxc sync nvram
sleep 5

# finishing
log "Installed successfully"
sleep 5

reboot now
