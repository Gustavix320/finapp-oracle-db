-- Tabela para tipo de pessoa (PF ou PJ)
CREATE TABLE tb_tipo_pessoa (
    id_tipo_pessoa    NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    codigo            VARCHAR2(3)    NOT NULL,    -- Ex: 'PF', 'PJ'
    descricao         VARCHAR2(100)   NOT NULL,
    dt_criacao        DATE            DEFAULT SYSDATE NOT NULL,
    dt_atualizacao    DATE,
    
    CONSTRAINT pk_tb_tipo_pessoa
        PRIMARY KEY (id_tipo_pessoa),
    
    CONSTRAINT uk_tb_tipo_pessoa_codigo
        UNIQUE (codigo)
);

-- Trigger que atualiza dt_atualizacao em qualquer UPDATE
CREATE OR REPLACE TRIGGER trg_tb_tipo_pessoa_bu
BEFORE UPDATE ON tb_tipo_pessoa
FOR EACH ROW
BEGIN
    :NEW.dt_atualizacao := SYSDATE;
END;
/

-- Tabela de clientes
CREATE TABLE tb_cliente (
    id_cliente        NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_tipo_pessoa    NUMBER(10)          NOT NULL,        
    nome_razao        VARCHAR2(200)       NOT NULL,
    cpf_cnpj          VARCHAR2(20)        NOT NULL,
    email             VARCHAR2(200),
    telefone          VARCHAR2(20),
    logradouro        VARCHAR2(200),
    numero            VARCHAR2(20),
    complemento       VARCHAR2(100),
    bairro            VARCHAR2(100),
    cidade            VARCHAR2(100),
    uf                VARCHAR2(2),
    cep               VARCHAR2(10),
    situacao          CHAR(1)             DEFAULT 'A' NOT NULL, 
    dt_criacao        DATE                DEFAULT SYSDATE NOT NULL,
    dt_atualizacao    DATE,
    
    CONSTRAINT pk_tb_cliente
        PRIMARY KEY (id_cliente),
    
    CONSTRAINT fk_tb_cliente_tipo_pessoa
        FOREIGN KEY (id_tipo_pessoa)
        REFERENCES tb_tipo_pessoa (id_tipo_pessoa),
    
    CONSTRAINT uk_tb_cliente_cpf_cnpj
        UNIQUE (cpf_cnpj),
    
    CONSTRAINT ck_tb_cliente_situacao
        CHECK (situacao IN ('A', 'I'))
);

CREATE INDEX idx_tb_cliente_tipo_pessoa
    ON tb_cliente (id_tipo_pessoa);

-- Trigger para atualizar dt_atualizacao 
CREATE OR REPLACE TRIGGER trg_tb_cliente_bu
BEFORE UPDATE ON tb_cliente
FOR EACH ROW
BEGIN
    :NEW.dt_atualizacao := SYSDATE;
END;
/

-- Tabela de fornecedores
CREATE TABLE tb_fornecedor (
    id_fornecedor     NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_tipo_pessoa    NUMBER(10)          NOT NULL,        
    nome_razao        VARCHAR2(200)       NOT NULL,
    cpf_cnpj          VARCHAR2(20)        NOT NULL,
    email             VARCHAR2(200),
    telefone          VARCHAR2(20),
    logradouro        VARCHAR2(200),
    numero            VARCHAR2(20),
    complemento       VARCHAR2(100),
    bairro            VARCHAR2(100),
    cidade            VARCHAR2(100),
    uf                VARCHAR2(2),
    cep               VARCHAR2(10),
    situacao          CHAR(1)             DEFAULT 'A' NOT NULL, 
    dt_criacao        DATE                DEFAULT SYSDATE NOT NULL,
    dt_atualizacao    DATE,
    
    CONSTRAINT pk_tb_fornecedor
        PRIMARY KEY (id_fornecedor),
    
    CONSTRAINT fk_tb_fornecedor_tipo_pessoa
        FOREIGN KEY (id_tipo_pessoa)
        REFERENCES tb_tipo_pessoa (id_tipo_pessoa),
    
    CONSTRAINT uk_tb_fornecedor_cpf_cnpj
        UNIQUE (cpf_cnpj),
    
    CONSTRAINT ck_tb_fornecedor_situacao
        CHECK (situacao IN ('A', 'I'))
);

CREATE INDEX idx_tb_fornecedor_tipo_pessoa
    ON tb_fornecedor (id_tipo_pessoa);

-- Trigger para atualizar dt_atualizacao
CREATE OR REPLACE TRIGGER trg_tb_fornecedor_bu
BEFORE UPDATE ON tb_fornecedor
FOR EACH ROW
BEGIN
    :NEW.dt_atualizacao := SYSDATE;
END;
/

-- Tabela para tipos de título (boleto, pix, cartão, etc.)
CREATE TABLE tb_tipo_titulo (
    id_tipo_titulo    NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    codigo            VARCHAR2(3)    NOT NULL,    
    descricao         VARCHAR2(100)  NOT NULL,
    dt_criacao        DATE           DEFAULT SYSDATE NOT NULL,
    dt_atualizacao    DATE,
    
    CONSTRAINT pk_tb_tipo_titulo
        PRIMARY KEY (id_tipo_titulo),
    
    CONSTRAINT uk_tb_tipo_titulo_codigo
        UNIQUE (codigo)
);

-- Trigger de atualização
CREATE OR REPLACE TRIGGER trg_tb_tipo_titulo_bu
BEFORE UPDATE ON tb_tipo_titulo
FOR EACH ROW
BEGIN
    :NEW.dt_atualizacao := SYSDATE;
END;
/

