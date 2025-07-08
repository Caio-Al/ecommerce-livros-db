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