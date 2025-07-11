-- 3. POVOAMENTO DAS TABELAS

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

INSERT INTO Pedidos (cliente_id, data_pedido, status, valor_frete, valor_imposto) VALUES
(1, '2025-05-10 10:30:00', 'Entregue', 15.00, 7.49),
(2, '2025-05-12 14:00:00', 'Enviado', 15.00, 5.49),
(3, '2025-05-20 09:15:00', 'Aberto', 15.00, 5.99),
(1, '2025-06-01 18:45:00', 'Aberto', 15.00, 5.99);

INSERT INTO Itens_Pedido (pedido_id, livro_id, quantidade, preco_unitario) VALUES
(1, 1, 1, 69.90), (1, 6, 2, 39.90),
(2, 7, 1, 39.90), (2, 2, 1, 69.90),
(3, 4, 1, 69.90), (3, 9, 1, 49.90),
(4, 10, 2, 59.90);

INSERT INTO Carrinho (cliente_id, livro_id, quantidade) VALUES
(1, 3, 1), (1, 5, 2),
(2, 8, 1), (2, 11, 1),
(3, 12, 1);