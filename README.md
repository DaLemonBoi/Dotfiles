# Dotfiles

These are my dotfiles. Use them as you wish.

### Depends on

.zshrc (/home/lemon/.zshrc & /root/.zshrc) requires:

[Zsh shell](http://www.zsh.org/)

### Installing

First I highly suggest looking through the dotfiles see if anything you want to remove or modify.

TAKE NOTE THIS WILL DELETE ANY FILES IF THEY HAVE THE SAME PATH AS THOSE IN THE ROOTFS FOLDER

first rename the normal user home directory in /home to your normal user home directory's name with the mv command

```
mv home/lemon [YOUR NORMAL USER]
```

now mv the rootfs contents to your / with root privileges 

```
mv rootfs/* /
```

you may need to restart or at least relogin for changes to take effect
