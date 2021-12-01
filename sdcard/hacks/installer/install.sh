#!/bin/sh
# shellcheck disable=SC1090,SC2039

HACK_INSTALLED_FLAG_FILE="/mnt/data/config/.hack_installed"
CONFIG_FILE="/mnt/sdcard/hacks/installer/config.sh"
LOG_FILE="/mnt/sdcard/hacks/installer/installer.log"

# redirect stdout and stderr to log file
exec 1>${LOG_FILE}
exec 2>&1

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] ${1}" >>${LOG_FILE}
}

die() {
  log "$1"
  exit 1
}

if [ -f ${HACK_INSTALLED_FLAG_FILE} ]; then
  # hack already installed
  exit 0
else
  log "Hack installer started"
fi

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
  if echo "${no_stop}" | grep -w "$(basename ${service})" &>/dev/null; then
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
config_block="/dev/mtdblock4"
if [ -f "${nvram_config_file}" ]; then
  mortoxc sync nvram
  dd if=${nvram_config_file} of=${config_block} bs=64K count=1
fi
perpctl X mortox && log "mortox service stopped" || die "Can't stop mortox service"

# stop perp service
/etc/init.d/S50perp stop && log "perp service stopped" || die "Can't stop perp service"
sleep 5
rm -f /var/run/perp/perp*
# stop remaining services using /dev/mtdblock3
killall -9 wpa_supplicant hostapd dhcpd

# unmount data block
for _ in $(seq 10); do
  sleep 5
  umount -f /dev/mtdblock3 && break
done

# check if data block is still mounted
if grep -qs '/dev/mtdblock3 ' /proc/mounts; then
  die "Can't unmount data block"
else
  log "Data block unmounted"
fi

# backup data block to SD card and remount it
cat /dev/mtdblock3 >/mnt/sdcard/hacks/installer/data.bak && log "Data block backed up"
mount -a

# check if data block is remounted
if grep -qs '/dev/mtdblock3 ' /proc/mounts; then
  log "Data block remounted"
else
  die "Can't remount data block"
fi

# remove useless Xiaomi stuff
cd /mnt/data/bin || die "Can't open /mnt/data/bin"
rm -f agent_client ipc_client log2mi.sh log2tf.sh miio_agent miio_client miio_client_helper_nomqtt.sh miio_cloud miio_devicekit miio_log miio_md miio_nas miio_nas_syncer miio_ota miio_qrcode miio_recv_line miio_send_line miio_stream play_audio_test post-ota.sh pre-ota.sh shbf_client

# add hacks
ln -sf /mnt/sdcard/hacks/framegrabber/bin/framegrabber framegrabber
ln -sf /mnt/sdcard/hacks/rtsp-server/bin/rtspserver rtspserver
ln -sf /mnt/sdcard/hacks/motor-control/bin/motord motord
ln -sf /mnt/sdcard/hacks/onvif-server/bin/onvif_srvd onvif_srvd
ln -sf /mnt/sdcard/hacks/bin/busybox ntpd

# remove useless Xiaomi stuff
cd /mnt/data/etc/perp || die "Can't open /mnt/data/etc/perp"
rm -rf miio_agent miio_client miio_client_helper miio_cloud miio_devicekit miio_nas miio_ota miio_qrcode miio_stream

# add hacks
cp -r /mnt/sdcard/hacks/installer/etc/* /mnt/data/etc/
chmod +t /mnt/data/etc/perp/*
chmod +x /mnt/data/etc/perp/*/rc.main
chmod +x /mnt/data/etc/init.sh
echo -e "\n[ -f /mnt/data/etc/init.sh ] && /mnt/data/etc/init.sh &" >>fetch_av/fetch_av_set.sh

mkdir -p /mnt/data/config
echo "0 0 " >/mnt/data/config/position
cp /mnt/sdcard/hacks/rtsp-server/config/config.json /mnt/data/config/rtsp.json
cp ${CONFIG_FILE} /mnt/data/config/config.sh

# set timezone
ln -sf /usr/share/zoneinfo/${TIMEZONE} /mnt/data/etc/TZ

# restore NVRAM
chmod 777 ${nvram_config_file}
dd if=${config_block} of=${nvram_config_file} bs=64K count=1
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
touch ${HACK_INSTALLED_FLAG_FILE}
log "Installed successfully"
sleep 5

reboot now
