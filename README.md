# zsh-ssh-enhance
Support `ssh` selector and using `sshpass` to better handle `ssh` & `scp` password autofill

## Installation

## Oh My Zsh
1. Clone this repository into `$ZSH_CUSTOM/plugins` (by default `~/.oh-my-zsh/custom/plugins`)
```shell
git clone https://github.com/lanbaoshen/zsh-ssh-enhance.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-ssh-enhance
```

2. Add the plugin to the list of plugins for Oh My Zsh to load (inside `~/.zshrc`):
```
plugins=(zsh-ssh-enhance $plugins)
```

3. Start a new terminal session.


## Manual (Git Clone)

1. Clone this repository somewhere on your machine. For example: `~/.zsh/zsh-ssh-enhance`.
```shell
git clone https://github.com/lanbaoshen/zsh-ssh-enhance.git ~/.zsh/zsh-ssh-enhance
```

2. Add the following to your `.zshrc`:
```
source ~/.zsh/zsh-ssh-enhance/zsh-ssh-enhance.zsh
```

3. Start a new terminal session.


## Feature

### SSH Selector
Make sure you have [fzf](https://github.com/junegunn/fzf) installed.

Type `ssh` and hit `Enter` to run a bare `ssh` command with no arguments.

This plugin shows a list of hosts from `~/.ssh/config`, which you can navigate with arrow keys or mouse to connect.

### Password Autofill
Make sure you have [sshpass](https://sourceforge.net/projects/sshpass/) installed.

Just configure the `#Password` in the `~/.ssh/config`, then use `ssh` & `scp` as usual. 

This plugin will determine whether to use `sshpass`.

`~/.ssh/config` example:
```
Host Worker0
    HostName 0.0.0.0
    User lanbaoshen

Host Worker1
    HostName 1.1.1.1
    User lanbaoshen
    #Password 12345678
```
