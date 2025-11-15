***Infrastructure as Code para app SpaManager***

Consiste em configuracoes de Proxy e de Banco de Dados

***Configuracoes de Proxy***

Configuracao do servidor de proxy NGINX, com arquivo de configuracao, certificados p/ funcionamento correto do HTTPS e dockerfile para montagem em caso de integracao com CI/CD

Detalhes do arquivo de configuração:

- Configuracoes basicas do servidor para estado production-ready
- Configuracoes de locations -> Rotas que encaminham aos containers do aplicativo
- Configuracoes anti DDOS e anti abuso

***Configuracoes de Banco de Dados***

- Documentacao sobre os comandos usados para criacao do container do PostgreSQL, incluindo caminho do docker volume que garante a persistencia dos dados
- Informacoes sobre as configuracoes adotadas dentro do PostgreSQL
- Modelagem do banco de dado as code: Comando de criacao das tabelas

