-- 3. CRIAÇÃO DE STORED PROCEDURES

DELIMITER $$

-- Procedure para inserir um novo livro (requisito do projeto)
CREATE PROCEDURE sp_inserir_livro (
    IN p_titulo VARCHAR(255), IN p_autor_id INT, IN p_isbn CHAR(20),
    IN p_editora_id INT, IN p_preco DECIMAL(10,2), IN p_quantidade_estoque INT, IN p_categoria_id INT
)
BEGIN
    INSERT INTO Livros (titulo, autor_id, isbn, editora_id, preco, quantidade_estoque, categoria_id)
    VALUES (p_titulo, p_autor_id, p_isbn, p_editora_id, p_preco, p_quantidade_estoque, p_categoria_id);
END$$

-- Procedure para atualizar estoque com tratamento de erro (melhor prática)
CREATE PROCEDURE sp_atualizar_estoque(
    IN p_livro_id INT, IN p_quantidade_vendida INT
)
BEGIN
    DECLARE v_estoque_atual INT;
    SELECT quantidade_estoque INTO v_estoque_atual FROM Livros WHERE id = p_livro_id;

    IF v_estoque_atual >= p_quantidade_vendida THEN
            UPDATE Livros SET quantidade_estoque = quantidade_estoque - p_quantidade_vendida WHERE id = p_livro_id;
    ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Estoque insuficiente para realizar a venda.';
    END IF;
END$$

 -- Procedure para gerar relatório de vendas por categoria (requisito do projeto)
CREATE PROCEDURE sp_gerar_relatorio_vendas(
    IN p_data_inicio DATE, IN p_data_fim DATE
)
BEGIN
    SELECT
        c.nome AS categoria,
        SUM(ip.quantidade) AS total_livros_vendidos,
        SUM(ip.quantidade * ip.preco_unitario) AS receita_total
    FROM Itens_Pedido ip
    INNER JOIN Pedidos p ON ip.pedido_id = p.id
    INNER JOIN Livros l ON ip.livro_id = l.id
    INNER JOIN Categorias c ON l.categoria_id = c.id
    WHERE DATE(p.data_pedido) BETWEEN p_data_inicio AND p_data_fim
    GROUP BY c.nome
    ORDER BY receita_total DESC;
END$$

-- Procedure adicional para relatório de vendas por autor
CREATE PROCEDURE sp_relatorio_vendas_por_autor(
IN data_inicio DATE, IN data_fim DATE
    )
BEGIN
SELECT
    a.nome AS autor,
    SUM(ip.quantidade) AS total_vendido,
    SUM(ip.quantidade * ip.preco_unitario) AS total_receita
FROM Itens_Pedido ip
JOIN Livros l ON ip.livro_id = l.id
JOIN Autores a ON l.autor_id = a.id
JOIN Pedidos p ON ip.pedido_id = p.id
WHERE DATE(p.data_pedido) BETWEEN data_inicio AND data_fim
GROUP BY a.nome
ORDER BY total_vendido DESC;
END$$

-- Procedure adicional para cadastro de cliente (considerando hash e salt)
CREATE PROCEDURE sp_cadastrar_cliente(
IN p_nome VARCHAR(255), IN p_email VARCHAR(255),
IN p_hash_senha VARCHAR(255), IN p_salt_senha VARCHAR(255), IN p_endereco VARCHAR(255)
)
BEGIN
INSERT INTO Clientes (nome, email, hash_senha, salt_senha, endereco)
VALUES (p_nome, p_email, p_hash_senha, p_salt_senha, p_endereco);
END$$

DELIMITER ;
