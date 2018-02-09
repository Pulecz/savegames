#!/bin/bash

# Load SSH Key for github
KEY_NAME=github
KEY_PATH=/c/Users/${USERNAME}/.ssh/${KEY_NAME}
echo "Initializing SSH Key from ${KEY_PATH}"
eval $(ssh-agent);ssh-add ${KEY_PATH}

# Cities Skylines git savegames helper, other games should have its own scripts

# SET THESE!
name_map="regal_hills"
name_city="cannville"
backup_id="09" # 2 digit number

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
	["backup_path"]="${backup_folder}/cities_skylines/${backup_id}_${name_map}_${name_city}"
	["git_path"]="${sys_paths[home]}/git/savegames/CitiesSkylines/${name_map}_${name_city}"
	["savegames_path"]="${sys_paths[local_appdata]}/Colossal Order/Cities_Skylines"
	["savegames_screenshots_path"]="${sys_paths[local_appdata]}/Colossal Order/Cities_Skylines/Screenshots"
	["steam_cloud"]="${steam_userdata}/255710/remote"
	["steam_screenshots"]="${steam_userdata}/760/remote/255710/screenshots"
)

# start helper

function pick_a_file() {
	# -e enables Readline (tab completion)
	local target_file # variable for function only
	read -e -p "Use TAB for help $(echo $'\n> ')" target_file
	echo ${target_file}  # return
}

# pick what save to copy
	echo
	echo "Copy savegame from steam_cloud to git"
	echo "Pick a .crp file relating to your city ${name_city} on map ${name_map}"
	cd "${game[steam_cloud]}"
	echo Avaliable saves:
	ls *.crp -alh
	echo
	target_save=$(pick_a_file)

echo Copying to git folder, confirm overwrite, if you didn\'t made a commit before
cp -i "${game[steam_cloud]}"/${target_save} "${game[git_path]}"

# edit mayor log
cd "${game[git_path]}"

# touch(create) mayor_log.md if does not exist
	if ! [ -e mayor_log.md ]
	then echo "mayor_log.md does not exist, creating new one"
	touch mayor_log.md
	fi

echo
echo Add changes
start mayor_log.md

# sort screenshots
echo "Maybe you want to see the screens during, opening TotalCMD with new screenshots on the left and your backup_folder on right"
start ${totalcmdbin} -L="${game[steam_screenshots]}" -R="${game[backup_path]}"/screens

# remind about mods.xml
ModsList_path="${game[savegames_path]}"/Addons/Mods/ModsList/ModsList_savefiles

if [ -d  "${ModsList_path}" ]
	then ls "${ModsList_path}" -alh
	echo
	read -p "Have you changed .xml file? [y/n]" if_to_copy_xml
	if [ "$if_to_copy_xml" = "y" ]
		then echo pick a .xml file to copy to git
		cd "${ModsList_path}"
		target_xml=$(pick_a_file)
		cp -i "${ModsList_path}"/${target_xml} "${game[git_path]}"
	elif [ "$if_to_copy_xml" = "n" ]
		then echo ok
	fi
fi

cd "${game[git_path]}"
echo "now do git magic! commit and push"