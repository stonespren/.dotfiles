#!/bin/bash

function ask_yes_no {
  while true; do
    read -p "$1 (y/n): " yn
    case $yn in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

if ask_yes_no "Do you want to DELETE the Downloads Directory and link it to /storage?"; then
  rm -rf /home/$USER/Downloads
  ln -s /storage/Downloads /home/$USER
fi

if ask_yes_no "Do you want to DELETE the Pictures Directory and link it to /storage?"; then
  rm -rf /home/$USER/Pictures
  ln -s /storage/Pictures /home/$USER
fi


if ask_yes_no "Do you want to DELETE zen profiles and link them to /storage?"; then
  rm -rf /home/$USER/.zen
  ln -s /storage/.zen /home/$USER
  rm -rf /home/$USER/.cache/zen
  ln -s /storage/.cache/zen /home/$USER/.cache
fi
