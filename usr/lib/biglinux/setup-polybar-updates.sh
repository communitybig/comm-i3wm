#!/bin/bash

# Script para configurar o módulo de atualizações da polybar para novos usuários
# Deve ser executado durante a primeira inicialização

# Definir variáveis
USER_HOME="$HOME"
CONFIG_DIR="$USER_HOME/.config/polybar"
SYSTEMD_DIR="$USER_HOME/.config/systemd/user"

# Garantir que os diretórios existam
mkdir -p "$CONFIG_DIR"
mkdir -p "$SYSTEMD_DIR"

# Tornar os scripts executáveis
chmod +x "$CONFIG_DIR/updates-check.sh"
chmod +x "$CONFIG_DIR/updates-install.sh"

# Verificar se o serviço e timer já existem
if [ ! -f "$SYSTEMD_DIR/updates-check.service" ]; then
    # Copiar e ativar o serviço e timer
    cp /etc/skel/.config/systemd/user/updates-check.service "$SYSTEMD_DIR/"
    cp /etc/skel/.config/systemd/user/updates-check.timer "$SYSTEMD_DIR/"
    
    # Recarregar os serviços do systemd
    systemctl --user daemon-reload
    
    # Ativar e iniciar o timer
    systemctl --user enable updates-check.timer
    systemctl --user start updates-check.timer
    
    # Executar a verificação inicial
    "$CONFIG_DIR/updates-check.sh" check &
fi

# Verificar se o módulo já está na configuração da polybar
if [ -f "$CONFIG_DIR/config" ]; then
    if ! grep -q "\[module/updates\]" "$CONFIG_DIR/config"; then
        # Adicionar o módulo ao final do arquivo
        cat << 'EOF' >> "$CONFIG_DIR/config"

[module/updates]
type = custom/script
exec = ~/.config/polybar/updates-check.sh
interval = 600
click-left = ~/.config/polybar/updates-install.sh
click-right = ~/.config/polybar/updates-check.sh check
format-padding = 1
EOF
        
        # Adicionar o módulo à barra principal
        # Isso é um pouco mais complicado porque precisamos encontrar a linha de módulos
        if grep -q "^modules-right = " "$CONFIG_DIR/config"; then
            # Adicionar à lista de módulos à direita
            sed -i 's/^modules-right = \(.*\)/modules-right = \1 updates/' "$CONFIG_DIR/config"
        elif grep -q "^modules-left = " "$CONFIG_DIR/config"; then
            # Adicionar à lista de módulos à esquerda se não encontrar à direita
            sed -i 's/^modules-left = \(.*\)/modules-left = \1 updates/' "$CONFIG_DIR/config"
        fi
        
        # Reiniciar a polybar se estiver em execução
        if pgrep -x polybar > /dev/null; then
            polybar-msg cmd restart
        fi
    fi
fi

# Marcar como configurado
touch "$USER_HOME/.config/.polybar_updates_configured"
