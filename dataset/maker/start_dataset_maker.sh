#!/bin/bash

# Vérifier si VNC Server est en cours d'exécution
vncserver_pid=$(pgrep Xtightvnc)

if [ -z "$vncserver_pid" ]; then
    # Si VNC Server n'est pas en cours d'exécution, démarrez-le (assurez-vous qu'il est installé)
    echo "Starting VNC Server..."
    vncserver :1 -geometry 1920x1080 -depth 24  # Remplacez par la résolution souhaitée
else
    echo "VNC Server is already running."
fi

# Définir le chemin vers votre programme Python
python_script_path="/app/dataset/maker/Split_Master.py"

# Assurez-vous que votre programme Python est exécutable
chmod +x "$python_script_path"

# Exécutez votre programme Python dans l'environnement VNC (display :1)
echo "Running your Python program in the VNC environment..."
DISPLAY=:1 python3 "$python_script_path"

# Facultatif : arrêtez VNC Server après l'exécution de votre programme
# vncserver -kill :1  # Décommentez cette ligne si vous souhaitez arrêter VNC Server après l'exécution

echo "Script execution completed."
