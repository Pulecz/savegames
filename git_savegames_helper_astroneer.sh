#!/bin/bash

# Load SSH Key for github
KEY_NAME=github
KEY_PATH=/c/Users/${USERNAME}/.ssh/${KEY_NAME}
echo "Initializing SSH Key from ${KEY_PATH}"
eval $(ssh-agent);ssh-add ${KEY_PATH}

# Cities Skylines git savegames helper

# SET THESE!
name_map="green_world1"
backup_id="01" # 2 digit number

# note that bash used in cmder 1.3.5 does not map network drives, use msys instead
backup_folder="/d/incoming/saves"
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
    ["backup_path"]="${backup_folder}/ASTRONEER/${backup_id}_${name_map}"
    ["git_path"]="${sys_paths[home]}/git/savegames/ASTRONEER/${name_map}"
    ["savegames_path"]="${sys_paths[local_appdata]}/Astro/Saved/SaveGames"
    ["savegames_config_path"]="${sys_paths[local_appdata]}/Astro/Saved/Config/WindowsNoEditor"  # only Win ver now
    # for id 361420(ASTRONEER)
    ["steam_cloud"]="${steam_userdata}/361420/remote"  # does not exist yet
    ["steam_screenshots"]="${steam_userdata}/760/remote/361420/screenshots"
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

# start helper

## 1. pick what save to copy
echo
echo "Copy savegame from steam_cloud to git"
echo "Pick a .sav file relating to your map ${name_map}"
cd "${game[savegames_path]}"
echo Avaliable saves:
ls *.sav -alh
echo
target_save=$(pick_a_file)

## 2. prepare git folder based on city and map name and copy save	
echo Copying to git folder, confirm overwrite, if you don\'t care to made a commit on last one
mkdir_if_none "${game[git_path]}"
cp -i "${game[savegames_path]}"/${target_save} "${game[git_path]}/${name_map}.sav"  # copy the save and rename it to name_map.sav

## 3. run editor for README.md(space_log.md) and totalcmd for screenshots
cd "${game[git_path]}"

# touch(create) README.md if does not exist
if ! [ -e README.md ]
    then echo "README.md does not exist, creating new one"
    touch README.md
fi

echo
echo Add changes
start README.md  # runs whatever is associated with windows
# 4. sort screenshots
echo "Maybe you want to see the screens during, opening TotalCMD with new screenshots on the left and your backup_folder on right"
# make sure the dir for screens exist
mkdir_if_none "${game[backup_path]}"/screens
start ${totalcmdbin} -L="${game[steam_screenshots]}" -R="${game[backup_path]}"/screens

# 5. throw user to git folder so git work can be done
echo "now do git magic! commit and push"
cd "${game[git_path]}"
