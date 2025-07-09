## 🌐 Guia de Conexão e Configuração do Banco de Dados

Este documento detalha o passo a passo para configurar o ambiente de banco de dados do projeto, permitindo o uso colaborativo por meio de uma arquitetura Host/Cliente.

---

## 👥 Estrutura de Trabalho

- **Host:** Um membro da equipe hospeda o banco de dados em sua máquina.
- **Clientes:** Os demais membros se conectam remotamente ao banco.

---

## ✅ Pré-requisitos

Instale os seguintes softwares:

- **MySQL Server**
- **MySQL Workbench**

---

## 🖥️ Passo 1: Configurando o Servidor (Host)

### 1.1 Criar o Banco de Dados

- Abra o **MySQL Workbench**
- Execute o script `main.sql` para criar as tabelas
- Execute o script `controleAcesso.sql` para criar os usuários e permissões

### 1.2 Habilitar Acesso Remoto

#### A. Obter IP da rede local

```sh
ipconfig
```
> Anote o valor de "Endereço IPv4"

#### B. Editar o `my.ini`

- Localize `C:\ProgramData\MySQL\MySQL Server X.X\my.ini`
- Após `[mysqld]`, adicione:
  ```ini
  bind-address = 0.0.0.0
  ```

#### C. Criar Regra no Firewall

1. Abra o **Firewall do Windows com Segurança Avançada**
2. Vá em **Regras de Entrada > Nova Regra**
3. Selecione **Porta**, escolha **TCP**, digite `3306`
4. Selecione **Permitir conexão**
5. Dê um nome à regra (ex: "Acesso MySQL Projeto")

#### D. Reiniciar o MySQL

```sh
services.msc
```
> Localize `MySQL`, clique com botão direito e escolha **Reiniciar**

---

## 🔌 Passo 2: Conectando ao Banco (Clientes)

1. Abra o **MySQL Workbench**
2. Clique no ícone `+` para nova conexão
3. Preencha:
   - **Connection Name:** Ex: Conexão Gerente - Projeto
   - **Hostname:** Endereço IPv4 do Host
   - **Port:** 3306
   - **Username:** usuario_gerente / usuario_tecnico / usuario_cliente
   - **Password:** Armazene a senha com "Store in Vault..."
4. Clique em **Test Connection**

---

## 🔐 Passo 3: Testando Permissões

### Como `usuario_tecnico`
```sql
SELECT * FROM ecommerce_livros_db.Pedidos;       -- ✅ Deve funcionar
DROP TABLE ecommerce_livros_db.Pedidos;          -- ❌ Deve falhar (sem permissão)
```

### Como `usuario_gerente`
```sql
SELECT * FROM ecommerce_livros_db.Pedidos;       -- ✅ Deve funcionar
CREATE TABLE ecommerce_livros_db.teste_gerente (id INT); -- ✅ Deve funcionar
DROP TABLE ecommerce_livros_db.teste_gerente;    -- ✅ Deve funcionar
```

---

Se os testes funcionarem conforme esperado, o ambiente colaborativo está pronto!
