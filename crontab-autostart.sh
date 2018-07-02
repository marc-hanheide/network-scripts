#!/bin/bash

# this can be put in crontab as `@reboot PATH/crontab-autostart.sh`

SESSION=autostart-$USER

tmux new-session -d -s $SESSION || true
# Setup a window for tailing log files
tmux new-window -t $SESSION:0 -n 'ngrok' || true
tmux new-window -t $SESSION:1 -n 'tmule' || true

tmux select-window -t $SESSION:0
tmux send-keys  C-c
tmux send-keys  C-c
tmux send-keys "/home/iliad/.local/bin/ngrok start-all" C-m

tmux select-window -t $SESSION:1
tmux send-keys  C-c
tmux send-keys  C-c
tmux send-keys "# will start tmule" C-m 

# Set default window
tmux select-window -t $SESSION:0 

