# Deploy do Frontend Angular na AWS

## 📋 Visão Geral

Este guia detalha o processo de deploy do frontend Angular na mesma instância EC2 onde o backend está rodando, usando Nginx para servir os arquivos estáticos e fazer proxy para a API.

---

## 🏗️ Arquitetura

```
Internet → [EC2 Instance] 
              ├── Nginx :80 (Frontend + Proxy)
              │   ├── / → Frontend Angular (arquivos estáticos)
              │   └── /api → Proxy → Backend :8000
              └── Python/Uvicorn :8000 (Backend API)
```

---

## 📦 Pré-requisitos

1. **Backend deployado e funcionando** na mesma instância
2. **Node.js instalado localmente** para build
3. **Nginx instalado no servidor** (já foi instalado no setup do backend)
4. **Chave SSH** da instância EC2

---

## 🚀 Processo de Deploy

### 1. Configurar URL da API

Antes de fazer o build, configure a URL da API em produção:

**Edite:** `src/environments/environment.production.ts`

```typescript
export const environment = {
  production: true,
  apiUrl: 'http://SEU-IP/api',  // ou https://seu-dominio.com/api
  appVersion: '1.0.0',
};
```

**Exemplos:**

```typescript
// Com IP público
apiUrl: 'http://34.232.80.190/api'

// Com domínio
apiUrl: 'https://api.seu-dominio.com'

// Nginx proxy na mesma origem
apiUrl: '/api'  // Recomendado!
```

**💡 Recomendação:** Use `/api` (caminho relativo) quando frontend e backend estão no mesmo domínio/IP. Isso evita problemas de CORS.

---

### 2. Build de Produção

```bash
cd /home/marcel/projetos/randomize-commander-frontend

# Instalar dependências (se necessário)
npm install

# Build de produção
npm run build

# Verificar se o build foi criado
ls -la dist/browser/
```

O build será criado em `dist/browser/` com arquivos otimizados e minificados.

---

### 3. Deploy Automatizado

```bash
# Execute o script de deploy
./deploy/deploy-frontend.sh ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190
```

**O script irá:**
1. ✅ Verificar se o build existe
2. ✅ Conectar ao servidor
3. ✅ Criar diretório `/var/www/randomize-commander-frontend`
4. ✅ Fazer backup da versão anterior
5. ✅ Copiar arquivos do build
6. ✅ Configurar Nginx
7. ✅ Recarregar Nginx
8. ✅ Verificar se o site está acessível

---

### 4. Verificação

```bash
# Testar o frontend
curl http://SEU-IP/

# Testar a API via proxy
curl http://SEU-IP/api/commander

# Acessar no navegador
# http://SEU-IP/
```

---

## 🔄 Atualizações

### Deploy Completo (após mudanças significativas)

```bash
# 1. Rebuild
npm run build

# 2. Deploy completo
./deploy/deploy-frontend.sh ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190
```

### Deploy Rápido (apenas arquivos)

```bash
# 1. Rebuild
npm run build

# 2. Deploy rápido
./deploy/quick-deploy-frontend.sh ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190
```

---

## ⚙️ Configuração do Nginx

O Nginx serve o frontend e faz proxy para o backend:

**Arquivo:** `/etc/nginx/sites-available/randomize-frontend`

```nginx
server {
    listen 80;
    root /var/www/randomize-commander-frontend/dist;
    index index.html;
    
    # Frontend Angular (SPA)
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Proxy para Backend API
    location /api/ {
        proxy_pass http://127.0.0.1:8000/api/;
        # ... headers e configurações
    }
}
```

---

## 🔧 Comandos Úteis

### Gerenciar Nginx

```bash
# Status
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "sudo systemctl status nginx"

# Reiniciar
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "sudo systemctl restart nginx"

# Recarregar (sem downtime)
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "sudo systemctl reload nginx"

# Testar configuração
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "sudo nginx -t"
```

### Ver Logs

```bash
# Logs de acesso
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "sudo tail -f /var/log/nginx/randomize-frontend-access.log"

# Logs de erro
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "sudo tail -f /var/log/nginx/randomize-frontend-error.log"
```

### Verificar Arquivos

```bash
# Listar arquivos deployados
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "ls -lah /var/www/randomize-commander-frontend/dist/"

# Verificar tamanho
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "du -sh /var/www/randomize-commander-frontend/"
```

---

## 🐛 Troubleshooting

