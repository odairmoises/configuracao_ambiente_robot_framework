$logFile = "$PSScriptRoot\limpar_e_configurar_robot_framework.log"

function Log {
    param([string]$msg)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$time] $msg"
    Write-Host $line
    Add-Content -Path $logFile -Value $line
}

Log "=== INICIANDO LIMPEZA E CONFIGURACAO DO AMBIENTE ROBOT FRAMEWORK ==="

if (-not (Read-Host "Deseja continuar e limpar/configurar o ambiente Robot Framework? (s/n)").ToLower().StartsWith("s")) {
    Log "Operacao cancelada pelo usuario."
    exit
}

try {
    Invoke-WebRequest -Uri "https://pypi.org" -UseBasicParsing -TimeoutSec 5 | Out-Null
    Log "Conexao com a internet verificada com sucesso."
} catch {
    Log "Erro: Sem conexao com a internet. Verifique sua conexao antes de executar o script."
    exit 1
}

$winget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $winget) {
    Log "Erro: Winget nao encontrado. Instale o Winget manualmente para permitir a instalacao automatica do Python."
    exit 1
}

Log "Procurando ambientes virtuais locais para remocao..."
$dirs = Get-ChildItem -Path $PSScriptRoot -Recurse -Directory -Include "venv", "robot-env" -ErrorAction SilentlyContinue
if ($dirs.Count -gt 0) {
    Log "Ambientes virtuais encontrados:"
    $dirs | ForEach-Object { Log " - $($_.FullName)" }
    if ((Read-Host "Deseja remover estes ambientes? (s/n)").ToLower().StartsWith("s")) {
        $dirs | ForEach-Object { Remove-Item $_.FullName -Recurse -Force }
        Log "Ambientes virtuais removidos."
    } else {
        Log "Manutencao dos ambientes virtuais foi pulada."
    }
} else {
    Log "Nenhum ambiente virtual encontrado."
}

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Log "Python nao encontrado no sistema. Instalando Python via winget..."
    winget install --id Python.Python.3.11 -e --silent
    Start-Sleep -Seconds 10
    $python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $python) {
        Log "Erro: Python nao foi instalado corretamente."
        exit 1
    } else {
        Log "Python instalado com sucesso."
    }
} else {
    Log "Python encontrado: $($python.Source)"
}

$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chromePath)) {
    Log "Google Chrome nao encontrado. Instalando via winget..."
    winget install Google.Chrome -e --silent
}

$venvPath = Join-Path $PSScriptRoot "robot-env"
if (-not (Test-Path $venvPath)) {
    Log "Criando ambiente virtual em $venvPath..."
    python -m venv $venvPath
} else {
    Log "Ambiente virtual ja existe em $venvPath"
}

$activateEnv = Read-Host "Deseja ativar o ambiente virtual agora? (s/n) - Caminho: $venvPath"

if ($activateEnv.ToLower().StartsWith("s")) {
    $activatePath = Join-Path $venvPath "Scripts\Activate.ps1"
    if (-not (Test-Path $activatePath)) {
        Log "Erro: Ativador do ambiente virtual nao encontrado em $activatePath"
        exit 1
    }

    Log "Para ativar o ambiente virtual, execute no seu terminal:"
    Write-Host "`n    & `"$activatePath`"`n"
} else {
    Log "Usuario optou por nao ativar o ambiente virtual agora."
}

Log "Instalando bibliotecas no ambiente virtual (robotframework, seleniumlibrary, webdriver-manager)..."
$pipPath = Join-Path $venvPath "Scripts\pip.exe"
$pythonPath = Join-Path $venvPath "Scripts\python.exe"

if (-not (Test-Path $pipPath)) {
    Log "Erro: pip nao encontrado em $pipPath"
    exit 1
}

& $pythonPath -m pip install --upgrade pip
& $pipPath install robotframework robotframework-seleniumlibrary webdriver-manager
if ($LASTEXITCODE -ne 0) {
    Log "Erro na instalacao dos pacotes Python."
    exit 1
} else {
    Log "Pacotes instalados com sucesso."
}

# Removi o bloco que executava 'rfbrowser init'

Log "Limpando cache do pip..."
& $pipPath cache purge

Log "Baixando ChromeDriver via webdriver-manager..."
$scriptPython = @"
from webdriver_manager.chrome import ChromeDriverManager
print(ChromeDriverManager().install())
"@
$chromeDriverPath = & $pythonPath -c $scriptPython
Log "ChromeDriver instalado em: $chromeDriverPath"

$driverDestFolder = Join-Path $PSScriptRoot "drivers"
if (-not (Test-Path $driverDestFolder)) {
    New-Item -ItemType Directory -Path $driverDestFolder | Out-Null
}
Copy-Item $chromeDriverPath.Trim() $driverDestFolder -Force
Log "ChromeDriver copiado para $driverDestFolder"

$envPathUser = [System.Environment]::GetEnvironmentVariable("Path", "User")
$pathsParaAdicionar = @(
    "$venvPath\Scripts",
    $driverDestFolder
)
foreach ($p in $pathsParaAdicionar) {
    if (-not ($envPathUser.Split(";") | ForEach-Object { $_.Trim().ToLower() }) -contains $p.ToLower()) {
        $envPathUser += ";$p"
        Log "Adicionando $p ao PATH do usuario."
    }
}
[System.Environment]::SetEnvironmentVariable("Path", $envPathUser, "User")

Log "PATH do usuario atualizado. Talvez precise reiniciar o terminal para aplicar."

$currentPython = (Get-Command python).Source
$pythonVenv = (Get-Item $pythonPath).FullName

if ($currentPython.ToLower() -eq $pythonVenv.ToLower()) {
    Log "Ambiente virtual está ATIVO neste terminal (python: $currentPython)."
} else {
    Log "Ambiente virtual NAO está ativo neste terminal."
}

Log "=== AMBIENTE ROBOT FRAMEWORK CONFIGURADO COM SUCESSO! ==="
