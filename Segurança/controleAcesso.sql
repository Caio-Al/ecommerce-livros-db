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
