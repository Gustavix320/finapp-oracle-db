# FINAPP Oracle DB – Módulo de Títulos Financeiros

Este repositório contém **toda a modelagem em Oracle 21c XE** e o código **PL/SQL** do módulo de **títulos financeiros (contas a pagar e a receber)** do projeto **FINAPP**.

 # MVP em desenvolvimento

---

## Tecnologias utilizadas

- Oracle Database **21c XE**
- Schema dedicado: **FIN_APP**
- PL/SQL (Packages, Procedures, Functions)
- Índices e constraints otimizados para consultas financeiras
- Ferramentas:
  - Oracle SQL Developer
  - VS Code com extensão SQL

---

## Estrutura do projeto

```bash
finapp-oracle-db/
├── audit/                          # Estruturas de auditoria, logs e trilhas de acesso
│
├── ddl/                            # DDL: criação de tablespaces, schema, tabelas, views
│   ├── 01_tablespace.sql           # Tablespaces do sistema financeiro
│   ├── 02_user_schema.sql          # Criação do usuário FIN_APP e grants básicos
│   ├── 10_tabelas_basicas.sql      # Tabelas de domínio (cliente, fornecedor, parâmetros)
│   ├── 11_tabela_titulo.sql        # Tabela principal de títulos (contas a pagar/receber)
│   ├── 13_tb_titulo_pagamento.sql  # Tabela de pagamentos vinculados ao título
│   ├── 14_views_financeiro.sql     # Views do módulo financeiro (dashboard, listagem)
│   └── 15_views_fluxo_caixa.sql    # Views específicas do fluxo de caixa
│
├── dml/                                 # Carga inicial de dados
│   ├── 01_carga_inicial_parametros.sql  # Parâmetros globais e configurações
│   └── 02_dados_teste.sql               # Registros de teste para validação do sistema
│
├── integration/                    # Integração com APIs externas / HTTP / serviços
│   ├── pkg_integracao_api.pks      # Especificação do pacote de integração com API
│   ├── pkg_integracao_api.pkb      # Implementação do pacote
│   └── utl_http_config.sql         # Configuração de ACL e permissões de rede via UTL_HTTP
│
├── jobs/                           # Rotinas automáticas (background jobs / scheduler)
│   ├── job_atualiza_atrasados.sql  # Atualiza títulos atrasados diariamente
│   └── job_consolidacao_diaria.sql # Consolida dados para dashboard e relatórios
│
├── plsql/                          # Packages de regras de negócio
│   ├── pkg_cliente.pks             # Interface do package de clientes
│   ├── pkg_cliente.pkb             # Implementação
│   ├── pkg_titulo.pks              # Interface do package de títulos
│   └── pkg_titulo.pkb              # Implementação completa do módulo financeiro
│
├── security/                       # Segurança, roles, permissões, políticas
│   ├── grants_app.sql              # Permissões do aplicativo FIN_APP
│   ├── grants_relatorio.sql        # Permissões para usuários de BI/Relatórios
│   └── roles.sql                   # Definição de roles corporativas
│
└── README.md




