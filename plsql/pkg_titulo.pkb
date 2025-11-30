create or replace PACKAGE BODY pkg_titulo AS

    -- FUNÇÕES INTERNAS

    -- Verifica se título existe
    FUNCTION existe_titulo (p_id_titulo IN tb_titulo.id_titulo%TYPE)
        RETURN BOOLEAN
    IS
        v_dummy NUMBER;
    BEGIN
        SELECT 1 INTO v_dummy
        FROM tb_titulo
        WHERE id_titulo = p_id_titulo;

        RETURN TRUE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END existe_titulo;

    
        -- Verifica se cliente existe
    FUNCTION existe_cliente (p_id_cliente IN tb_cliente.id_cliente%TYPE)
        RETURN BOOLEAN
    IS
        v_dummy NUMBER;
    BEGIN
        SELECT 1
          INTO v_dummy
          FROM tb_cliente
         WHERE id_cliente = p_id_cliente;

        RETURN TRUE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END existe_cliente;


    -- Verifica se fornecedor existe
    FUNCTION existe_fornecedor (p_id_fornecedor IN tb_fornecedor.id_fornecedor%TYPE)
        RETURN BOOLEAN
    IS
        v_dummy NUMBER;
    BEGIN
        SELECT 1
          INTO v_dummy
          FROM tb_fornecedor
         WHERE id_fornecedor = p_id_fornecedor;

        RETURN TRUE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END existe_fornecedor;


    -- Busca título com lock FOR UPDATEs
    PROCEDURE buscar_titulo_lock (
        p_id_titulo      IN tb_titulo.id_titulo%TYPE,
        p_status_out     OUT tb_titulo.status%TYPE,
        p_saldo_out      OUT tb_titulo.valor_saldo%TYPE
    ) IS
    BEGIN
        SELECT status, valor_saldo
          INTO p_status_out, p_saldo_out
          FROM tb_titulo
         WHERE id_titulo = p_id_titulo
         FOR UPDATE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE e_titulo_nao_encontrado;
    END buscar_titulo_lock;


    -- CLIENTE / FORNECEDOR
    PROCEDURE validar_cliente (p_id_cliente IN tb_cliente.id_cliente%TYPE) IS
    BEGIN
        IF p_id_cliente IS NULL THEN
            RAISE_APPLICATION_ERROR(-20010, 'ID_CLIENTE não informado.');
        END IF;

        IF NOT existe_cliente(p_id_cliente) THEN
            RAISE_APPLICATION_ERROR(-20011, 'Cliente não encontrado: ' || p_id_cliente);
        END IF;
    END validar_cliente;


    PROCEDURE validar_fornecedor (p_id_fornecedor IN tb_fornecedor.id_fornecedor%TYPE) IS
    BEGIN
        IF p_id_fornecedor IS NULL THEN
            RAISE_APPLICATION_ERROR(-20012, 'ID_FORNECEDOR não informado.');
        END IF;

        IF NOT existe_fornecedor(p_id_fornecedor) THEN
            RAISE_APPLICATION_ERROR(-20013, 'Fornecedor não encontrado: ' || p_id_fornecedor);
        END IF;
    END validar_fornecedor;


    -- CRIAR TÍTULO
    PROCEDURE criar_titulo (
        p_tipo_lado       IN tb_titulo.tipo_lado%TYPE,
        p_id_cliente      IN tb_titulo.id_cliente%TYPE,
        p_id_fornecedor   IN tb_titulo.id_fornecedor%TYPE,
        p_id_tipo_titulo  IN tb_titulo.id_tipo_titulo%TYPE,
        p_numero_doc      IN tb_titulo.numero_documento%TYPE,
        p_descricao       IN tb_titulo.descricao%TYPE,
        p_dt_emissao      IN tb_titulo.dt_emissao%TYPE,
        p_dt_vencimento   IN tb_titulo.dt_vencimento%TYPE,
        p_valor           IN tb_titulo.valor_original%TYPE,
        p_id_titulo_out   OUT tb_titulo.id_titulo%TYPE
    ) IS
    BEGIN
        -- Validações
        IF p_tipo_lado NOT IN (c_lado_pagar, c_lado_receber) THEN
            RAISE_APPLICATION_ERROR(-20020, 'Tipo de lado inválido.');
        END IF;

        IF p_valor <= 0 THEN
            RAISE_APPLICATION_ERROR(-20021, 'Valor deve ser maior que zero.');
        END IF;

        IF p_dt_vencimento < p_dt_emissao THEN
            RAISE_APPLICATION_ERROR(-20022, 'Vencimento não pode ser antes da emissão.');
        END IF;

        IF p_tipo_lado = c_lado_receber THEN
            IF p_id_cliente IS NULL OR p_id_fornecedor IS NOT NULL THEN
                RAISE_APPLICATION_ERROR(-20023,
                    'Para RECEBER: apenas ID_CLIENTE deve ser informado.');
            END IF;
            validar_cliente(p_id_cliente);
        ELSE
            IF p_id_fornecedor IS NULL OR p_id_cliente IS NOT NULL THEN
                RAISE_APPLICATION_ERROR(-20024,
                    'Para PAGAR: apenas ID_FORNECEDOR deve ser informado.');
            END IF;
            validar_fornecedor(p_id_fornecedor);
        END IF;

        -- Inserção
        INSERT INTO tb_titulo (
            tipo_lado, id_cliente, id_fornecedor, id_tipo_titulo,
            numero_documento, descricao, dt_emissao, dt_vencimento,
            valor_original, valor_saldo, status
        ) VALUES (
            p_tipo_lado, p_id_cliente, p_id_fornecedor, p_id_tipo_titulo,
            p_numero_doc, p_descricao, p_dt_emissao, p_dt_vencimento,
            p_valor, p_valor, c_status_aberto
        )
        RETURNING id_titulo INTO p_id_titulo_out;
    END criar_titulo;


    -- ATUALIZAR STATUS
    PROCEDURE atualizar_status (
        p_id_titulo IN tb_titulo.id_titulo%TYPE,
        p_status    IN tb_titulo.status%TYPE
    ) IS
    BEGIN
        IF p_status NOT IN (
            c_status_aberto, c_status_pago, c_status_atrasado, c_status_cancel
        ) THEN
            RAISE_APPLICATION_ERROR(-20030, 'Status inválido.');
        END IF;

        UPDATE tb_titulo
           SET status = p_status,
               dt_atualizacao = SYSDATE
         WHERE id_titulo = p_id_titulo;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE e_titulo_nao_encontrado;
        END IF;
    END atualizar_status;


    -- REGISTRAR PAGAMENTO
    PROCEDURE registrar_pagamento (
        p_id_titulo        IN tb_titulo.id_titulo%TYPE,
        p_valor_pagamento  IN tb_titulo_pagamento.valor_pagamento%TYPE,
        p_dt_pagamento     IN tb_titulo_pagamento.dt_pagamento%TYPE,
        p_forma_pagamento  IN tb_titulo_pagamento.forma_pagamento%TYPE,
        p_observacao       IN tb_titulo_pagamento.observacao%TYPE,
        p_id_pagamento_out OUT tb_titulo_pagamento.id_titulo_pagamento%TYPE
    ) IS
        v_status     tb_titulo.status%TYPE;
        v_saldo      tb_titulo.valor_saldo%TYPE;
        v_novo_saldo tb_titulo.valor_saldo%TYPE;
    BEGIN
        IF p_valor_pagamento <= 0 THEN
            RAISE_APPLICATION_ERROR(-20040, 'Valor do pagamento deve ser maior que zero.');
        END IF;

        buscar_titulo_lock(p_id_titulo, v_status, v_saldo);

        IF v_status = c_status_cancel THEN
            RAISE_APPLICATION_ERROR(-20041, 'Título cancelado.');
        ELSIF v_status = c_status_pago THEN
            RAISE_APPLICATION_ERROR(-20042, 'Título já quitado.');
        END IF;

        IF p_valor_pagamento > v_saldo THEN
            RAISE_APPLICATION_ERROR(-20043, 'Pagamento excede saldo.');
        END IF;

        INSERT INTO tb_titulo_pagamento (
            id_titulo, dt_pagamento, valor_pagamento, forma_pagamento, observacao
        ) VALUES (
            p_id_titulo, NVL(p_dt_pagamento, SYSDATE),
            p_valor_pagamento, p_forma_pagamento, p_observacao
        )
        RETURNING id_titulo_pagamento INTO p_id_pagamento_out;

        v_novo_saldo := v_saldo - p_valor_pagamento;

        UPDATE tb_titulo
           SET valor_saldo    = v_novo_saldo,
               status         = CASE WHEN v_novo_saldo = 0 THEN c_status_pago ELSE v_status END,
               dt_atualizacao = SYSDATE
         WHERE id_titulo = p_id_titulo;
    END registrar_pagamento;


    -- EXTRATO DO TÍTULO
    PROCEDURE obter_extrato_titulo (
        p_id_titulo       IN  tb_titulo.id_titulo%TYPE,
        p_titulo_out      OUT SYS_REFCURSOR,
        p_pagamentos_out  OUT SYS_REFCURSOR
    ) IS
    BEGIN
        IF NOT existe_titulo(p_id_titulo) THEN
            RAISE e_titulo_nao_encontrado;
        END IF;

        OPEN p_titulo_out FOR
            SELECT *
            FROM v_titulos_listagem
            WHERE id_titulo = p_id_titulo;

        OPEN p_pagamentos_out FOR
            SELECT *
            FROM tb_titulo_pagamento
            WHERE id_titulo = p_id_titulo
            ORDER BY dt_pagamento, id_titulo_pagamento;

        DBMS_SQL.RETURN_RESULT(p_titulo_out);
        DBMS_SQL.RETURN_RESULT(p_pagamentos_out);
    END obter_extrato_titulo;


    -- ESTORNAR PAGAMENTO
    PROCEDURE estornar_pagamento (
        p_id_titulo_pagamento IN tb_titulo_pagamento.id_titulo_pagamento%TYPE
    ) IS
        v_id_titulo     tb_titulo.id_titulo%TYPE;
        v_val_pagamento tb_titulo_pagamento.valor_pagamento%TYPE;
        v_status        tb_titulo.status%TYPE;
        v_saldo         tb_titulo.valor_saldo%TYPE;
        v_novo_saldo    tb_titulo.valor_saldo%TYPE;
    BEGIN
        SELECT id_titulo, valor_pagamento
          INTO v_id_titulo, v_val_pagamento
          FROM tb_titulo_pagamento
         WHERE id_titulo_pagamento = p_id_titulo_pagamento
         FOR UPDATE;

        buscar_titulo_lock(v_id_titulo, v_status, v_saldo);

        v_novo_saldo := v_saldo + v_val_pagamento;

        UPDATE tb_titulo
           SET valor_saldo    = v_novo_saldo,
               status         = CASE
                                   WHEN v_novo_saldo = 0 THEN c_status_pago
                                   WHEN v_status = c_status_pago THEN c_status_aberto
                                   ELSE v_status
                               END,
               dt_atualizacao = SYSDATE
         WHERE id_titulo      = v_id_titulo;

        DELETE FROM tb_titulo_pagamento
         WHERE id_titulo_pagamento = p_id_titulo_pagamento;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20050,
                'Pagamento não encontrado: ' || p_id_titulo_pagamento);
    END estornar_pagamento;


    -- CANCELAR TÍTULO
    PROCEDURE cancelar_titulo (
        p_id_titulo IN tb_titulo.id_titulo%TYPE
    ) IS
        v_status  tb_titulo.status%TYPE;
        v_saldo   tb_titulo.valor_saldo%TYPE;
        v_qtd_pag PLS_INTEGER;
    BEGIN
        buscar_titulo_lock(p_id_titulo, v_status, v_saldo);

        IF v_status = c_status_cancel THEN
            RAISE_APPLICATION_ERROR(-20060, 'Título já cancelado.');
        ELSIF v_status = c_status_pago THEN
            RAISE_APPLICATION_ERROR(-20061, 'Não pode cancelar título quitado.');
        END IF;

        SELECT COUNT(*)
          INTO v_qtd_pag
          FROM tb_titulo_pagamento
         WHERE id_titulo = p_id_titulo;

        IF v_qtd_pag > 0 THEN
            RAISE_APPLICATION_ERROR(-20062,
                'Título possui pagamentos. Estorne antes.');
        END IF;

        UPDATE tb_titulo
           SET status = c_status_cancel,
               dt_atualizacao = SYSDATE
         WHERE id_titulo = p_id_titulo;
    END cancelar_titulo;


    -- LISTAR TÍTULOS
    PROCEDURE listar_titulos (
        p_tipo_lado      IN tb_titulo.tipo_lado%TYPE DEFAULT NULL,
        p_status         IN tb_titulo.status%TYPE    DEFAULT NULL,
        p_dt_venc_ini    IN tb_titulo.dt_vencimento%TYPE DEFAULT NULL,
        p_dt_venc_fim    IN tb_titulo.dt_vencimento%TYPE DEFAULT NULL,
        p_result_out     OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_result_out FOR
            SELECT *
              FROM v_titulos_listagem
             WHERE (p_tipo_lado   IS NULL OR tipo_lado   = p_tipo_lado)
               AND (p_status      IS NULL OR status      = p_status)
               AND (p_dt_venc_ini IS NULL OR dt_vencimento >= p_dt_venc_ini)
               AND (p_dt_venc_fim IS NULL OR dt_vencimento <= p_dt_venc_fim)
             ORDER BY dt_vencimento, id_titulo;

        DBMS_SQL.RETURN_RESULT(p_result_out);
    END listar_titulos;


    -- RESUMO TÍTULOS
    PROCEDURE resumo_titulos (
        p_dt_venc_ini IN tb_titulo.dt_vencimento%TYPE DEFAULT NULL,
        p_dt_venc_fim IN tb_titulo.dt_vencimento%TYPE DEFAULT NULL,
        p_result_out  OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_result_out FOR
            SELECT *
            FROM v_titulos_resumo_dashboard
            WHERE (p_dt_venc_ini IS NULL OR mes_referencia >= TO_CHAR(p_dt_venc_ini, 'YYYY-MM'))
              AND (p_dt_venc_fim IS NULL OR mes_referencia <= TO_CHAR(p_dt_venc_fim, 'YYYY-MM'))
            ORDER BY mes_referencia, tipo_lado, situacao_cobranca;

        DBMS_SQL.RETURN_RESULT(p_result_out);
    END resumo_titulos;

END pkg_titulo;