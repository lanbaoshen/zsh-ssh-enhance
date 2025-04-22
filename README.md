# zsh-ssh-enhance
Using `sshpass` to better handle `ssh` password autofill

## Installation

## Oh My Zsh
Make sure you have [sshpass](https://sourceforge.net/projects/sshpass/) installed.

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

### Password autofill
Just configure the `#Password` in the `~/.ssh/config`, then use `ssh` as usual. 

This plugin will determine whether to use `sshpass`.

`~/.ssh/config` example:
```
Host Worker0
    Hostname 0.0.0.0
    User lanbaoshen

Host Worker1
    Hostname 1.1.1.1
    User lanbaoshen
    #Password 12345678
```
