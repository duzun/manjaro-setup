#!/bin/sh
ssh-add < /dev/null

# Tip: The above ssh-add.sh script will only add the default key ~/.ssh/id_rsa.
# Assuming you have different SSH keys named key1, key2, key3 in ~/.ssh/,
# you may add them automatically on login by changing the above script to:
#
# ssh-add $HOME/.ssh/key1 $HOME/.ssh/key2 $HOME/.ssh/key3 </dev/null