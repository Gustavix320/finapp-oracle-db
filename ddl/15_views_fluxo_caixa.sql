-- Fluxo de caixa PREVISTO por dia
CREATE OR REPLACE VIEW v_fluxo_caixa_previsto_diario AS
    SELECT
        TRUNC(t.dt_vencimento)        AS dt_movimento,
        t.tipo_lado,
        SUM(t.valor_saldo)            AS vl_previsto_saldo,
        SUM(t.valor_original)         AS vl_previsto_original,
        COUNT(*)                      AS qt_titulos
    FROM tb_titulo t
    WHERE t.status NOT IN ('PG', 'CN')   
    GROUP BY
        TRUNC(t.dt_vencimento),
        t.tipo_lado;
/

-- Fluxo de caixa REALIZADO por dia 
CREATE OR REPLACE VIEW v_fluxo_caixa_realizado_diario AS
    SELECT
        TRUNC(p.dt_pagamento)         AS dt_movimento,
        t.tipo_lado,
        SUM(p.valor_pagamento)        AS vl_realizado,
        COUNT(*)                      AS qt_pagamentos
    FROM tb_titulo_pagamento p
    JOIN tb_titulo t
      ON t.id_titulo = p.id_titulo
    GROUP BY
        TRUNC(p.dt_pagamento),
        t.tipo_lado;
/

-- Fluxo de caixa PREVISTO x REALIZADO por mês
CREATE OR REPLACE VIEW v_fluxo_caixa_mensal AS
    SELECT
        TO_CHAR(f.dt_movimento, 'YYYY-MM') AS mes_referencia,
        f.tipo_lado,
        SUM(f.vl_previsto_saldo)           AS vl_previsto_saldo,
        SUM(r.vl_realizado)                AS vl_realizado
    FROM v_fluxo_caixa_previsto_diario f
    LEFT JOIN v_fluxo_caixa_realizado_diario r
           ON r.dt_movimento = f.dt_movimento
          AND r.tipo_lado    = f.tipo_lado
    GROUP BY
        TO_CHAR(f.dt_movimento, 'YYYY-MM'),
        f.tipo_lado;
/

COMMIT;