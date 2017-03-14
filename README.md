# tillrebuild
Automated till controller rebuild process created from the PING project

This imaging process utilises a Central Server as the location to perform the legacy system re-imaging from.
It has been created with the idea that a non-technical user should be able to rebuild the controller with minimal
instruction from a help desk operative, and get the system back up and running within an hour. The process would
obviously not be able to recover the system from a hardware error, but in cases where the cause of a problem was
uncertain (hardware vs. software error), the process could be run as a first step to eliminate the possibility of a
software error as quickly as possible.

The build disc is based an a FOSS (Free Open Source Software) project called PING (Part Image Is Not Ghost).
The latest version of this project can be downloaded as an ISO file in its unmodified form from
http://ping.windowsdream.com/. The project is based on Linux, and it is all done using shell script using
the BASH terminal scripting language. This project has then been modified for our purposes by performing
the following steps:

−	Set up a working environment on a Linux box (Ubuntu is fine).
−	Mount the ISO file and extract the contents to the working directory.
−	In the tmp folder, modify the file isolinux.cfg with the relevant commands to automate required rebuild process.
−	In the tmp folder, modify the file logo.16 with the image to be displayed at boot time.

Once customisation is complete, recompile the ISO file with the following command (all as a single command):

$ sudo mkisofs -D -r -cache-inodes -J -l -b isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -o ../hmvbuild.iso .

−	Using a CD burning tool (ubuntu has one pre-installed), burn the ISO image to a CD.

The isolinux.cfg file is the first configuration file that is processed by PING, and contains all the relevant
details of the Central Server and System Image, as well as the commands for obtaining the IP settings. The commands
that this process passes in are:

Cmd_1 - contains a string of commands separated by a “;” - these commands are responsible for obtaining the IP details,
and applying them to the network adaptor (eth0), and writing them to a file on the temporary RAM disk (IP.TXT).
This command is run BEFORE attempting any network activity.

Cmd_2 - copies the the buildscript.sh file from the Jump Server to the temporary RAM disk. This command is run
AFTER the network settings are instantiated Jump Server images folder has been mounted.

Cmd_3 - calls the buildscript.sh file which then completes the build process. This command is is run AFTER the
clean image has been applied to the controller.

The buildscript.sh file was created custom for this process, and is intended to reside on the Central Server
so that any changes to the build process can be made once, rather than having to redistribute the build CD every
time something changes. Currently the script simply re-inserts the IP details into the clean system image
that has just been applied, however, in future we would be able to script any other settings should we want to.
Below is a cut n paste of the initial version of the buildscript.sh file:

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

touch adxipccz.bat
sed -i "s=$IMAGEIP=$OLDIP=;s=$IMAGEROUTE=$OLDROUTE=;s=$IMAGENETMASK=$OLDNETMASK=" adxipccz.bat
eject
clear
echo "Restore complete!"
echo "Please remove the disc from the tray then press any key to reboot."
read -p \$
cd /
umount /mnt/hdd
shutdown -r now
