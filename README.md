## Infrastructure as Code para app SpaManager

Consiste em configurações de **Proxy** e de **Banco de Dados**.

---

### Configurações de Proxy (NGINX)

Configuração do servidor de proxy **NGINX**, com:

- Arquivo de configuração do NGINX
- Certificados para funcionamento correto do **HTTPS**
- `Dockerfile` para montagem em caso de integração com **CI/CD**

**Detalhes do arquivo de configuração**

- Configurações básicas do servidor para estado *production-ready*
- Configurações de `location` → rotas que encaminham aos containers do aplicativo
- Configurações anti-DDOS e anti-abuso

---

### Configurações de Banco de Dados (PostgreSQL)

- Documentação sobre os comandos usados para criação do container do **PostgreSQL**, incluindo o caminho do `docker volume` que garante a persistência dos dados
- Informações sobre as configurações adotadas dentro do PostgreSQL
- Modelagem do banco de dados *as code*: comandos de criação das tabelas

