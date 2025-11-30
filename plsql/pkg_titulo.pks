create or replace PACKAGE pkg_titulo AS

    c_lado_pagar      CONSTANT tb_titulo.tipo_lado%TYPE := 'P';
    c_lado_receber    CONSTANT tb_titulo.tipo_lado%TYPE := 'R';

    c_status_aberto   CONSTANT tb_titulo.status%TYPE    := 'AB';
    c_status_pago     CONSTANT tb_titulo.status%TYPE    := 'PG';
    c_status_atrasado CONSTANT tb_titulo.status%TYPE    := 'AT';
    c_status_cancel   CONSTANT tb_titulo.status%TYPE    := 'CN';

    e_titulo_nao_encontrado EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_titulo_nao_encontrado, -20001);

    PROCEDURE criar_titulo (
        p_tipo_lado       IN tb_titulo.tipo_lado%TYPE,
        p_id_cliente      IN tb_titulo.id_cliente%TYPE      DEFAULT NULL,
        p_id_fornecedor   IN tb_titulo.id_fornecedor%TYPE   DEFAULT NULL,
        p_id_tipo_titulo  IN tb_titulo.id_tipo_titulo%TYPE,
        p_numero_doc      IN tb_titulo.numero_documento%TYPE,
        p_descricao       IN tb_titulo.descricao%TYPE       DEFAULT NULL,
        p_dt_emissao      IN tb_titulo.dt_emissao%TYPE,
        p_dt_vencimento   IN tb_titulo.dt_vencimento%TYPE,
        p_valor           IN tb_titulo.valor_original%TYPE,
        p_id_titulo_out   OUT tb_titulo.id_titulo%TYPE
    );

    PROCEDURE atualizar_status (
        p_id_titulo IN tb_titulo.id_titulo%TYPE,
        p_status    IN tb_titulo.status%TYPE
    );

    PROCEDURE registrar_pagamento (
        p_id_titulo        IN tb_titulo.id_titulo%TYPE,
        p_valor_pagamento  IN tb_titulo_pagamento.valor_pagamento%TYPE,
        p_dt_pagamento     IN tb_titulo_pagamento.dt_pagamento%TYPE      DEFAULT SYSDATE,
        p_forma_pagamento  IN tb_titulo_pagamento.forma_pagamento%TYPE   DEFAULT NULL,
        p_observacao       IN tb_titulo_pagamento.observacao%TYPE        DEFAULT NULL,
        p_id_pagamento_out OUT tb_titulo_pagamento.id_titulo_pagamento%TYPE
    );
    
    PROCEDURE obter_extrato_titulo (
        p_id_titulo       IN  tb_titulo.id_titulo%TYPE,
        p_titulo_out      OUT SYS_REFCURSOR,
        p_pagamentos_out  OUT SYS_REFCURSOR
    );
    
    PROCEDURE estornar_pagamento(
    p_id_titulo_pagamento IN tb_titulo_pagamento.id_titulo_pagamento%TYPE
    );
    
    PROCEDURE cancelar_titulo(
    p_id_titulo IN tb_titulo.id_titulo%TYPE
    );
    
    PROCEDURE listar_titulos(
    p_tipo_lado      IN tb_titulo.tipo_lado%TYPE DEFAULT NULL,  
    p_status         IN tb_titulo.status%TYPE    DEFAULT NULL,  
    p_dt_venc_ini    IN tb_titulo.dt_vencimento%TYPE DEFAULT NULL,
    p_dt_venc_fim    IN tb_titulo.dt_vencimento%TYPE DEFAULT NULL,
    p_result_out     OUT SYS_REFCURSOR
    );

    PROCEDURE resumo_titulos(
    p_dt_venc_ini IN tb_titulo.dt_vencimento%TYPE DEFAULT NULL,
    p_dt_venc_fim IN tb_titulo.dt_vencimento%TYPE DEFAULT NULL,
    p_result_out  OUT SYS_REFCURSOR
    );


    
END pkg_titulo;