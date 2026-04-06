#!/bin/bash

SESSION_NAME="main"

# Get VM IP address (ens160 interface for VMware)
IP_INFO=$(ip -4 addr show ens160 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Prepare IP display message with colors and ASCII art
IP_MESSAGE="clear && printf '\033[0;36m
                  ⠀⠀⠀⠀⠀⠀⡶⠶⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣤⠀⠀⠀⠀
                  ⠀⠀⠀⠀⠀⠀⣷⣿⣦⠙⠿⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⠾⠛⣉⣉⢹⡇⠀⠀⠀
                  ⠀⠀⠀⠀⠀⠀⣿⣻⣿⣷⡄⠨⠛⠛⠛⣹⣿⠿⠛⠛⠶⢶⣤⣴⡿⠋⢀⣴⣾⣿⡿⢸⠇⠀⠀⠀
                  ⠀⠀⠀⠀⠀⠀⠹⣜⣿⡿⠃⠀⠀⠀⠸⠋⠀⠀⠀⠀⠀⠀⠈⠛⠀⣰⣿⣿⣿⣿⠇⣾⠀⠀⠀⠀
                  ⠀⠀⠀⠀⠀⠀⢀⣿⢯⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⠟⣸⠏⠀⠀⠀⠀
                  ⠀⠀⠀⠀⢀⣴⡟⢁⣼⣿⣷⡀⠀⡄⠀⠀⠀⣠⣤⣤⣤⣀⠀⠀⠀⠀⠀⠻⣯⣴⠋⠀⠀⠀⠀⠀
                  ⠀⠀⢀⣴⡿⠋⣰⣿⣿⠿⠙⣿⣴⠇⢀⣤⣾⣿⣿⣿⣿⣦⣉⠁⠀⠀⠀⠀⠘⢿⣄⠀⠀⠀⠀⠀
                  ⠀⣠⣿⠟⠢⣼⣿⣿⣿⢀⣿⣿⣿⣴⣿⣿⡟⠁⢠⣬⣿⣿⣿⣷⣦⡀⠀⠀⠀⠈⢻⣦⠀⠀⠀⠀
                  ⠸⢿⣷⡆⠀⢿⣿⣿⠿⣿⣿⣿⡿⠿⠿⣿⣷⣄⣐⣿⣿⣿⣿⣿⣿⣿⡷⠂⠀⠀⠀⠹⣷⡀⠀⠀
                  ⠀⠀⠙⢿⣄⣴⣾⣷⣿⣿⡉⠀⠀⠀⠘⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠹⣿⡄⠀
                  ⠀⠀⠀⠈⠻⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠈⠙⠿⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⢑⣶⣶⣿⡿⠆
                  ⠀⠀⠀⠀⠀⠘⢿⣧⣤⡀⠀⠀⠀⠀⢀⣶⣤⣀⡀⠀⠈⠉⠀⠀⠀⠀⠀⣀⣤⣶⡿⠟⠉⠀⠀⠀
                  ⠀⠀⠀⠀⠀⠀⠀⠛⣿⣿⡿⠶⠶⠿⠛⠉⠀⢀⣀⣤⣀⣀⣤⣤⣶⠾⠿⠛⠋⠁⠀⠀⠀⠀⠀⠀
                  ⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠿⣶⣶⣤⣶⠶⠟⠛⠛⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
\033[0m
\033[0;36m         ╔══════════════════════════════════════════════════════╗
         ║                                                      ║
         ║                  \033[1;37mTMUX SESSION READY\033[0;36m                  ║
         ║                                                      ║
         ╚══════════════════════════════════════════════════════╝
\033[0m
         \033[1;33mSSH Connection:\033[0m
            \033[0;32mssh $(whoami)@$IP_INFO\033[0m

         \033[1;33mAttach Command:\033[0m
            \033[0;35mtmux attach -t $SESSION_NAME\033[0m

\033[0;36m         ───────────────────────────────────────────────────────────\033[0m
\033[0m
'"

# Check if session already exists
tmux has-session -t $SESSION_NAME 2>/dev/null

if [ $? != 0 ]; then
    # Create new session
    tmux new-session -d -s $SESSION_NAME

    # Split window vertically (creates left and right panes)
    tmux split-window -h -t $SESSION_NAME

    # Select the right pane and split it horizontally
    tmux select-pane -t 1
    tmux split-window -v

    # Wait for shell to initialise before sending welcome message
    sleep 1
    tmux send-keys -t 0 "$IP_MESSAGE" Enter

    # Select the left pane (pane 0)
    tmux select-pane -t 0
fi

# Attach to session
tmux attach-session -t $SESSION_NAME
