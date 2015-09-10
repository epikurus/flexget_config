#!/bin/bash
#
# Uses kiara to rename anime files according to anidb.net:
# https://github.com/hartfelt/kiara/
#
###SETTINGS
bin="/usr/local/bin/kiara"
args="--organize --overwrite --brief"
animeListFile="/var/tmp/anime_rename.txt"

###MAIN EXECUTION

#Define the internal field separator to CR and LF so that the animeList elements are full lines
IFS=$'\r\n'
#Create an array with the contents of the file
animeList=( $(cat $animeListFile) )
#Restore the IFS to bash default (space)
IFS=$' '

#Check if animeList has contents before anything...
if [[ ${#animeList[@]} -eq 0 ]]; then
  echo "$(date '+%H:%M:%S') - No entries in file, nothing to do."
  exit 1
fi

#...Since it does, do what must be done
for line in ${!animeList[*]}; do
  #Move animeList line to tmp var to make code easier to read
  animePath="${animeList[$line]}"
  #Escape \, /, & and [] because of sed
  animePath_safe=$(echo $animePath | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g' -e 's/\[/\\[/g' -e 's/\]/\\]/g')
  #Split the path in multiple vars for later use
  animeDir=$(echo $animePath | grep -Eo '/.*/')
  animeName=$(echo $animePath | grep -Po '[^/]*(?=- ep.*)')
  animeId=$(echo $animePath | grep -Po '(?<=ep)[0-9]{1,3}')

  #Check if file exists or not, to avoid errors from the program and get more accurate condition checks later on
  if [[ -e "$animePath" ]]; then
    echo "$(date '+%H:%M:%S %d/%m/%Y') - Renaming: $animePath"
    #Call the program to rename the file
    $bin $args "$animePath"

    #Do things if it was renamed and if not
    if [[ $(ls "$animeDir" | grep $animeId | grep -E "[e,E]pisode|[u,U]nknown") ]]; then
      #Episode name contains the word episode or unknown, so it was not renamed properly
      echo "$(date '+%H:%M:%S') - File was not renamed properly! Episode probably does not have a name yet on aniDB."
    elif [[ -e "$animePath" ]]; then
      #Original file still exists, so it was not renamed
      echo "$(date '+%H:%M:%S') - File still exists with the same name. File probably does not exist in aniDB yet."
    else
      #File does not exist anymore, and does not match the first case, so it must have been renamed
      echo "$(date '+%H:%M:%S') - File renamed successfully to: $(ls "$animeDir" | grep $animeId)"
      #Remove the file that was renamed from the anime list file
      sed -i "/$animePath_safe/d" "$animeListFile"
    fi

  else
    #File does not exist, remove it from the list file
    echo "$(date '+%H:%M:%S %d/%m/%Y') - File does not exist, removing entry: $animePath"
    #Remove the file that was renamed from the anime list file
    sed -i "/$animePath_safe/d" "$animeListFile"
  fi
done

#Kill kiara backend, since it does nothing after renaming
$bin --kill

exit 0
