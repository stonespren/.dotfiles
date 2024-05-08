# stonspren's dotfiles

...and other computer setup stuff in this readme. This assumes you've installed a Debian-based distribution.

### Add user to sudoers

Run the `su` command and enter the password, then run the following commands:

```shell
apt install neovim git
nvim ../../etc/sudoers
```

Under User privilege specification, copy the root line and replace `root` with your username. `wq!`

### Dotfiles

In the home directory, run:

```shell
git clone --bare https://github.com/stonespren/.dotfiles.git $HOME/.dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
dotfiles checkout
dotfiles config --local status.showUntrackedFiles no
```

If there are any errors with `checkout`, delete the conflicting files and try again.

### Packages

```shell
sudo apt install alacritty tmux xclip curl fontconfig
```

### fnm

docs: https://github.com/Schniz/fnm

```shell
curl -fsSL https://fnm.vercel.app/install | bash
```

### Zsh

```shell
sudo apt install zsh
chsh -s $(which zsh)
```

Log out and back in to see change.

#### Zap

Docs: https://github.com/zap-zsh/zap

```shell
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
```

The install script will create a new `.zshrc`. Go ahead and delete it and restore the old one.

Restart your terminal.

### Get Nerd Fonts

Docs: https://github.com/getnf/getnf

Make sure that `~/.local/bin` is in PATH (already in .zshrc) and `curl` and `fontconfig` are installed

```shell
curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash
```

Run `getnf` and pick fonts

### Tmux Plugin Manager

Docs: https://github.com/tmux-plugins/tpm

```shell
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

In tmux, pres `prefix` + I to fetch plugins.

### GitHub

```shell
ssh-keygen -t ed25519 -C "email_here"
```

Add .github to the file name

```shell
ssh-add ~/.ssh/id_ed25519.github
cat ~/.ssh/id_ed25519.github.pub | xclip -sel clip
```

Paste into GitHub.
