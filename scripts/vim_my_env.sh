#!/bin/bash

if tmux attach -t tide; then
    tmux a -t tide
else
    tmux new-session -A -s tide
    # Crea una nuova finestra per nvim
    tmux new-window -n "tide" "nvim"
    # Crea una nuova finestra per lazygit
    tmux new-window -n "tide" "lazygit"
    # Crea una nuova finestra per il terminale
    tmux new-window -n "tide" "term"
    # Seleziona la finestra nvim come finestra attiva
    tmux select-window -t "nvim"
fi
