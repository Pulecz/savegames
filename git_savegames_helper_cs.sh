#!/bin/bash

# Load SSH Key for github
KEY_NAME=github
KEY_PATH=/c/Users/${USERNAME}/.ssh/${KEY_NAME}
echo "Initializing SSH Key from ${KEY_PATH}"
eval $(ssh-agent);ssh-add ${KEY_PATH}

# Cities Skylines git savegames helper

# SET THESE!
name_map="regal_hills"
name_city="cannville"
backup_id="09" # 2 digit number

# note that bash used in cmder 1.3.5 does not map network drives, use msys instead
backup_folder="/s/incoming/saves"
steam_userdata="/c/Program Files (x86)/Steam/userdata/52064014"
totalcmdbin="/c/totalcmd/TOTALCMD64.EXE"
ffmpegbin="/c/ProgramData/chocolatey/bin/ffmpeg.exe"  # installed via chocolatey

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
echo "Pick a .crp file relating to your city ${name_city} on map ${name_map}"
cd "${game[steam_cloud]}"
echo Avaliable saves:
ls *.crp -alh
echo
target_save=$(pick_a_file)

## 2. prepare git folder based on city and map name and copy save	
echo Copying to git folder, confirm overwrite, if you don\'t care to made a commit on last one
mkdir_if_none "${game[git_path]}"
cp -i "${game[steam_cloud]}"/${target_save} "${game[git_path]}"

## 2.1 specific for Cities Skylines, remind about $modlistname.xml along with the saves
# so others can load the save with all the required mods
ModsList_path="${game[savegames_path]}"/Addons/Mods/ModsList/ModsList_savefiles
# if it does not exist though, ignore it
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

## 3. run editor for README.md(mayor_log.md) and totalcmd for screenshots
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

# 5. see if user already created screens/timelapse folder in ${game[backup_path]}" to do timelapse
if [ -d "${game[backup_path]}"/screens/timelapse ]
	then 
	camera_positions=$(ls "${game[backup_path]}"/screens/timelapse)
	echo You currently have saved these camera positions: ${camera_positions}
	read -p "Do you want to update timelapse for each one? [y/n]" if_to_do_timelapse
	if [ "$if_to_do_timelapse" = "y" ]
		# go to each folder, run ffmpeg to create timelapse
		then for camera in ${camera_positions}
			do cd "${game[backup_path]}"/screens/timelapse/${camera}
			# input is raw jpg, output is timelapse, -y to overwrite
			# -f = fmt (input/output) - forces image2pipe
			# -r = fps, framerate, 1 for one screen per second
			# -vcodec 1, pick mjpeg as codec, probably for input
			# -i, input from -, the pipe, I guess!
			# -vcodec 2,pick libx264, probably for output
			cat *.jpg | ${ffmpegbin} -f image2pipe -r 1 -vcodec mjpeg -i - -vcodec libx264 -y timelapse.mp4
			done
    elif [ "$if_to_do_timelapse" = "n" ]
        then echo ok
	fi
fi

# 5. throw user to git folder so git work can be done
echo "now do git magic! commit and push"
cd "${game[git_path]}"