INSERT INTO tb_tipo_pessoa (codigo, descricao) VALUES ('PF', 'Pessoa Física');
INSERT INTO tb_tipo_pessoa (codigo, descricao) VALUES ('PJ', 'Pessoa Jurídica');

INSERT INTO tb_cliente (id_tipo_pessoa, nome_razao, cpf_cnpj)
VALUES (1, 'João da Silva', '123.456.789-00');

INSERT INTO tb_cliente (id_tipo_pessoa, nome_razao, cpf_cnpj)
VALUES (2, 'Maria Oliveira', '987.654.321-00');

INSERT INTO tb_tipo_titulo (codigo, descricao)
VALUES ('PIX', 'Pagamento via PIX');

INSERT INTO tb_tipo_titulo (codigo, descricao)
VALUES ('BOL', 'Boleto bancário');

INSERT INTO tb_tipo_titulo (codigo, descricao)
VALUES ('CAR', 'Cartão de crédito');

INSERT INTO tb_fornecedor (id_tipo_pessoa, nome_razao, cpf_cnpj)
VALUES (1, 'Fornecedor XPTO', '11.222.333/0001-44');

INSERT INTO tb_titulo (
    tipo_lado,
    id_cliente,
    id_tipo_titulo,
    numero_documento,
    descricao,
    dt_emissao,
    dt_vencimento,
    dt_competencia,
    valor_original
)
VALUES (
    'R',                       
    3,                         
    1,                       
    'NF-1001',
    'Exame laboratorial - NF 1001',
    DATE '2025-11-28',
    DATE '2025-12-05',
    DATE '2025-11-30',
    250.00
);

INSERT INTO tb_titulo (
    tipo_lado,
    id_fornecedor,
    id_tipo_titulo,
    numero_documento,
    descricao,
    dt_emissao,
    dt_vencimento,
    valor_original
)
VALUES (
    'P',
    2,          
    2,          
    'FAT-2025-001',
    'Pagamento fornecedor exames terceirizados',
    DATE '2025-11-28',
    DATE '2025-12-10',
    1800.00
);


COMMIT;
