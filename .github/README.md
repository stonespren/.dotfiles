# stonspren's dotfiles

...and other computer setup stuff in this readme. 

<details>
  <summary>Debian (or debian-based distro)</summary>

  Run the `su` command and enter the password, then run the following commands:
  
  ```shell
  apt install neovim git
  nvim ../../etc/sudoers
  ```
  
  Under User privilege specification, copy the root line and replace `root` with your username. `wq!`
  
  ---

</details>

<details>
  <summary>Arch Linux</summary>

  ##### Connect to Wifi

  ```shell
  iwctl
  adapter list
  adapter "phy0" set-property Powered on
  station list
  station "wlan0" scan
  station "wlan0" get-networks
  station "wlan0" connect "network name"
  # enter passphrase
  # done, ctrl+c to exit 
  ```

  ##### Install Arch

  ```shell
  archinstall
  ```

  ---
  
</details>

### Dotfiles

In the home directory, run:

```shell
yadm clone https://github.com/stonespren/.dotfiles.git --bootstrap
```

Run `getnf` and pick fonts

In tmux, pres `prefix` + I to fetch plugins.

run `.config/custom/sshkey` to generate an sshkey and copy it to the clipboard
