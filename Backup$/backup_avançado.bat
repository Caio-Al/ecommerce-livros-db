@echo off

ECHO.
ECHO =================================================
ECHO  INICIANDO PROCESSO DE BACKUP DO BANCO DE DADOS
ECHO =================================================
ECHO.

SET DB_USER=root
SET DB_PASS=SuaSenhaAqui
REM Altere a senha acima para a senha do seu usuário root do MySQL.
SET DB_NAME=ecommerce_livros_db
SET BASE_BACKUP_PATH=C:\MySQL_Backups

SET MYSQL_BIN_PATH="C:\Program Files\MySQL\MySQL Server 8.0\bin"
SET MYSQL_DATA_PATH="C:\ProgramData\MySQL\MySQL Server 8.0\Data"

for /f "tokens=1" %%i in ('wmic path win32_localtime get dayofweek /format:list') do for /f "tokens=2 delims==" %%j in ("%%i") do set DIA_SEMANA=%%j
for /f "tokens=1" %%i in ('wmic path win32_localtime get day /format:list') do for /f "tokens=2 delims==" %%j in ("%%i") do set DIA_MES=%%j

SET TIPO_BACKUP=Diario
if %DIA_SEMANA%==6 SET TIPO_BACKUP=Semanal
if %DIA_MES% GEQ 28 SET TIPO_BACKUP=Mensal

SET FINAL_BACKUP_PATH=%BASE_BACKUP_PATH%\%TIPO_BACKUP%
ECHO O tipo de backup de hoje eh: %TIPO_BACKUP%

if not exist "%BASE_BACKUP_PATH%" mkdir "%BASE_BACKUP_PATH%"
if not exist "%FINAL_BACKUP_PATH%" mkdir "%FINAL_BACKUP_PATH%"
if not exist "%BASE_BACKUP_PATH%\LogsBinarios" mkdir "%BASE_BACKUP_PATH%\LogsBinarios"
ECHO Pastas de backup verificadas/criadas.

SET FILENAME=%DB_NAME%_%date:~-4,4%-%date:~-7,2%-%date:~-10,2%_%time:~0,2%h%time:~3,2%m.sql

ECHO.
ECHO Iniciando o backup do banco de dados: %DB_NAME%...
%MYSQL_BIN_PATH%\mysqldump --user=%DB_USER% --password="%DB_PASS%" --host=localhost --single-transaction --routines --events --triggers --source-data %DB_NAME% > "%FINAL_BACKUP_PATH%\%FILENAME%"

if %errorlevel% neq 0 (
    ECHO.
    ECHO ******************************************************
    ECHO * ERRO: O backup completo (mysqldump) falhou!
    ECHO * Verifique as credenciais e os caminhos do MySQL.
    ECHO ******************************************************
    ECHO.
) else (
    ECHO Backup completo salvo com sucesso em: %FINAL_BACKUP_PATH%\%FILENAME%
)

ECHO.
ECHO Copiando logs binarios...
%MYSQL_BIN_PATH%\mysqladmin --user=%DB_USER% --password="%DB_PASS%" flush-logs
xcopy "%MYSQL_DATA_PATH%\AIZEN-bin.*" "%BASE_BACKUP_PATH%\LogsBinarios\" /Y /D /Q
ECHO Copia de logs binarios concluida.

ECHO.
ECHO Iniciando limpeza de backups antigos...
forfiles /p "%BASE_BACKUP_PATH%\Diario" /s /m *.sql /d -30 /c "cmd /c del @path" > nul 2>&1
forfiles /p "%BASE_BACKUP_PATH%\Semanal" /s /m *.sql /d -182 /c "cmd /c del @path" > nul 2>&1
forfiles /p "%BASE_BACKUP_PATH%\Mensal" /s /m *.sql /d -730 /c "cmd /c del @path" > nul 2>&1
forfiles /p "%BASE_BACKUP_PATH%\LogsBinarios" /s /m *.* /d -7 /c "cmd /c del @path" > nul 2>&1
ECHO Limpeza concluida.

ECHO.
ECHO =================================================
ECHO  PROCESSO DE BACKUP FINALIZADO
ECHO =================================================
ECHO.

PAUSE
