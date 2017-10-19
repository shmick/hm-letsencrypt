# hm-letsencrypt

Give your internet facing HeaterMeter a **free** HTTPS certificate via [Let's Encrypt](https://letsencrypt.org/)

## Getting Started

These instructions should get you up and running. If you run into any trouble, please post to the [HeaterMeter Forum](https://tvwbb.com/forumdisplay.php?85-HeaterMeter-DIY-BBQ-Controller)

### Prerequisites

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


#### Phase 2 - Generating and renewing a certificate

* We're going to assume your Dynamic DNS name is **myawesomebbq.duckdns.org**

In the HeaterMeter web interface, go to **System** > **Scheduled Tasks** and add the following:

```
0 * * * * /mnt/mmcblk0p4/letsencrypt.sh myawesomebbq.duckdns.org
```

## Acknowledgments

* Neilpang's [acme.sh](https://github.com/Neilpang/acme.sh) script
