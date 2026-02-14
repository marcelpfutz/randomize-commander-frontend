# 🚀 Guia Rápido de Deploy - Frontend (Angular)

## 📋 Pré-requisitos

1. ✅ Instância EC2 criada (t3.small + Ubuntu 22.04) - **mesma do backend**
2. ✅ Chave SSH baixada (`.pem`)
3. ✅ Backend já deployado e funcionando
4. ✅ IP público anotado

---

## 🎯 Deploy em 3 Passos

### **Passo 1: Build da Aplicação** 🏗️

```bash
# No seu computador
cd /home/marcel/projetos/randomize-commander-frontend

# Ajuste a URL da API no environment.production.ts
# Edite: src/environments/environment.production.ts
# Altere apiUrl para: 'http://SEU-IP:8000/api' ou 'http://SEU-IP/api' (se usar nginx)

# Build de produção
npm run build
```

**Tempo estimado**: 1-2 minutos

---

### **Passo 2: Deploy Automatizado** 🎈

```bash
# No seu computador
./deploy/deploy-frontend.sh ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190
```

**Tempo estimado**: 1-2 minutos

✅ **Pronto!** Seu frontend está rodando em `http://SEU-IP/`

---

### **Passo 3: Configurar SSL (Opcional)** 🔒

```bash
# Conecte ao servidor
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190

# Configure SSL com Let's Encrypt (precisa ter um domínio)
sudo certbot --nginx -d seu-dominio.com

# Teste
curl https://seu-dominio.com
```

---

## 🔄 Atualizações Futuras

```bash
# 1. Rebuild
npm run build

# 2. Deploy rápido
./deploy/quick-deploy-frontend.sh ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190
```

---

## 🛠️ Comandos Essenciais

### Ver status do Nginx
```bash
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 "sudo systemctl status nginx"
```

### Ver logs do Nginx
```bash
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 "sudo tail -f /var/log/nginx/access.log"
```

### Reiniciar Nginx
```bash
ssh -i ~/.ssh/note-pessoal.pem ubuntu@34.232.80.190 "sudo systemctl restart nginx"
```

### Testar site
```bash
curl http://34.232.80.190/
```

---

## 🔧 Configurações Importantes

### 1. URL da API (IMPORTANTE!)

Antes do build, edite `src/environments/environment.production.ts`:

```typescript
export const environment = {
  production: true,
  apiUrl: 'http://34.232.80.190/api',  // ← IP do backend
  appVersion: '1.0.0',
};
```

**Com domínio:**
```typescript
apiUrl: 'https://api.seu-dominio.com'
```

### 2. Atualizar CORS no Backend

Lembre-se de atualizar o CORS no backend (`app/main.py`):

```python
allow_origins=[
    "http://localhost:4200",
    "http://34.232.80.190",  # ← IP do frontend
    "https://seu-dominio.com"  # ← Seu domínio
],
```

---

## 📊 Estrutura no Servidor

```
/var/www/randomize-commander-frontend/
└── dist/
    └── browser/
        ├── index.html
        ├── main-*.js
        ├── polyfills-*.js
        └── styles-*.css
```

---

## ⚠️ Troubleshooting

### Site não carrega?
```bash
# Verificar Nginx
sudo systemctl status nginx
sudo nginx -t

# Ver logs
sudo tail -f /var/log/nginx/error.log
```

### Erro 404 ao recarregar?
Nginx já está configurado com `try_files` para SPA.

### API não responde?
```bash
# Testar API diretamente
curl http://localhost:8000/api/commander

# Verificar CORS no backend
# Edite app/main.py e adicione a origem do frontend
```

### Erros de build?
```bash
# Limpar e rebuild
rm -rf dist/ node_modules/
npm install
npm run build
```

---

## 🌐 Arquitetura de Deploy

```
Internet
    ↓
[Nginx :80] ← Serve frontend estático
    ↓
    ├── / → Frontend Angular (SPA)
    └── /api → Proxy para Backend :8000
```

---

## 💰 Custos

Usando a **mesma instância EC2** do backend:
- Sem custos adicionais! ✅
- Total: ~$20/mês (compartilhado backend + frontend)

---

## 🎉 Checklist de Deploy

- [ ] Backend deployado e funcionando
- [ ] `environment.production.ts` configurado com IP correto
- [ ] Build de produção executado (`npm run build`)
- [ ] Deploy executado com sucesso
- [ ] Site acessível via navegador
- [ ] API respondendo corretamente
- [ ] CORS configurado no backend
- [ ] (Opcional) SSL configurado

---

## 📚 Documentação Completa

- **Deploy detalhado**: `DEPLOY_FRONTEND_AWS.md`
- **Scripts**: `deploy/README.md`

---

## 🔗 URLs Importantes

- **Frontend**: `http://34.232.80.190/`
- **Backend API**: `http://34.232.80.190/api/`
- **Health Check**: `http://34.232.80.190/api/`

---

## ❓ Dúvidas?

1. Veja logs do Nginx: `sudo tail -f /var/log/nginx/error.log`
2. Teste a API: `curl http://localhost:8000/api/commander`
3. Consulte `DEPLOY_FRONTEND_AWS.md` para detalhes
