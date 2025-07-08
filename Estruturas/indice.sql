-- 5. CRIAÇÃO DE ÍNDICES PARA OTIMIZAÇÃO

CREATE INDEX idx_livros_categoria_id ON Livros (categoria_id);
CREATE INDEX idx_livros_autor_id ON Livros (autor_id);
CREATE INDEX idx_livros_preco ON Livros (preco);
CREATE INDEX idx_pedidos_cliente_id ON Pedidos (cliente_id);
CREATE INDEX idx_pedidos_data_pedido ON Pedidos (data_pedido);
CREATE INDEX idx_itens_pedido_pedido_id ON Itens_Pedido (pedido_id);
CREATE INDEX idx_itens_pedido_livro_id ON Itens_Pedido (livro_id);
CREATE INDEX idx_carrinho_cliente_id ON Carrinho (cliente_id);