# 📚 Projeto Final – Banco de Dados para E-commerce de Livros

Este repositório contém a implementação de um sistema de banco de dados relacional que simula a operação de um e-commerce de livros. O projeto foi desenvolvido como parte da disciplina **Tópicos Avançados em Banco de Dados** do curso de Análise e Desenvolvimento de Sistemas – IF Baiano / Campus Guanambi.

---

## 🎯 Objetivos do Projeto

- Aplicar conceitos práticos de SQL (DDL, DML, Views, Procedures, Functions e Índices)
- Representar entidades do mundo real com modelagem de dados
- Otimizar consultas SQL com uso de índices
- Simular funcionalidades reais de um sistema de e-commerce
- Garantir segurança, integridade e desempenho no acesso aos dados

---

## 🧱 Estrutura do Banco de Dados

### 📄 Tabelas:
- `Categorias` – Tipos de livros
- `Autores` – Nome, nacionalidade e data de nascimento
- `Editoras` – Nome e país
- `Livros` – Dados do livro com FK para autor, editora e categoria
- `Clientes` – Com hash + salt para senhas
- `Pedidos` – FK para cliente e status do pedido
- `Itens_Pedido` – Detalhes dos livros de cada pedido
- `Carrinho` – Livros adicionados por cada cliente

### 🔍 Views:
- `vw_livros_mais_vendidos`
- `vw_clientes_ativos`
- `vw_estoque_baixo`

### ⚙️ Procedures:
- `sp_inserir_livro`
- `sp_atualizar_estoque`
- `sp_gerar_relatorio_vendas`
- `sp_relatorio_vendas_por_autor`
- `sp_cadastrar_cliente`

### ➗ Function:
- `fn_calcular_desconto`

### 🏷 Índices:
Criados nas colunas: `cliente_id`, `livro_id`, `data_pedido`, `preco`, `quantidade_estoque`

---

## 🔐 Segurança
- Senhas com **hash e salt** por cliente
- Controle de acesso com 3 usuários:
  - `usuario_cliente` – uso restrito da aplicação (localhost)
  - `usuario_tecnico` – acesso remoto com permissões intermediárias
  - `usuario_gerente` – acesso total com `WITH GRANT OPTION`

---

## ▶️ Execução Recomendada

1. `main.sql` – Criação de tabelas
2. `function.sql`, `procedure.sql`, `views.sql`, `indice.sql`
3. `povoamento.sql` – Inserção de dados simulados
4. `controleAcesso.sql` – Criação de usuários e permissões

Ou utilize o script consolidado:
- `sql_blocos_executaveis.sql`

---

## 💾 Backup e Recuperação

- Recomenda-se uso de `mysqldump` ou ferramentas gráficas para exportação.
- Arquitetura preparada para cópias regulares do banco e scripts reexecutáveis.

---

## 👨‍🏫 Informações Acadêmicas

- **Instituição:** IF Baiano – Campus Guanambi
- **Curso:** Análise e Desenvolvimento de Sistemas
- **Disciplina:** Tópicos Avançados em Banco de Dados
- **Professor:** Dr. Carlos Anderson
- **Aluno Responsável:** Junior do Bolo

---

## 🌐 Conexão Remota e Configuração

Para configurar seu ambiente local e acessar o banco remotamente (host/cliente), siga o guia detalhado:

📄 [Guia de Conexão e Configuração do Banco de Dados](README_CONEXAO.md)

## 🌐 Backup e Restauração

Para configurar seu backup atomatico e restaurar o banco de dados, siga o guia detalhado:

📦 [Guia de Backup e Política de Retenção](README_BACKUP.md)



Este projeto tem finalidade acadêmica e foi desenvolvido como prática de modelagem, implementação, segurança e administração de banco de dados com MySQL.

