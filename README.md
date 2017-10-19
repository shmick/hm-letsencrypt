# hm-letsencrypt

Give your internet facing HeaterMeter a **free** HTTPS certificate via [Let's Encrypt](https://letsencrypt.org/)

## Getting Started

These instructions should get you up and running. If you run into any trouble, please post to the [HeaterMeter Forum](https://tvwbb.com/forumdisplay.php?85-HeaterMeter-DIY-BBQ-Controller)

### Prerequisites

* You must be running [HeaterMeter Stable Firmware Release v14](https://tvwbb.com/showthread.php?72170-Stable-Firmware-Release-v14)
* Your router must be forwarding port 443 to port 443 on your HeaterMeter
* You need a Dynamic DNS name

### Installing

#### Phase 1 - Installing the letsencrypt.sh script

* This will download the letsencrypt.sh to /mnt/mmcblk0p4/letsencrypt.sh
* This script runs on every reboot, but only downloads the ```letsencrypt.sh``` script if it's not already installed.

In the HeaterMeter web interface, go to **System** > **Startup** and edit the **Local Startup** entry.

Add this line before ```exit 0```
```
sleep 1m ; curl -s https://raw.githubusercontent.com/shmick/hm-letsencrypt/master/install.sh | sh
```
It should now look like:

```
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

sleep 1m ; curl -s https://raw.githubusercontent.com/shmick/hm-letsencrypt/master/install.sh | sh
exit 0
```

Click on **Submit** to save the changes.

Click on the **Reboot** tab and then click on **Perform reboot** to reboot your HeaterMeter


#### Phase 2 - Generating and/or renewing a certificate

* We're going to assume your Dynamic DNS name is **myawesomebbq.duckdns.org** please use whatever your actual Dynamic DNS name is in the entry below

In the HeaterMeter web interface, go to **System** > **Scheduled Tasks** and add the following:

```
0 * * * * /mnt/mmcblk0p4/letsencrypt.sh myawesomebbq.duckdns.org
```

Click on **Submit** to save your changes.

This will attempt to create or renew your certificate every hour.

**Note:** The certificate is valid for 90 days and will only attempt to renew once there's less than 30 days remaining.

Since you probably don't want to wait up to an hour for your certificate to be generated, you can add this line to the **Local Startup** entry in **Phase 1**. Make sure to add it **before** ```exit 0```

```
sleep 1m ; /mnt/mmcblk0p4/letsencrypt.sh myawesomebbq.duckdns.org
```

Go ahead and reboot your HeaterMeter once more.

### Testing

You should now be able to go to https://(whatever your Dynamic DNS name is) and you should see your HeaterMeter and your browser should show that the site is secure.

## Acknowledgments

* Neilpang's [acme.sh](https://github.com/Neilpang/acme.sh) script
