# Remove-InactiveUsers.ps1

## 📌 Descrição
Script para gerenciamento de usuários inativos em servidores Terminal Server.

## 🎯 Objetivo
Identificar e remover usuários que não realizam logon há mais de 90 dias, reduzindo consumo de espaço em disco e mantendo o ambiente organizado.

## ⚙️ Funcionamento

- Conecta remotamente aos servidores TS via PowerShell
- Exibe menu interativo com lista de servidores
- Solicita:
  - Servidor desejado
  - Mês
  - Ano
- Analisa último logon dos usuários
- Lista usuários inativos (+90 dias)
- Permite escolha para remoção

## ▶️ Como executar

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
cd C:\Caminho\do\script
.\Remove-InactiveUsers.ps1
```

## ⚠️ Observações
Necessário acesso ao domínio
Permissões administrativas nos servidores
Ajustar paths conforme ambiente

## 👨‍💻 Autor

Pablo Vinicius
