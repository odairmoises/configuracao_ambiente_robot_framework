*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}    https://www.empresa1.com.br/

*** Test Cases ***
Validar Robot Framework Instalado
    Log    Robot Framework esta funcionando corretamente.

Validar SeleniumLibrary e ChromeDriver
    Open Browser    ${URL}    chrome
    Maximize Browser Window
    ${title}=    Get Title
    Should Contain    ${title}    Empresa 1
    Sleep    10s
    Close Browser