### Site não carrega (404)

**Causa:** Nginx não está servindo os arquivos corretos

**Solução:**
```bash
# Verificar se os arquivos existem
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "ls -la /var/www/randomize-commander-frontend/dist/"

# Verificar configuração do Nginx
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "sudo nginx -t"

# Ver logs de erro
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "sudo tail -f /var/log/nginx/error.log"
```

---

### Erro 404 ao recarregar página

**Causa:** Nginx não está redirecionando rotas do Angular para `index.html`

**Solução:** A configuração já inclui `try_files $uri $uri/ /index.html;`

Se ainda der erro:
```bash
# Verificar configuração
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "cat /etc/nginx/sites-available/randomize-frontend | grep try_files"
```

---

### API não responde

**Causa:** Proxy do Nginx não está funcionando ou backend está offline

**Solução:**
```bash
# Testar backend diretamente
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "curl http://localhost:8000/api/commander"

# Verificar status do backend
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "sudo systemctl status randomize-backend"

# Reiniciar backend se necessário
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 \
  "sudo systemctl restart randomize-backend"
```

---

### Erros de CORS

**Causa:** Backend não está aceitando requisições do frontend

**Solução:** Atualize `app/main.py` no backend:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:4200",
        "http://34.232.80.190",  # Adicione o IP
        "https://seu-dominio.com"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

Depois faça deploy do backend novamente:
```bash
cd /home/marcel/projetos/randomize-commander-backend
./deploy/quick-deploy.sh ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190
```

---

### Build com erros

**Causa:** Dependências desatualizadas ou problemas no código

**Solução:**
```bash
# Limpar e reinstalar
rm -rf node_modules/ dist/
npm install

# Tentar build novamente
npm run build

# Se persistir, verificar erros específicos
npm run build -- --verbose
```

---

## 🔒 Configurar SSL (HTTPS)

### Pré-requisitos

1. Ter um **domínio** apontando para o IP da instância EC2
2. Certbot instalado (já foi instalado no setup do backend)

### Passos

```bash
# 1. Conectar ao servidor
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190

# 2. Editar configuração do Nginx e adicionar seu domínio
sudo nano /etc/nginx/sites-available/randomize-frontend
# Altere: server_name seu-dominio.com;

# 3. Testar e recarregar
sudo nginx -t
sudo systemctl reload nginx

# 4. Obter certificado SSL
sudo certbot --nginx -d seu-dominio.com

# 5. Testar renovação automática
sudo certbot renew --dry-run
```

### Atualizar URL da API

Depois de configurar SSL, atualize `environment.production.ts`:

```typescript
apiUrl: 'https://seu-dominio.com/api'
```

Rebuild e faça deploy novamente.

---

## 📊 Estrutura de Diretórios

### No Servidor

```
/var/www/randomize-commander-frontend/
├── dist/
│   ├── index.html
│   ├── main-[hash].js
│   ├── polyfills-[hash].js
│   ├── styles-[hash].css
│   └── ...
└── nginx-frontend.conf
```

### Localmente

```
randomize-commander-frontend/
├── deploy/
│   ├── deploy-frontend.sh
│   ├── quick-deploy-frontend.sh
│   ├── nginx-frontend.conf
│   └── README.md
├── dist/
│   └── browser/  ← Build de produção
├── src/
│   └── environments/
│       ├── environment.ts
│       └── environment.production.ts
└── package.json
```

---

## 🎯 Checklist de Deploy

- [ ] Backend deployado e funcionando
- [ ] `environment.production.ts` configurado
- [ ] Build de produção executado (`npm run build`)
- [ ] Deploy executado com sucesso
- [ ] Site acessível no navegador
- [ ] API respondendo corretamente
- [ ] Rotas do Angular funcionando (testar navegação)
- [ ] CORS configurado no backend
- [ ] (Opcional) SSL configurado

---

## 💰 Custos

**Usando a mesma instância EC2 do backend:**
- Sem custos adicionais! ✅
- **Total:** ~$20/mês (backend + frontend juntos)

---

## 🔗 Recursos

- [Angular Deployment](https://angular.io/guide/deployment)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Let's Encrypt](https://letsencrypt.org/)

---

## 📞 Suporte

Para problemas:
1. Verifique logs: `sudo tail -f /var/log/nginx/error.log`
2. Teste a API: `curl http://localhost:8000/api/commander`
3. Verifique status: `sudo systemctl status nginx`
