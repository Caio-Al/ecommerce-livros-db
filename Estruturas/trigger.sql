-- 6. CRIAÇÃO DE TRIGGERS

DELIMITER $$

CREATE TRIGGER trg_atualiza_estoque_pedido
AFTER UPDATE ON Pedidos
FOR EACH ROW
BEGIN
    IF NEW.status = 'Enviado' AND OLD.status != 'Enviado' THEN
        UPDATE Livros l
        JOIN Itens_Pedido ip ON l.id = ip.livro_id
        SET l.quantidade_estoque = l.quantidade_estoque - ip.quantidade
        WHERE ip.pedido_id = NEW.id;
    END IF;
END$$

DELIMITER ;