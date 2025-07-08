-- 7. CRIAÇÃO DE CONSULTAS 

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