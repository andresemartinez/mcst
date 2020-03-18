#!/bin/bash

server_base_path=/opt/minecraft
log_file_name=backup-$(date +%Y%m%d%H%M%S).log
log_file_path=$server_base_path/backups/$log_file_name

## Logs into $1 into a backup specific loggin file
function log {
  echo "$(date "+%F %R") - $1" >> $log_file_path
}

## Connects to minecraft server and executes $1
function rcon {
  $server_base_path/tools/mcrcon/mcrcon -H 127.0.0.1 -P 25575 -p @9hcFwR57Pzt "$1"
}

## Backups the entire server folder
##  1- Disable autosave
##  2- Save the world
##  3- Tar the entire server foulder
##  4- Enable autosave
function backup_server {
  log 'Backing up server'
  log 'Disabling autosave'
  rcon 'save-off'

  log 'Saving world' 
  rcon 'save-all'

  log 'Backuping server'
  tar -cvpzf $server_base_path/backups/backup-$(date +%Y%m%d%H%M%S).tar.gz -C $server_base_path server

  log 'Enabling autosave'
  rcon 'save-on'
}

## Delete everything but last 5 backups
function cicle_backups {
  log 'Cicling backups'
#  find $server_base_path/backups/ -type f -mtime +8 -name '*.gz' -delete
#  ls -t $server_base_path/backups/ | grep -E "(\.tar\.gz)|(\.log)" | tail -n +11 | xargs rm
   find /opt/minecraft/backups/ -name "backup-*" | tail -n +11 | xargs rmfind /opt/minecraft/backups/ -name "server-*" | tail -n +11 | xargs rm
}

if [ $(rcon 'list' | awk '{print $3}') -gt 0 ]
then 
  backup_server
  cicle_backups 
fi 

exit 0
