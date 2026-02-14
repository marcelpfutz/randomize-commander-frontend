#!/bin/bash

# Script de Deploy - Randomize Commander Frontend (Angular)
# Uso: ./deploy-frontend.sh <chave.pem> <usuario@ip-servidor>
# Exemplo: ./deploy-frontend.sh minha-chave.pem ubuntu@34.232.80.190

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Verificar argumentos
if [ "$#" -ne 2 ]; then
    print_error "Uso: $0 <chave.pem> <usuario@ip-servidor>"
    print_error "Exemplo: $0 minha-chave.pem ubuntu@54.123.456.789"
    exit 1
fi

SSH_KEY=$1
SERVER=$2
APP_DIR="/var/www/randomize-commander-frontend"
NGINX_CONF="randomize-frontend"

# Determinar diretório do projeto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$PROJECT_DIR/dist/browser"

# Verificar se a chave SSH existe
if [ ! -f "$SSH_KEY" ]; then
    print_error "Arquivo de chave SSH não encontrado: $SSH_KEY"
    exit 1
fi

chmod 400 "$SSH_KEY"

print_info "======================================"
print_info "Deploy - Randomize Commander Frontend"
print_info "======================================"
print_info "Servidor: $SERVER"
print_info "Diretório: $APP_DIR"
print_info ""

# Verificar se o build existe
if [ ! -d "$DIST_DIR" ]; then
    print_error "Diretório de build não encontrado: $DIST_DIR"
    print_error "Execute 'npm run build' antes de fazer o deploy"
    exit 1
fi

print_info "Build encontrado: $DIST_DIR"

# Verificar conexão SSH
print_step "Testando conexão SSH..."
if ! ssh -i "$SSH_KEY" -o ConnectTimeout=10 "$SERVER" "echo 'Conexão OK'" > /dev/null 2>&1; then
    print_error "Falha ao conectar ao servidor"
    exit 1
fi
print_info "Conexão SSH estabelecida com sucesso!"

# Criar diretório da aplicação
print_step "Criando diretório da aplicação..."
ssh -i "$SSH_KEY" "$SERVER" "sudo mkdir -p $APP_DIR && sudo chown \$(whoami):\$(whoami) $APP_DIR"

# Fazer backup da versão anterior
print_step "Fazendo backup da versão anterior..."
ssh -i "$SSH_KEY" "$SERVER" "
    if [ -d '$APP_DIR/dist' ]; then
        BACKUP_DIR=\$HOME/backups/frontend-\$(date +%Y%m%d-%H%M%S)
        mkdir -p \$HOME/backups
        cp -r $APP_DIR/dist \$BACKUP_DIR
        echo 'Backup criado em: \$BACKUP_DIR'
    else
        echo 'Nenhum backup necessário (primeira instalação)'
    fi
"

# Copiar arquivos do build
print_step "Copiando arquivos do build..."
rsync -avz --delete -e "ssh -i $SSH_KEY" \
    "$DIST_DIR/" "$SERVER:$APP_DIR/dist/"

# Copiar configuração do Nginx
print_step "Copiando configuração do Nginx..."
scp -i "$SSH_KEY" "$SCRIPT_DIR/nginx-frontend.conf" "$SERVER:$APP_DIR/"

# Configurar Nginx
print_step "Configurando Nginx..."
ssh -i "$SSH_KEY" "$SERVER" << 'EOF'
    # Copiar configuração do Nginx
    sudo cp /var/www/randomize-commander-frontend/nginx-frontend.conf /etc/nginx/sites-available/randomize-frontend
    
    # Criar link simbólico se não existir
    if [ ! -L /etc/nginx/sites-enabled/randomize-frontend ]; then
        sudo ln -s /etc/nginx/sites-available/randomize-frontend /etc/nginx/sites-enabled/
    fi
    
    # Remover configuração default se existir
    if [ -L /etc/nginx/sites-enabled/default ]; then
        sudo rm /etc/nginx/sites-enabled/default
    fi
    
    # Testar configuração
    if sudo nginx -t; then
        echo "Configuração do Nginx OK!"
        sudo systemctl reload nginx
        echo "Nginx recarregado com sucesso!"
    else
        echo "ERRO: Configuração do Nginx inválida"
        exit 1
    fi
EOF

# Verificar se o site está acessível
print_step "Verificando se o site está acessível..."
sleep 2
if ssh -i "$SSH_KEY" "$SERVER" "curl -s http://localhost/ | grep -q 'randomize-commander' || curl -s http://localhost/ | head -n 1 | grep -q '<!doctype html>'" 2>/dev/null; then
    print_info "Site está acessível! ✓"
else
    print_warning "Não foi possível verificar se o site está acessível"
    print_warning "Tente acessar manualmente: http://SEU-IP/"
fi

print_info ""
print_info "======================================"
print_info "Deploy concluído com sucesso! ✓"
print_info "======================================"
print_info ""
print_info "🌐 Acesse seu site:"
print_info "   Frontend: http://$(echo $SERVER | cut -d'@' -f2)/"
print_info "   API:      http://$(echo $SERVER | cut -d'@' -f2)/api/"
print_info ""
print_info "📝 Comandos úteis:"
print_info "   Ver logs:      ssh -i $SSH_KEY $SERVER 'sudo tail -f /var/log/nginx/access.log'"
print_info "   Status Nginx:  ssh -i $SSH_KEY $SERVER 'sudo systemctl status nginx'"
print_info "   Reiniciar:     ssh -i $SSH_KEY $SERVER 'sudo systemctl restart nginx'"
print_info ""
print_warning "⚠️  Próximos passos recomendados:"
print_warning "1. Verifique se a API está respondendo corretamente"
print_warning "2. Teste todas as funcionalidades do site"
print_warning "3. Configure SSL com Let's Encrypt (se tiver domínio)"
print_warning "4. Atualize o CORS no backend com o IP/domínio correto"
print_info ""
