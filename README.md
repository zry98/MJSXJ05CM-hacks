[![discord](https://img.shields.io/discord/713125176971231233?label=discord)](http://discord.gg/qggupzu)

Stable: ![CI](https://github.com/zry98/MJSXJ05CM-hacks/actions/workflows/build.yml/badge.svg?branch=master)

Latest: ![CI](https://github.com/zry98/MJSXJ05CM-hacks/actions/workflows/build.yml/badge.svg?tag=latest-rc)

# Mi Camera Hacks (MJSXJ05CM)

- [Supported Cameras](#supported-cameras)
- [Features](#features)
- [Install Instructions](#install-instructions)
- [FAQ](#faq)
- [These Guys are Awesome](#these-guys-are-awesome)

Model Name(s) | Picture
--- | ---
MJSXJ05CM|![MJSXJ05CM](images/MJSXJ02CM.jpg)


## Features
Feature | Latest | Stable
--- | --- | ---
Motor Control | ![C/C++ CI](https://github.com/cmiguelcabral/mjsxj05cm-motor-control/workflows/C/C++%20CI/badge.svg?tag=latest-rc) | ![C/C++ CI](https://github.com/cmiguelcabral/mjsxj05cm-motor-control/workflows/C/C++%20CI/badge.svg?branch=master)
ONVIF Server | ![Build](https://github.com/zry98/MJSXJ05CM-ONVIF/actions/workflows/build.yml/badge.svg?tag=latest-rc) | ![Build](https://github.com/zry98/MJSXJ05CM-ONVIF/actions/workflows/build.yml/badge.svg?branch=master)
RTSP Server | ![C/C++ CI](https://github.com/cmiguelcabral/mjsxj05cm-rtsp-server/workflows/C/C++%20CI/badge.svg?tag=latest-rc)| ![C/C++ CI](https://github.com/cmiguelcabral/mjsxj05cm-rtsp-server/workflows/C/C++%20CI/badge.svg?branch=master)
~~Runit~~ | ![C/C++ CI](https://github.com/telmomarques/runit/workflows/C/C++%20CI/badge.svg?tag=latest-rc) | ![C/C++ CI](https://github.com/telmomarques/runit/workflows/C/C++%20CI/badge.svg?branch=master)
~~SFTP Server~~ | ![C/C++ CI](https://github.com/telmomarques/openssh-portable/workflows/C/C++%20CI/badge.svg?tag=latest-rc) | ![C/C++ CI](https://github.com/telmomarques/openssh-portable/workflows/C/C++%20CI/badge.svg?branch=master)
~~SSH Server~~ |![C/C++ CI](https://github.com/telmomarques/dropbear/workflows/C/C++%20CI/badge.svg?tag=latest-rc)|![C/C++ CI](https://github.com/telmomarques/dropbear/workflows/C/C++%20CI/badge.svg?branch=master)
~~Web Configuration Client~~ | ![Node.js CI](https://github.com/cmiguelcabral/mjsxj05cm-web-client/workflows/Node.js%20CI/badge.svg?tag=latest-rc) | ![Node.js CI](https://github.com/cmiguelcabral/mjsxj05cm-web-client/workflows/Node.js%20CI/badge.svg?branch=master)
~~Web Configuration Server~~ | ![Go](https://github.com/cmiguelcabral/mjsxj05cm-web-server/workflows/Go/badge.svg?tag=latest-rc)| ![Go](https://github.com/cmiguelcabral/mjsxj05cm-web-server/workflows/Go/badge.svg?branch=master)
~~Websocker Stream Server~~ | ![Go](https://github.com/cmiguelcabral/mjsxj05cm-websocket-stream-server/workflows/Go/badge.svg?tag=latest-rc)| ![Go](https://github.com/cmiguelcabral/mjsxj05cm-websocket-stream-server/workflows/Go/badge.svg?branch=master)

## Install Instructions
The hacks exploit a flaw in firmware version `3.5.1_0052`, **please read the instructions very carefully!!**

- First [Check your camera firmware version](#view-camera-firmware-version)

- If you have firmware version `3.5.1_0052`, go to [Install the hacks](#install-the-hacks)

- If you have another firmware version, go to [Downgrade the Firmware](#downgrade-the-firmware) **(This method won't work anymore for newer firmwares.)**

### View camera firmware version
1. Configure the camera using the Mi Home app
2. Open the camera in the app and touch the 3 dots in the upper right corner
3. Select the option "General Settings", and then "Check for firmware upgrades"
4. The current firmware version is presented on the screen

### Downgrade the Firmware
**This method won't work anymore for newer firmwares.**

**You will lose the camera configuration!**

⚠️ Please be careful!

⚠️ Do not power down the camera while flashing!

⚠️ Make sure you understand all the steps before continuing!

1. Grab `tf_recovery.bin` file from [here](https://github.com/zry98/MJSXJ05CM-hacks/raw/dev/firmware/IPC019_3.5.1_0052/tf_recovery.img).
2. Put the file in the root of your SD Card (don't change the name!)
3. Power down the camera and insert the SD Card.
4. Power on the camera and wait, the LED indicator will be a solid yellow while the firmware is flashing (this will take several minutes!).
6. When the camera starts rotating and asking for the QR code, it's done.
7. Go to ["Install the hacks"](#install-the-hacks) below.

### Install the hacks
~~1. Configure the camera using the Mi Home app~~ (this is not necessary).
2. Download the [latest release](https://github.com/zry98/MJSXJ05CM-hacks/releases/tag/latest-rc)
3. Unzip it and copy the **contents** (folder `hacks` and `manu_test`) of `sdcard` folder to the root of your SD Card.
4. Power off the camera and insert the SD Card.
5. Power on the camera and wait, the LED indicator will be a solid yellow while the hacks are being installed (this will take several minutes!).
6. When the camera starts rotating, it's done.
7. Find the IP address of your camera on your router.

## FAQ

### I can't downgrade the firmware, I follow the instructions but nothing happens.
You may need to open the camera and use a programmer to directly flash the firmware.

## These Guys are Awesome
Huge thanks to everyone who contributed!

[@aslafy-z](https://github.com/aslafy-z)
[@crckmc](https://github.com/crckmc)
[@thewh1teagle](https://github.com/thewh1teagle)
[@telmomarques](https://github.com/telmomarques)
[@cmiguelcabral](https://github.com/cmiguelcabral)
