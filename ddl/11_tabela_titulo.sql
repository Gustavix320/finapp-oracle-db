CREATE TABLE tb_titulo (
    id_titulo         NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    tipo_lado         CHAR(1)          NOT NULL,           
    id_cliente        NUMBER(10),                           
    id_fornecedor     NUMBER(10),                           
    id_tipo_titulo    NUMBER(10)        NOT NULL,           
    numero_documento  VARCHAR2(50),                         
    descricao         VARCHAR2(255),                        
    dt_emissao        DATE              NOT NULL,
    dt_vencimento     DATE              NOT NULL,
    valor_original    NUMBER(15,2)      NOT NULL,
    valor_saldo       NUMBER(15,2)      NOT NULL,
    status            CHAR(2)           DEFAULT 'AB' NOT NULL, 
    dt_criacao        DATE              DEFAULT SYSDATE NOT NULL,
    dt_atualizacao    DATE,
    
    CONSTRAINT pk_tb_titulo
        PRIMARY KEY (id_titulo),
    
    CONSTRAINT fk_tb_titulo_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES tb_cliente (id_cliente),
    
    CONSTRAINT fk_tb_titulo_fornecedor
        FOREIGN KEY (id_fornecedor)
        REFERENCES tb_fornecedor (id_fornecedor),
    
    CONSTRAINT fk_tb_titulo_tipo_titulo
        FOREIGN KEY (id_tipo_titulo)
        REFERENCES tb_tipo_titulo (id_tipo_titulo),
    
    CONSTRAINT ck_tb_titulo_status
        CHECK (status IN ('AB', 'PG', 'AT', 'CN')),
    
    CONSTRAINT ck_tb_titulo_tipo_lado
        CHECK (tipo_lado IN ('P', 'R')),
    
    -- Regra de consistência:
    --  R (receber) -> exige CLIENTE e proíbe FORNECEDOR
    --  P (pagar) -> exige FORNECEDOR e proíbe CLIENTE
    CONSTRAINT ck_tb_titulo_lado_relacionamento
        CHECK (
            (tipo_lado = 'R' AND id_cliente    IS NOT NULL AND id_fornecedor IS NULL) OR
            (tipo_lado = 'P' AND id_fornecedor IS NOT NULL AND id_cliente    IS NULL)
        )
);

-- Índices em FKs
CREATE INDEX idx_tb_titulo_cliente
    ON tb_titulo (id_cliente);

CREATE INDEX idx_tb_titulo_fornecedor
    ON tb_titulo (id_fornecedor);

CREATE INDEX idx_tb_titulo_tipo_titulo
    ON tb_titulo (id_tipo_titulo);

CREATE INDEX idx_tb_titulo_status_vencimento
    ON tb_titulo (status, dt_vencimento);

CREATE INDEX idx_titulo_tipo_cli_sit_venc
    ON tb_titulo (tipo_lado, id_cliente, status, dt_vencimento);

CREATE INDEX idx_titulo_tipo_forn_sit_venc
    ON tb_titulo (tipo_lado, id_fornecedor, status, dt_vencimento);

-- Trigger para atualizar dt_atualizacao e inicializar valor_saldo
CREATE OR REPLACE TRIGGER trg_tb_titulo_biu
BEFORE INSERT OR UPDATE ON tb_titulo
FOR EACH ROW
BEGIN

    IF INSERTING THEN
        IF :NEW.valor_saldo IS NULL THEN
            :NEW.valor_saldo := :NEW.valor_original;
        END IF;
        :NEW.dt_criacao := NVL(:NEW.dt_criacao, SYSDATE);
    END IF;

    :NEW.dt_atualizacao := SYSDATE;
END;
/
