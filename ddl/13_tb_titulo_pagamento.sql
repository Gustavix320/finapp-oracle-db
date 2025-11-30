CREATE TABLE tb_titulo_pagamento (
    id_titulo_pagamento  NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_titulo            NUMBER(10)      NOT NULL,
    dt_pagamento         DATE            NOT NULL,
    valor_pagamento      NUMBER(15,2)    NOT NULL,
    forma_pagamento      VARCHAR2(30),
    observacao           VARCHAR2(255),
    dt_criacao           DATE            DEFAULT SYSDATE NOT NULL,
    dt_atualizacao       DATE,

    CONSTRAINT pk_tb_titulo_pagamento
        PRIMARY KEY (id_titulo_pagamento),

    CONSTRAINT fk_tb_titulo_pagamento_titulo
        FOREIGN KEY (id_titulo)
        REFERENCES tb_titulo (id_titulo),

    CONSTRAINT ck_tb_titulo_pag_valor_positivo
        CHECK (valor_pagamento > 0)
);

-- Índices auxiliares

CREATE INDEX idx_tb_titulo_pag_id_titulo
    ON tb_titulo_pagamento (id_titulo);

CREATE INDEX idx_tb_titulo_pag_dt_pagamento
    ON tb_titulo_pagamento (dt_pagamento);

-- Trigger para auditoria

CREATE OR REPLACE TRIGGER trg_tb_titulo_pagamento_biu
BEFORE INSERT OR UPDATE ON tb_titulo_pagamento
FOR EACH ROW
BEGIN

    IF INSERTING THEN
        :NEW.dt_criacao := NVL(:NEW.dt_criacao, SYSDATE);
    END IF;

    :NEW.dt_atualizacao := SYSDATE;
END;
/

COMMIT;