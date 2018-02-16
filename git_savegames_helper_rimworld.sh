#!/bin/bash

# Load SSH Key for github
KEY_NAME=github
KEY_PATH=/c/Users/${USERNAME}/.ssh/${KEY_NAME}
echo "Initializing SSH Key from ${KEY_PATH}"
eval $(ssh-agent);ssh-add ${KEY_PATH}

# RimWorld git savegames helper

# SET THESE!
seed="sea lion"
name="chillio"
backup_id="01" # 2 digit number

backup_folder="/s/incoming/saves"
steam_userdata="/c/Program Files (x86)/Steam/userdata/52064014"
totalcmdbin="/c/totalcmd/TOTALCMD64.EXE"

# initialize associatve arrays(something like dictionary)
declare -A sys_paths
declare -A game

sys_paths=(
    # I wish they could reference on each other
    ["home"]="/c/Users/${USERNAME}/"
    ["local_appdata"]="/c/Users/${USERNAME}/AppData/Local"
    ["locallow_appdata"]="/c/Users/${USERNAME}/AppData/LocalLow"  # for RimWorld
)

game=(
    ["backup_path"]="${backup_folder}/rimworld/${backup_id}_${name}_${seed}"
    ["git_path"]="${sys_paths[home]}/git/savegames/RimWorld/${name}_${seed}"
    ["savegames_path"]="${sys_paths[locallow_appdata]}/Ludeon Studios/RimWorld by Ludeon Studios"
    ["steam_data"]="${steam_userdata}/294100"
    ["steam_screenshots"]="${steam_userdata}/760/remote/294100/screenshots"
)

# helpers

function pick_a_file() {
    # -e enables Readline (tab completion)
    local target_file # variable for function only
    read -e -p "Use TAB for help $(echo $'\n> ')" target_file
    echo ${target_file}  # return
}

function mkdir_if_none() {
if ! [ -d "$1" ]
    then mkdir -p "$1"
fi
}

## 1. pick what save to copy
echo
echo "Copy savegame from locallow savegeame path to git"
echo "Pick a .rws file relating to your city ${name} on map ${seed}"
cd "${game[savegames_path]}"/Saves
echo Avaliable saves:
ls *.rws -alh
echo
target_save=$(pick_a_file)

## 2. prepare git folder based on city and map name and copy save	
echo Copying to git folder, confirm overwrite, if you don\'t care to made a commit on last one
mkdir_if_none "${game[git_path]}"
cp -i "${game[savegames_path]}"/Saves/${target_save} "${game[git_path]}"

## 2.1 specific for RimWorld, remind about ModsConfig.xml along with the saves
# so others can load the save with all the required mods even thought
# modlist this should import all mods based on the savegame http://steamcommunity.com/sharedfiles/filedetails/?id=1139051045
ModsList_path="${game[savegames_path]}"/Config
echo
read -p "Have you changed any Mods? If copy ModsConfig.xml? [y/n]" if_to_copy_xml
if [ "$if_to_copy_xml" = "y" ]
	then echo pick a .xml file to copy to git
	cd "${ModsList_path}"
	target_xml="ModsConfig.xml"
	cp -i "${ModsList_path}"/${target_xml} "${game[git_path]}"
elif [ "$if_to_copy_xml" = "n" ]
	then echo ok
fi

## 3. run editor for README.md(log.md) and totalcmd for screenshots
cd "${game[git_path]}"

# touch(create) README.md if does not exist
if ! [ -e README.md ]
    then echo "README.md does not exist, creating new one"
    touch README.md
fi

echo
echo Add changes
start README.md  # runs whatever is associated with windows
# sort screenshots
echo "Maybe you want to see the screens during, opening TotalCMD with new screenshots on the left and your backup_folder on right"
# make sure the dir for screens exist
mkdir_if_none "${game[backup_path]}"/screens
start ${totalcmdbin} -L="${game[steam_screenshots]}" -R="${game[backup_path]}"/screens

echo "now do git magic! commit and push"