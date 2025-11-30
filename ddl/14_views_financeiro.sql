-- View de listagem detalhada de títulos
CREATE OR REPLACE VIEW v_titulos_listagem AS
    SELECT
        t.id_titulo,
        t.tipo_lado,
        t.id_cliente,
        t.id_fornecedor,
        t.id_tipo_titulo,
        t.numero_documento,
        t.descricao,
        t.dt_emissao,
        t.dt_vencimento,
        t.valor_original,
        t.valor_saldo,
        t.status,
        t.dt_criacao,
        t.dt_atualizacao,

        -- Quanto já foi pago
        (t.valor_original - t.valor_saldo) AS vl_pago,

        -- Situação
        CASE
            WHEN t.status = 'PG' THEN 'PAGO'
            WHEN t.dt_vencimento < TRUNC(SYSDATE) THEN 'EM_ATRASO'
            ELSE 'EM_ABERTO'
        END AS situacao_cobranca,

        -- Dias em atraso
        CASE
            WHEN t.dt_vencimento < TRUNC(SYSDATE) THEN
                TRUNC(SYSDATE) - TRUNC(t.dt_vencimento)
            ELSE
                0
        END AS dias_em_atraso
    FROM tb_titulo t;
/

-- Dashboard
CREATE OR REPLACE VIEW v_titulos_resumo_dashboard AS
    SELECT
        t.tipo_lado,
        TO_CHAR(t.dt_vencimento, 'YYYY-MM') AS mes_referencia,

        CASE
            WHEN t.status = 'PG' THEN 'PAGO'
            WHEN t.dt_vencimento < TRUNC(SYSDATE) THEN 'VENCIDO'
            ELSE 'A_VENCER'
        END AS situacao_cobranca,

        COUNT(*)                              AS qt_titulos,
        SUM(t.valor_original)                 AS vl_total_original,
        SUM(t.valor_saldo)                    AS vl_total_saldo,
        SUM(t.valor_original - t.valor_saldo) AS vl_total_pago
    FROM tb_titulo t
    GROUP BY
        t.tipo_lado,
        TO_CHAR(t.dt_vencimento, 'YYYY-MM'),
        CASE
            WHEN t.status = 'PG' THEN 'PAGO'
            WHEN t.dt_vencimento < TRUNC(SYSDATE) THEN 'VENCIDO'
            ELSE 'A_VENCER'
        END;
/
COMMIT;