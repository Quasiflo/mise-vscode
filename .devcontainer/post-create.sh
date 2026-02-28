#!/usr/bin/env bash
echo "Fixing permissions on mounted volumes ..."
sudo chown -R vscode:vscode /mnt/mise-data /home/vscode/.local

echo "Configuring zsh ..."
cat >> ~/.zshrc << 'EOF'
eval "$(mise activate zsh)" # Enables Mise in shells
EOF

echo "Post-create setup finished."