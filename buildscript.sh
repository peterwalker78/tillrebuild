#!/bin/bash
#logfile=script.log
#exec > $logfile 2>&1

mount -t msdos /dev/?da1 /mnt/hdd
cd /mnt/hdd/adx_sdt1

export OLDIP="$(grep IP /IP.TXT | awk '{print $2}')"
export OLDROUTE="$(grep ROUTE /IP.TXT | awk '{print $2}')"
export OLDNETMASK="$(grep NETMASK /IP.TXT | awk '{print $2}')"
export IMAGEIP="$(grep lan0 adxipccz.bat | awk '{print $3}')"
export IMAGEROUTE="$(grep default adxipccz.bat | awk '{print $4}')"
export IMAGENETMASK="$(grep lan0 adxipccz.bat | awk '{print $5}')"

sed -i "s=$IMAGEIP=$OLDIP=;s=$IMAGEROUTE=$OLDROUTE=;s=$IMAGENETMASK=$OLDNETMASK=" adxipccz.bat
cat adxipccz.bat >> adxipccz.tmp
rm adxipccz.bat
mv adxipccz.tmp adxipccz.bat
umount /mnt/hdd
eject
clear
echo "Restore complete!"
echo "Please remove the disc from the tray then press any key to reboot."
read -p \$
cd /
shutdown -r now
