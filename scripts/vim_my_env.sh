#!/bin/bash

if tmux attach -t nvim;
then
    tmux a -t nvim
else
    tmux new-session -A -s nvim
fi


