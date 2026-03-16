@echo off
setlocal EnableDelayedExpansion

echo ==================================================
echo   ASSINADOR DE EXECUTAVEL DELPHI - AUTOASSINADO
echo ==================================================
echo.

:: ==================================================
:: VERIFICA ADMIN
:: ==================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Execute como ADMINISTRADOR!
    pause
    exit /b
)

:: ==================================================
:: DEFINICOES DE PASTA
:: ==================================================
set BASE_DIR=%~dp0
set CERT_DIR=%BASE_DIR%Certificado
set INPUT_DIR=%BASE_DIR%APP\Input
set OUTPUT_DIR=%BASE_DIR%APP\Out

if not exist "%CERT_DIR%" mkdir "%CERT_DIR%"
if not exist "%INPUT_DIR%" mkdir "%INPUT_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: ==================================================
:: LIMPAR PASTA OUT
:: ==================================================
del /q "%OUTPUT_DIR%\*" >nul 2>&1

:: ==================================================
:: VALORES PADRAO
:: ==================================================
set DEF_EMPRESA=SUA EMPRESA
set DEF_ORG=SUA ORGANIZACAO
set DEF_DEPT=Desenvolvimento
set DEF_CITY=Rio de Janeiro
set DEF_STATE=RJ
set DEF_COUNTRY=BR
set DEF_EMAIL=seu@email.com
set DEF_PFX=SeuCertificado
set DEF_SENHA=123456
set DEF_VALIDADE=5

:: ==================================================
:: INPUTS
:: ==================================================
set /p EMPRESA=Nome da Empresa (CN) [%DEF_EMPRESA%]: 
if "%EMPRESA%"=="" set EMPRESA=%DEF_EMPRESA%

set /p ORG=Organizacao [%DEF_ORG%]: 
if "%ORG%"=="" set ORG=%DEF_ORG%

set /p DEPT=Departamento [%DEF_DEPT%]: 
if "%DEPT%"=="" set DEPT=%DEF_DEPT%

set /p CITY=Cidade [%DEF_CITY%]: 
if "%CITY%"=="" set CITY=%DEF_CITY%

set /p STATE=Estado [%DEF_STATE%]: 
if "%STATE%"=="" set STATE=%DEF_STATE%

set /p COUNTRY=Pais [%DEF_COUNTRY%]: 
if "%COUNTRY%"=="" set COUNTRY=%DEF_COUNTRY%

set /p EMAIL=Email [%DEF_EMAIL%]: 
if "%EMAIL%"=="" set EMAIL=%DEF_EMAIL%

set /p PFXNAME=Nome do arquivo PFX [%DEF_PFX%]: 
if "%PFXNAME%"=="" set PFXNAME=%DEF_PFX%

set /p SENHA=Senha do certificado [%DEF_SENHA%]: 
if "%SENHA%"=="" set SENHA=%DEF_SENHA%

set /p VALIDADE=Validade em anos [%DEF_VALIDADE%]: 
if "%VALIDADE%"=="" set VALIDADE=%DEF_VALIDADE%

echo.

:: ==================================================
:: SANITIZAR NOME DO PFX
:: ==================================================
for /f "delims=" %%i in ('powershell -NoProfile -Command "$n='%PFXNAME%'; $n -replace '[^a-zA-Z0-9_-]', ''"') do set "PFXNAME=%%i"

if "%PFXNAME%"=="" (
    echo Nome do certificado invalido!
    pause
    exit /b
)

set PFX_PATH=%CERT_DIR%\%PFXNAME%.pfx

:: ==================================================
:: GERAR CERTIFICADO SE NAO EXISTIR
:: ==================================================
if exist "%PFX_PATH%" (
    echo Certificado ja existente:
    echo %PFX_PATH%
    echo Sera reutilizado.
) else (
    echo Gerando novo certificado...

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$cert = New-SelfSignedCertificate -Type CodeSigningCert -Subject 'CN=%EMPRESA%, O=%ORG%, OU=%DEPT%, L=%CITY%, S=%STATE%, C=%COUNTRY%, E=%EMAIL%' -KeyUsage DigitalSignature -FriendlyName 'Certificado %EMPRESA%' -CertStoreLocation 'Cert:\CurrentUser\My' -NotAfter (Get-Date).AddYears(%VALIDADE%);" ^
    "$pwd = ConvertTo-SecureString -String '%SENHA%' -Force -AsPlainText;" ^
    "Export-PfxCertificate -Cert $cert -FilePath '%PFX_PATH%' -Password $pwd"

    if not exist "%PFX_PATH%" (
        echo Erro ao criar certificado.
        pause
        exit /b
    )
)

:: ==================================================
:: LISTAR EXECUTAVEIS
:: ==================================================
echo.
echo Executaveis encontrados em:
echo %INPUT_DIR%
echo.

set COUNT=0
for %%F in ("%INPUT_DIR%\*.exe") do (
    set /a COUNT+=1
    set FILE!COUNT!=%%F
    echo !COUNT! - %%~nxF
)

if %COUNT%==0 (
    echo Nenhum executavel encontrado.
    pause
    exit /b
)

if %COUNT%==1 (
    set SELECAO=1
) else (
    echo.
    set /p SELECAO=Digite o numero do executavel desejado: 
)

set EXE_FILE=!FILE%SELECAO%!

if "%EXE_FILE%"=="" (
    echo Selecao invalida.
    pause
    exit /b
)

echo.
echo Executavel selecionado:
echo %EXE_FILE%
echo.

:: ==================================================
:: DEFINIR SAIDA
:: ==================================================
for %%F in ("%EXE_FILE%") do (
    set NOME=%%~nF
    set EXT=%%~xF
)

set OUTPUT_FILE=%OUTPUT_DIR%\%NOME%_ASSINADO%EXT%
copy "%EXE_FILE%" "%OUTPUT_FILE%" >nul

:: ==================================================
:: DETECTAR SIGNTOOL (SUA LOGICA MELHORADA)
:: ==================================================
echo Localizando signtool...

set SIGNTOOL=

:: PATH
for /f "delims=" %%S in ('where signtool 2^>nul') do (
    set SIGNTOOL=%%S
)

:: Windows Kits (sua abordagem)
if not defined SIGNTOOL (
    for /f "delims=" %%S in ('where /r "%ProgramFiles(x86)%\Windows Kits" signtool.exe 2^>nul') do (
        set SIGNTOOL=%%S
    )
)

if not defined SIGNTOOL (
    for /f "delims=" %%S in ('where /r "%ProgramFiles%\Windows Kits" signtool.exe 2^>nul') do (
        set SIGNTOOL=%%S
    )
)

if not defined SIGNTOOL (
    echo Signtool nao encontrado.
    pause
    exit /b
)

echo Signtool encontrado:
echo %SIGNTOOL%
echo.

:: ==================================================
:: ASSINAR
:: ==================================================
echo Assinando...

"%SIGNTOOL%" sign /f "%PFX_PATH%" /p "%SENHA%" /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 "%OUTPUT_FILE%"

if %errorlevel% neq 0 (
    echo Erro ao assinar.
    pause
    exit /b
)

echo.
echo ==================================================
echo   EXECUTAVEL ASSINADO COM SUCESSO!
echo   Saida:
echo   %OUTPUT_FILE%
echo ==================================================
echo.

pause