#!/bin/bash

timestamp="$(date +%Y%m%d%H%M%S)"
server_base_path="/home/minecraft"
backups_folder="$server_base_path/backups"
log_file_name="backup-$timestamp.log"
log_file_path="$backups_folder/$log_file_name"
backup_file_name="backup-$timestamp.tar.gz"
backup_file_path="$backups_folder/$backup_file_name"

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
  tar -cvpzf "$backup_file_path" -C "$server_base_path" server

  log 'Enabling autosave'
  rcon 'save-on'
}

## Delete everything but last 5 backups
function cicle_backups {
  log 'Cicling backups'
  ls -t "$backups_folder" | awk 'NR > 12 { print "/home/minecraft/backups/"$0 }' | xargs rm -v
}

## Execute backup if there is someone connected
if [ $(rcon 'list' | awk '{print $3}') -gt 0 ]
then 
  backup_server
  cicle_backups 
fi 

exit 0
