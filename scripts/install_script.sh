#! /bin/bash

# Version 1.0.0
#
# ----------------------------------------------------
# How to install this script in an Openbravo Appliance
# ----------------------------------------------------
# Copy install_script.sh file to /usr/share/etendo
echo 'alias reinicio_performance="/usr/share/etendo/backup/scripts/reinicio_performance.sh -t restart -p restart"' >> ~/.bashrc && . ~/.bashrc
echo '*:*:*:postgres:syspass' >> ~/.pgpass
chmod 600 ~/.pgpass
echo 'export PGPASSFILE=/home/etendo/.pgpass' >> ~/.bashrc && . ~/.bashrc
source ~/.bashrc
