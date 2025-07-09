-- 6. CRIAÇÃO DE TRIGGERS
DELIMITER $$
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