#!/bin/bash +x
#
# Uses kiara to rename and organize anime files:
# https://github.com/hartfelt/kiara/
#
#Basic Settings
EXEC="/usr/local/bin/kiara"
ARGS=" --organize --overwrite --brief"
ANIMELIST="/var/tmp/anime_rename.txt"

get_anime_list() {
  #Define the internal field separator to CR and LF so that the array elements are full lines
  IFS=$'\r\n'
  array=( $(cat $ANIMELIST) )
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
  TMP="${array[$line]}"
  #Escape \, / and & because of sed
  TMP_SAFE=$(echo $TMP | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')

  #Check if file exists or not, to avoid errors from the program and get more accurate condition checks later on
  if [[ -e "$TMP" ]]; then
      echo "Renaming: $TMP"
      #Call the program to rename the file
      $EXEC $ARGS "$TMP"

      #Do things if it was renamed and if not
      if [[ -e "$TMP" ]]; then
          echo "File still exists. Either Kiara failed or the file does not exist in aniDB yet"
          #TODO: Introduce some sort of number of tries/blacklist system
      else
          #File does not exist anymore, so it must have been renamed successfully
          echo "File renamed successfully"
          #Remove the file that was renamed from the anime list file
          sed -i "/$TMP_SAFE/d" $ANIMELIST
      fi
  else
      #File does not exist, remove it from the list file
      echo "File does not exist, removing entry."
      #Remove the file that was renamed from the anime list file
      sed -i "/$TMP_SAFE/d" $ANIMELIST
  fi
done

#Kill kiara backend, since it does nothing after renaming
/usr/local/bin/kiara --kill

exit 0
