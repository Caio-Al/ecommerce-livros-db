-- =====================================================================================
-- SCRIPT SQL PARA O E-COMMERCE DE LIVROS
--
-- Combina as melhores práticas dos scripts analisados:
-- 1. Estrutura base fiel aos requisitos do PDF (do Script (1).sql).
-- 2. Modelo de segurança com Hash e Salt para senhas (do EcommerceLivros.sql).
-- 3. Povoamento de dados completo e procedures de relatórios (do livraria_db (1).sql).
-- 4. Tratamento de erro explícito para gerenciamento de estoque (do EcommerceLivros.sql).
-- =====================================================================================

-- 1. CRIAÇÃO DO BANCO DE DADOS
CREATE DATABASE IF NOT EXISTS ecommerce_livros_db;
USE ecommerce_livros_db;

-- 2. CRIAÇÃO DAS TABELAS

CREATE TABLE Categorias (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Autores (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL UNIQUE,
    nacionalidade VARCHAR(255),
    data_nascimento DATE
);

CREATE TABLE Editoras (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    pais VARCHAR(255)
);

CREATE TABLE Livros (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    autor_id INT UNSIGNED NOT NULL,
    isbn CHAR(20) UNIQUE NOT NULL,
    editora_id INT UNSIGNED NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    quantidade_estoque INT NOT NULL,
    categoria_id INT UNSIGNED NOT NULL,
    FOREIGN KEY (autor_id) REFERENCES Autores(id),
    FOREIGN KEY (editora_id) REFERENCES Editoras(id),
    FOREIGN KEY (categoria_id) REFERENCES Categorias(id)
);

-- Tabela Clientes com modelo de segurança aprimorado (Hash + Salt)
CREATE TABLE Clientes (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    hash_senha VARCHAR(255) NOT NULL, -- Armazena o hash da senha
    salt_senha VARCHAR(255) NOT NULL, -- Armazena o salt único para cada usuário
    endereco VARCHAR(255) NOT NULL
);

CREATE TABLE Pedidos (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT UNSIGNED NOT NULL,
    data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Aberto', 'Enviado', 'Entregue', 'Cancelado') NOT NULL DEFAULT 'Aberto',
    FOREIGN KEY (cliente_id) REFERENCES Clientes(id)
);

CREATE TABLE Itens_Pedido (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT UNSIGNED NOT NULL,
    livro_id INT UNSIGNED NOT NULL,
    quantidade INT UNSIGNED NOT NULL CHECK (quantidade > 0),
    preco_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(id),
    FOREIGN KEY (livro_id) REFERENCES Livros(id)
);

CREATE TABLE Carrinho (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT UNSIGNED NOT NULL,
    livro_id INT UNSIGNED NOT NULL,
    quantidade INT UNSIGNED NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES Clientes(id),
    FOREIGN KEY (livro_id) REFERENCES Livros(id)
);

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

-- 4. CRIAÇÃO DE STORED FUNCTIONS

DELIMITER $$

-- Função para calcular desconto (requisito do projeto)
CREATE FUNCTION fn_calcular_desconto(p_valor_total DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_desconto_calculado DECIMAL(10,2);

    IF p_valor_total > 500 THEN
        SET v_desconto_calculado = p_valor_total * 0.10; -- 10% de desconto
    ELSEIF p_valor_total > 200 THEN
        SET v_desconto_calculado = p_valor_total * 0.05; -- 5% de desconto
    ELSE
        SET v_desconto_calculado = 0.00;
    END IF;

    RETURN v_desconto_calculado;
END$$

DELIMITER ;

DELIMITER $$

-- 5. CRIAÇÃO DE TRIGGERS

-- Trigger para atualizar o estoque após a atualização do status do pedido
-- (requisito do projeto) 
CREATE DEFINER=CURRENT_USER TRIGGER trg_atualiza_estoque_pedido
AFTER UPDATE ON Pedidos
FOR EACH ROW
BEGIN
    -- Se o status do pedido mudar PARA 'Enviado' e NÃO ERA 'Enviado' antes,
    -- diminui o estoque.
    IF NEW.status = 'Enviado' AND OLD.status != 'Enviado' THEN
        UPDATE Livros l
        JOIN Itens_Pedido ip ON l.id = ip.livro_id
        SET l.quantidade_estoque = l.quantidade_estoque - ip.quantidade
        WHERE ip.pedido_id = NEW.id;
        
    -- Se o status do pedido MUDOU e o status antigo era 'Enviado'
    -- (ex: foi para 'Cancelado'), devolve os itens ao estoque.
    ELSEIF OLD.status = 'Enviado' AND NEW.status != 'Enviado' THEN
        UPDATE Livros l
        JOIN Itens_Pedido ip ON l.id = ip.livro_id
        SET l.quantidade_estoque = l.quantidade_estoque + ip.quantidade
        WHERE ip.pedido_id = NEW.id;
    END IF;
END$$

DELIMITER ;

-- 6. CRIAÇÃO DE ÍNDICES PARA OTIMIZAÇÃO

CREATE INDEX idx_livros_categoria_id ON Livros (categoria_id);
CREATE INDEX idx_livros_autor_id ON Livros (autor_id);
CREATE INDEX idx_livros_preco ON Livros (preco);
CREATE INDEX idx_pedidos_cliente_id ON Pedidos (cliente_id);
CREATE INDEX idx_pedidos_data_pedido ON Pedidos (data_pedido);
CREATE INDEX idx_itens_pedido_pedido_id ON Itens_Pedido (pedido_id);
CREATE INDEX idx_itens_pedido_livro_id ON Itens_Pedido (livro_id);
CREATE INDEX idx_carrinho_cliente_id ON Carrinho (cliente_id);

-- 7. POVOAMENTO DAS TABELAS

INSERT INTO Categorias (nome) VALUES
('Romance'), ('Terror'), ('Suspense'), ('Ficção Científica'), ('Fantasia'), ('Aventura'), ('Mangá');

INSERT INTO Editoras (nome, pais) VALUES
('Companhia das Letras', 'Brasil'), ('Penguin Random House', 'EUA'), ('HarperCollins', 'Reino Unido'),
('Planeta', 'Espanha'), ('DarkSide Books', 'Brasil'), ('Editora JBC', 'Brasil'), ('Abril Educação', 'Brasil');

INSERT INTO Autores (nome, nacionalidade, data_nascimento) VALUES
('George R. R. Martin', 'Americana', '1948-09-20'), ('Julia Quinn', 'Americana', '1970-01-12'),
('Masashi Kishimoto', 'Japonesa', '1974-11-08'), ('Stephen King', 'Americana', '1947-09-21'),
('J.K. Rowling', 'Britânica', '1965-07-31'), ('Isaac Asimov', 'Russiana', '1920-01-02'),
('Brandon Sanderson', 'Americana', '1975-12-19'), ('Agatha Christie', 'Britânica', '1890-09-15'),
('Haruki Murakami', 'Japonesa', '1949-01-12'), ('Jules Verne', 'Francesa', '1828-02-08')
, ('Paulo Coelho', 'Brasileira', '1947-08-24'),
('Franz Kafka', 'Austríaca', '1883-07-03'), ('Miguel de Cervantes', 'Espanhola', '1547-09-29');

INSERT INTO Livros (titulo, autor_id, ISBN, editora_id, preco, quantidade_estoque, categoria_id) VALUES
('A Guerra dos Tronos', 1, '978-8576573980', 4, 69.90, 50, 5),
('A Fúria dos Reis', 1, '978-8576573997', 4, 69.90, 50, 5),
('A Tormenta de Espadas', 1, '978-8576574003', 4, 69.90, 40, 5),
('O Festim dos Corvos', 1, '978-8576574010', 4, 69.90, 35, 5),
('A Dança dos Dragões', 1, '978-8576574027', 4, 69.90, 30, 5),
('O Duque e Eu', 2, '978-8551000001', 1, 39.90, 40, 1),
('O Visconde que me Amava', 2, '978-8551000002', 1, 39.90, 38, 1),
('Naruto Vol. 1', 3, '978-8551001001', 6, 25.00, 60, 7),
('It - A Coisa', 4, '978-8532527365', 1, 49.90, 40, 2),
('Harry Potter e a Pedra Filosofal', 5, '978-8532530785', 1, 59.90, 80, 5),
('Fundação', 6, '978-8576570316', 4, 42.50, 35, 4),
('Assassinato no Expresso Oriente', 8, '978-8525430302', 1, 36.90, 40, 3);

INSERT INTO Clientes (nome, email, hash_senha, salt_senha, endereco) VALUES
('Milena Pires', 'milenapires94@gmail.com', 'hash_exemplo_1', 'salt_exemplo_1', 'Rua das Flores, 123'),
('Caio Alves', 'caioalves22@gmail.com', 'hash_exemplo_2', 'salt_exemplo_2', 'Av. Brasil, 456'),
('Lázaro Pedro', 'lazaropedro76@gmail.com', 'hash_exemplo_3', 'salt_exemplo_3', 'Rua das Acácias, 789'),
('Carlos Anderson', 'carlosanderson10@gmail.com', 'hash_exemplo_4', 'salt_exemplo_4', 'Av. das Palmeiras, 101'),
('João Miguel', 'joaomiguel58@gmail.com', 'hash_exemplo_5', 'salt_exemplo_5', 'Rua do Sol, 202');

INSERT INTO Pedidos (cliente_id, data_pedido, status) VALUES
(1, '2025-05-10 10:30:00', 'Entregue'),
(2, '2025-05-12 14:00:00', 'Enviado'),
(3, '2025-05-20 09:15:00', 'Aberto'),
(1, '2025-06-01 18:45:00', 'Aberto');

INSERT INTO Itens_Pedido (pedido_id, livro_id, quantidade, preco_unitario) VALUES
(1, 1, 1, 69.90), (1, 6, 2, 39.90),
(2, 7, 1, 39.90), (2, 2, 1, 69.90),
(3, 4, 1, 69.90), (3, 9, 1, 49.90),
(4, 10, 2, 59.90);

INSERT INTO Carrinho (cliente_id, livro_id, quantidade) VALUES
(1, 3, 1), (1, 5, 2),
(2, 8, 1), (2, 11, 1),
(3, 12, 1);

-- 8. CRIAÇÃO DE CONSULTAS 

-- Consulta para ver os livros mais vendidos (últimos 6 meses)
SELECT * FROM vw_livros_mais_vendidos;

-- Consulta para ver os clientes mais ativos (últimos 6 meses)
SELECT * FROM vw_clientes_ativos;

-- Consulta para verificar livros com estoque baixo (menos de 10 unidades)
SELECT * FROM vw_estoque_baixo;

-- Chamada da Procedure para gerar um relatório de vendas por categoria em um período
CALL sp_gerar_relatorio_vendas('2025-01-01', '2025-06-30');

-- Chamada da Procedure para gerar um relatório de vendas por autor em um período
CALL sp_relatorio_vendas_por_autor('2025-01-01', '2025-06-30');

-- =====================================================================
-- SCRIPT DE CONTROLE DE ACESSO
--
-- Define 3 papéis de usuário com permissões específicas:
-- 1. usuario_cliente: Para a aplicação web, acesso local e restrito.
-- 2. usuario_tecnico: Para funcionários, acesso remoto para gerenciamento de dados.
-- 3. usuario_gerente: Para administradores, acesso remoto com controle total.
-- =====================================================================


-- =====================================================================
-- PASSO 1: CRIAÇÃO DOS USUÁRIOS
-- =====================================================================

CREATE USER IF NOT EXISTS 'usuario_cliente'@'localhost' IDENTIFIED BY 'senha_forte_para_cliente_app';
CREATE USER IF NOT EXISTS 'usuario_tecnico'@'%' IDENTIFIED BY 'senha_segura_para_tecnico';
CREATE USER IF NOT EXISTS 'usuario_gerente'@'%' IDENTIFIED BY 'senha_admin_super_segura';


-- =====================================================================
-- PASSO 2: CONCESSÃO DE PERMISSÕES (GRANT)
-- =====================================================================

-- === PERMISSÕES PARA O 'usuario_cliente'@'localhost' ===
-- Este usuário representa a aplicação e tem as permissões mais restritas.

-- Permissão de leitura no catálogo da loja.
GRANT SELECT ON ecommerce_livros_db.Livros TO 'usuario_cliente'@'localhost';
GRANT SELECT ON ecommerce_livros_db.Categorias TO 'usuario_cliente'@'localhost';
GRANT SELECT ON ecommerce_livros_db.Autores TO 'usuario_cliente'@'localhost';
GRANT SELECT ON ecommerce_livros_db.Editoras TO 'usuario_cliente'@'localhost';

-- Permissão para gerenciar clientes (a aplicação controla o acesso individual).
GRANT SELECT, INSERT, UPDATE ON ecommerce_livros_db.Clientes TO 'usuario_cliente'@'localhost';

-- Permissão total nas tabelas de transação do usuário.
GRANT SELECT, INSERT, UPDATE, DELETE ON ecommerce_livros_db.Pedidos TO 'usuario_cliente'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON ecommerce_livros_db.Itens_Pedido TO 'usuario_cliente'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON ecommerce_livros_db.Carrinho TO 'usuario_cliente'@'localhost';

-- Permissão para executar as procedures que a aplicação precisa.
GRANT EXECUTE ON PROCEDURE ecommerce_livros_db.sp_cadastrar_cliente TO 'usuario_cliente'@'localhost';
GRANT EXECUTE ON PROCEDURE ecommerce_livros_db.sp_atualizar_estoque TO 'usuario_cliente'@'localhost';
GRANT EXECUTE ON FUNCTION ecommerce_livros_db.fn_calcular_desconto TO 'usuario_cliente'@'localhost';


-- === PERMISSÕES PARA O 'usuario_tecnico'@'%' ===
-- Este usuário gerencia os dados da loja, mas não a estrutura do banco.

-- Permissão de leitura em todo o banco de dados para consultas e suporte.
GRANT SELECT ON ecommerce_livros_db.* TO 'usuario_tecnico'@'%';

-- Permissão para gerenciar o catálogo de livros e o status dos pedidos.
GRANT INSERT, UPDATE ON ecommerce_livros_db.Livros TO 'usuario_tecnico'@'%';
GRANT UPDATE ON ecommerce_livros_db.Pedidos TO 'usuario_tecnico'@'%';

-- Permissão para executar todas as procedures e functions, especialmente as de relatório.
GRANT EXECUTE ON PROCEDURE ecommerce_livros_db.sp_gerar_relatorio_vendas TO 'usuario_tecnico'@'%';
GRANT EXECUTE ON PROCEDURE ecommerce_livros_db.sp_relatorio_vendas_por_autor TO 'usuario_tecnico'@'%';
GRANT EXECUTE ON PROCEDURE ecommerce_livros_db.sp_inserir_livro TO 'usuario_tecnico'@'%';


-- === PERMISSÕES PARA O 'usuario_gerente'@'%' ===
-- Este usuário é o administrador do banco de dados específico da loja.

-- Concede todas as permissões no banco de dados 'ecommerce_livros_db'.
-- O 'WITH GRANT OPTION' permite que este usuário também conceda permissões a outros.
GRANT ALL PRIVILEGES ON ecommerce_livros_db.* TO 'usuario_gerente'@'%' WITH GRANT OPTION;


-- =====================================================================
-- PASSO 3: APLICAR AS ALTERAÇÕES DE PRIVILÉGIOS
-- =====================================================================
-- Garante que o MySQL recarregue as tabelas de permissões imediatamente.

FLUSH PRIVILEGES;