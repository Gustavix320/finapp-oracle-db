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

Sugestão de organização (ajuste conforme sua pasta real):

```bash
finapp-oracle-db/
├── ddl/                # Criação de tabelas, índices, sequences
│   ├── 01_tb_cliente.sql
│   ├── 02_tb_fornecedor.sql
│   ├── 03_tb_tipo_titulo.sql
│   └── 04_tb_titulo.sql
├── plsql/              # Packages e procedures
│   └── pkg_titulo.sql
├── dml/                # Inserts de teste (dados fake)
│   └── carga_inicial_titulos.sql
└── README.md


