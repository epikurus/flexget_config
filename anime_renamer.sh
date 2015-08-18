#!/bin/bash
#
# Uses kiara to rename anime files according to anidb.net:
# https://github.com/hartfelt/kiara/
#
#Basic Settings
bin="/usr/local/bin/kiara"
args="--organize --overwrite --brief"
animeList="/var/tmp/anime_rename.txt"

get_anime_list() {
  #Define the internal field separator to CR and LF so that the array elements are full lines
  IFS=$'\r\n'
  array=( $(cat $animeList) )
  #Restore the IFS to bash default (space)
  IFS=$' '
}

###MAIN EXECUTION

get_anime_list

#Check if array has contents before anything...
if [[ ${#array[@]} -eq 0 ]]; then
  echo "No entries in file, nothing to do."
  exit 1
fi

#...Since it does, do what must be done
for line in ${!array[*]}; do
  #Move array line to tmp var to make code easier to read
  path="${array[$line]}"
  #Escape \, /, & and [] because of sed
  path_safe=$(echo $path | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g' -e 's/\[/\\[/g' -e 's/\]/\\]/g')

  #Check if file exists or not, to avoid errors from the program and get more accurate condition checks later on
  if [[ -e "$path" ]]; then
      echo "Renaming: $path"
      #Call the program to rename the file
      $bin $args "$path"

      #Do things if it was renamed and if not
      if [[ -e "$path" ]]; then
          echo "File still exists. Either Kiara failed or the file does not exist in aniDB yet"
          #TODO: Introduce some sort of number of tries/blacklist system
      else
          #File does not exist anymore, so it must have been renamed successfully
          echo "File renamed successfully"
          #Remove the file that was renamed from the anime list file
          sed -i "/$path_safe/d" $animeList
      fi
  else
      #File does not exist, remove it from the list file
      echo "File does not exist, removing entry."
      #Remove the file that was renamed from the anime list file
      sed -i "/$path_safe/d" $animeList
  fi
done

#Kill kiara backend, since it does nothing after renaming
$bin --kill

exit 0
