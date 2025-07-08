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

