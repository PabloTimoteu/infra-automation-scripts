<#
.Descrição
  Este script interativo permite que você selecione um servidor, defina um mês e ano
  para inatividade e remova os perfis de usuário que não acessam o servidor desde
  a data especificada.
#>

# Força o console do PowerShell a usar a codificação UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Variável global para armazenar os usuários inativos.
$inactiveUsers = @()

#-----------------------------------------------------------------------------------
# FUNÇÕES DO SCRIPT
#-----------------------------------------------------------------------------------

function Select-Server {
    Write-Host "---------------------------------------------------------" -ForegroundColor Green
    Write-Host "      MENU DE SELEÇÃO DE SERVIDOR" -ForegroundColor Cyan
    Write-Host "---------------------------------------------------------" -ForegroundColor Green
# coloque os servidores que serão gerenciados dentro de $servers. (apague essa linha se nescessario). 
    $servers = @("")

    for ($i = 0; $i -lt $servers.Count; $i++) {
        Write-Host "$($i + 1). $($servers[$i])"
    }

    Write-Host "---------------------------------------------------------" -ForegroundColor Green
    $selection = [int](Read-Host "Digite o número do servidor que deseja gerenciar").Trim()

    if ($selection -gt 0 -and $selection -le $servers.Count) {
        $serverName = $servers[$selection - 1]
        Write-Host "Você selecionou o servidor: $serverName" -ForegroundColor Yellow
        return $serverName
    } else {
        Write-Host "Seleção inválida. Por favor, tente novamente." -ForegroundColor Red
        return $null
    }
}

function Get-InactiveUsers {
    param ([string]$serverName)
    $maxTries = 3
    $tries = 0

    do {
        $tries++
        try {
            $month = [int](Read-Host "Digite o número do mês (ex: 04)").Trim()
            $year = [int](Read-Host "Digite o ano (ex: 2025)").Trim()
            $targetDate = Get-Date -Month $month -Year $year -Day 1

            Write-Host "Procurando usuários com último logon em $($targetDate.ToString('MM/yyyy'))..." -ForegroundColor Yellow

            $inactiveUsers = Invoke-Command -ComputerName $serverName -ScriptBlock {
                cd 'C:\Users\'
                .\last_logon.ps1 | Where-Object { 
                    $_.Loadtime.Month -eq $Using:month -and $_.Loadtime.Year -eq $Using:year -and $_.User -notlike "AUTORIDADE NT*"
                }
            }
            break
        } catch {
            Write-Host "Ocorreu um erro ao conectar ao servidor ou executar o comando." -ForegroundColor Red
            if ($tries -ge $maxTries) {
                Write-Host "Tentativas esgotadas. Encerrando o script." -ForegroundColor Red
                exit
            }
        }
    } while ($true)

    return $inactiveUsers
}

function Remove-SelectedUsers {
    param (
        [string]$serverName,
        [array]$users
    )

    if ($users.Count -eq 0) {
        Write-Host "Nenhum usuário inativo encontrado para a data especificada." -ForegroundColor Yellow
        return
    }

    Write-Host "---------------------------------------------------------" -ForegroundColor Green
    Write-Host "      USUÁRIOS INATIVOS ENCONTRADOS" -ForegroundColor Cyan
    Write-Host "---------------------------------------------------------" -ForegroundColor Green

    for ($i = 0; $i -lt $users.Count; $i++) {
        if ($users[$i].Loadtime) {
            Write-Host "$($i + 1). $($users[$i].User) - Último Logon: $($users[$i].Loadtime.ToString("dd/MM/yyyy HH:mm:ss"))"
        } else {
            Write-Host "$($i + 1). $($users[$i].User) - Último Logon: N/A"
        }
    }
    
    Write-Host "---------------------------------------------------------" -ForegroundColor Green
    Write-Host "Opções:" -ForegroundColor Magenta
    Write-Host "  Digite o(s) número(s) para remover (ex: 1, 3)" -ForegroundColor Magenta
    Write-Host "  Digite 'T' para remover TODOS os listados" -ForegroundColor Magenta
    Write-Host "  Digite 'S' para sair sem remover" -ForegroundColor Magenta
    Write-Host "---------------------------------------------------------" -ForegroundColor Green

    $selection = Read-Host "Digite sua seleção"

    if ($selection.Trim().ToUpper() -eq "S") {
        Write-Host "Nenhum perfil será removido." -ForegroundColor Yellow
        return
    }

    $usersToRemove = @()

    # Opção para remover todos
    if ($selection.Trim().ToUpper() -eq "T") {
        $usersToRemove = $users
    } else {
        # Lógica original de seleção múltipla por número
        $selection.Split(',') | ForEach-Object {
            $indexStr = $_.Trim()
            if ($indexStr -match '^\d+$') {
                $index = [int]$indexStr
                if ($index -gt 0 -and $index -le $users.Count) {
                    $usersToRemove += $users[$index - 1]
                }
            }
        }
    }

    if ($usersToRemove.Count -eq 0) {
        Write-Host "Nenhuma seleção válida feita. Encerrando." -ForegroundColor Red
        return
    }

    Write-Host "Você selecionou os seguintes usuários para remover:" -ForegroundColor Yellow
    $usersToRemove | ForEach-Object { Write-Host " - $($_.User)" }
    
    Write-Host "CONFIRMAR EXCLUSÃO DE $($usersToRemove.Count) PERFIL(S)? (S/N) " -ForegroundColor Red -NoNewline
    $confirm = Read-Host
    if ($confirm.Trim().ToUpper() -ne 'S') {
        Write-Host "Operação cancelada." -ForegroundColor Yellow
        return
    }

    foreach ($user in $usersToRemove) {
        $userName = $user.User.Trim()
        
        if ($userName.Contains("\")) {
            $split = $userName.Split("\")
            $userName = $split[1]
        }
        
        Write-Host "Removendo perfil do usuário $userName..." -ForegroundColor Yellow
        
        try {
            Invoke-Command -ComputerName $serverName -ScriptBlock {
                $profileToRemove = Get-CimInstance -ClassName Win32_UserProfile -Filter "LocalPath LIKE '%\\$Using:userName'"
                if ($profileToRemove) {
                    Remove-CimInstance -CimInstance $profileToRemove -ErrorAction Stop
                    Write-Host "Perfil de $Using:userName removido com sucesso." -ForegroundColor Green
                } else {
                    Write-Host "Perfil de $Using:userName não encontrado." -ForegroundColor Red
                }
            }
        } catch {
            Write-Host "Erro ao remover o perfil de $userName. Erro: $_" -ForegroundColor Red
        }
    }
    
    Write-Host "Operação de remoção concluída." -ForegroundColor Green
}

#-----------------------------------------------------------------------------------
# LÓGICA PRINCIPAL DO PROGRAMA
#-----------------------------------------------------------------------------------

try {
    Write-Host "Iniciando o script de automação..." -ForegroundColor Yellow

    $selectedServer = Select-Server
    if ($null -eq $selectedServer) { exit }

    $inactiveUsers = Get-InactiveUsers -serverName $selectedServer
    if ($null -eq $inactiveUsers) { exit }

    Remove-SelectedUsers -serverName $selectedServer -users $inactiveUsers

} catch {
    Write-Host "Ocorreu um erro fatal no script." -ForegroundColor Red
    Write-Host "Erro: $_" -ForegroundColor Red
}
