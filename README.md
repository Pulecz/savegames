# Savegames

Save and share your savegames to git for others to use and see the progress

* Cities Skylines
	
Idea is to use one savegame per branch, which will get overwritten with each commit.

Instead of commit_msg a mayor_log.md is used to log what happened to the city.
These mods are recommended to make timelapse_like screenshots:

* [Camera Positions Utility (ID=898480258)](https://steamcommunity.com/sharedfiles/filedetails/?id=898480258)
* [HideUI (ID=406326408)](https://steamcommunity.com/sharedfiles/filedetails/?id=406326408)

Helper bash script is ready for loading ssh-key related to github and copying .crp to git and .xml of ModList if you have mod [Mods Listing (ID=588691634)](http://steamcommunity.com/sharedfiles/filedetails/?id=588691634).

It makes you to write you some mayolor_log.md

Then it opens TotalCommander with left panel on new screenshots made by game and your backup folder, which is probably some folder in google drive folder so new screens can be uploaded.

Just make sure to edit/verify [these few variables](https://github.com/Pulecz/savegames/blob/master/git_savegames_helper_cs.sh#L11)

For the script you will need [cmder](http://cmder.net/)
You will also need [these scripts](https://github.com/Pulecz/dotfiles/tree/master/Windows) and in init_bash.bat you will just change the bash script name.

I should do video on it anyway.

## Planned:
RimWorld
