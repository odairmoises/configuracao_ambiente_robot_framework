
# Script de Limpeza e Configuração do Ambiente Robot Framework

Este script PowerShell automatiza a limpeza e configuração de um ambiente local para desenvolvimento e execução de testes com Robot Framework usando SeleniumLibrary.

---

## Funcionalidades principais

- Confirmação para continuar a operação.
- Verifica conexão com a internet.
- Verifica se o `winget` está instalado (necessário para instalar Python e Chrome).
- Remove ambientes virtuais locais existentes (`venv` e `robot-env`), com confirmação do usuário.
- Verifica e instala o Python 3.11, caso não esteja presente.
- Verifica e instala o Google Chrome, caso não esteja presente.
- Cria um ambiente virtual (`robot-env`) para isolar as dependências.
- Pergunta se deseja ativar o ambiente virtual imediatamente, e indica o comando para ativação.
- Instala as bibliotecas essenciais no ambiente virtual:
  - `robotframework`
  - `robotframework-seleniumlibrary`
  - `webdriver-manager`
- Limpa o cache do `pip`.
- Baixa e copia o ChromeDriver para uma pasta local `drivers`.
- Atualiza o PATH do usuário para incluir o ambiente virtual e a pasta `drivers`.
- Informa se o ambiente virtual está ativo no terminal atual.

---

## Como usar

1. Abra o PowerShell na pasta onde o script está salvo.

2. Execute o script:

   ```powershell
   .\limpar_e_configurar_robot_framework.ps1
   ```
   Se for solicitado permissões especiais execute esse script:  ```powershell
   -ExecutionPolicy Bypass -File .\limpar_e_configurar_robot.ps1
   ```
      
      

3. O script irá solicitar confirmações para algumas etapas, como remoção de ambientes virtuais antigos e ativação do ambiente virtual.

4. Caso opte por ativar o ambiente virtual, será exibido o comando para executar no terminal atual:

   ```powershell
   & "caminho\para\robot-env\Scripts\Activate.ps1"
   ```

   Execute este comando para ativar o ambiente virtual.

5. Após a ativação, você poderá rodar os testes Robot Framework usando as bibliotecas instaladas.

6. Executar o script de validação 'validar_ambiente.robot' comando
robot validar_ambiente.robot


---

## Estrutura criada

- Ambiente virtual isolado na pasta `robot-env`.
- Pasta `drivers` contendo o ChromeDriver.
- Log de execução em `limpar_e_configurar_robot_framework.log`.

---

## Requisitos

- Windows com PowerShell.
- Conexão ativa com a internet.
- `winget` instalado (gerenciador de pacotes do Windows).
- Permissão para instalar softwares e alterar variáveis de ambiente.

---

## Observações

- O script não ativa automaticamente o ambiente virtual para não modificar o estado do terminal atual sem permissão.
- Após a execução, é recomendado reiniciar o terminal para que as alterações no PATH tenham efeito.
- O script não instala a biblioteca `robotframework-browser`, apenas `robotframework-seleniumlibrary`.
- Para executar o script de testes deve no mesmo diretorio executar o comando robot validar_ambiente.robot (lembrando que o arquivo validar_ambiente.robot deve existir no diretório)


---

## Contato

Odair Moises de Oliveira

---

**Feito com 💻 e PowerShell**
