-- 2. CRIAÇÃO DAS VIEWS

CREATE OR REPLACE VIEW vw_livros_mais_vendidos AS
SELECT
    l.id AS livro_id,
    l.titulo,
    SUM(ip.quantidade) AS total_vendido
FROM Itens_Pedido ip
JOIN Livros l ON ip.livro_id = l.id
JOIN Pedidos p ON ip.pedido_id = p.id
WHERE p.data_pedido >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY l.id, l.titulo
ORDER BY total_vendido DESC;

CREATE OR REPLACE VIEW vw_clientes_ativos AS
SELECT DISTINCT
    c.id AS cliente_id, c.nome, c.email,
    MAX(p.data_pedido) AS ultima_compra
FROM Clientes c
JOIN Pedidos p ON p.cliente_id = c.id
WHERE p.data_pedido >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY c.id, c.nome, c.email;

CREATE OR REPLACE VIEW vw_estoque_baixo AS
SELECT
    l.id AS livro_id, l.titulo, l.quantidade_estoque, c.nome AS categoria
FROM Livros l
JOIN Categorias c ON l.categoria_id = c.id
WHERE l.quantidade_estoque < 10;
