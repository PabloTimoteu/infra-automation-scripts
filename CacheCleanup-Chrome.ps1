# ================================
# CONFIG
# ================================
$logPath = "C:\Temp\ChromeCacheCleanup.log"
$usersPath = "C:\Users"

# Garante que a pasta de logs existe
if (!(Test-Path "C:\Temp")) { New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null }

Function Write-Log {
    param ($msg)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time - $msg" | Out-File -Append -FilePath $logPath -Encoding utf8
}

Write-Log "==== INÍCIO DA LIMPEZA ===="

# ================================
# VARIÁVEIS DE CONTROLE
# ================================
$totalFreedMB = 0
$usersCleaned = 0
$usersSkipped = 0
$skippedList = @()

# ================================
# USUÁRIOS COM CHROME ABERTO
# ================================
$activeChromeUsers = @()
try {
    # Adicionado -ErrorAction SilentlyContinue caso nenhum processo 'chrome' exista
    $activeChromeUsers = Get-Process chrome -IncludeUserName -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty UserName -Unique
}
catch {
    Write-Log "Não foi possível obter usuários do Chrome (Serviço de logon pode estar inacessível)"
}

# ================================
# LOOP USUÁRIOS
# ================================
foreach ($user in Get-ChildItem $usersPath -Directory) {

    if ($user.Name -in @("Public","Default","Default User","All Users")) { continue }

    $chromePath = "$($user.FullName)\AppData\Local\Google\Chrome\User Data"

    if (!(Test-Path $chromePath)) { continue }

    # Verifica se o usuário atual está com o Chrome aberto
    $isActive = $false
    foreach ($procUser in $activeChromeUsers) {
        if ($procUser -like "*\$($user.Name)") {
            $isActive = $true
            break
        }
    }

    if ($isActive) {
        $usersSkipped++
        $skippedList += $user.Name
        Write-Log "Pulando (Chrome em uso): $($user.Name)"
        continue
    }

    Write-Log "Limpando usuário: $($user.Name)"
    $userFreedMB = 0

    # Busca perfis (Default e Profile X)
    $profiles = Get-ChildItem -Path $chromePath -Directory | Where-Object {
        $_.Name -eq "Default" -or $_.Name -like "Profile*"
    }

    foreach ($profile in $profiles) {
        $folders = @("Cache","Code Cache","GPUCache")

        foreach ($folder in $folders) {
            $fullPath = Join-Path $profile.FullName $folder

            if (Test-Path $fullPath) {
                try {
                    # --- CORREÇÃO DO ERRO ---
                    # 1. Filtramos apenas arquivos (-File)
                    # 2. Usamos uma variável intermediária para a medida
                    $files = Get-ChildItem $fullPath -Recurse -File -ErrorAction SilentlyContinue
                    
                    if ($null -ne $files) {
                        $measure = $files | Measure-Object -Property Length -Sum
                        $size = if ($null -eq $measure.Sum) { 0 } else { $measure.Sum }
                    } else {
                        $size = 0
                    }
                    # ------------------------

                    $sizeMB = [math]::Round($size / 1MB, 2)

                    # Se maior que 50MB, limpa (ajustado para tratar $sizeMB nulo)
                    if ($sizeMB -gt 50) {
                        Remove-Item "$fullPath\*" -Recurse -Force -ErrorAction SilentlyContinue
                        $userFreedMB += $sizeMB
                        $totalFreedMB += $sizeMB
                        Write-Log "  $($profile.Name) - $folder limpo ($sizeMB MB)"
                    }
                    else {
                        Write-Log "  $($profile.Name) - $folder ignorado ($sizeMB MB)"
                    }
                }
                catch {
                    Write-Log "  ERRO ao limpar $folder em $($profile.Name): $($_.Exception.Message)"
                }
            }
        }
    }

    if ($userFreedMB -gt 0) {
        $usersCleaned++
        Write-Log "TOTAL LIBERADO usuário $($user.Name): $userFreedMB MB"
    }
}

# ================================
# RESUMO FINAL
# ================================
$totalFreedGB = [math]::Round($totalFreedMB / 1024, 2)

Write-Log "==== RESUMO ===="
Write-Log "Espaço total liberado: $totalFreedMB MB ($totalFreedGB GB)"
Write-Log "Usuários limpos: $usersCleaned"
Write-Log "Usuários ignorados (Chrome aberto): $usersSkipped"

if ($usersSkipped -gt 0) {
    Write-Log "Lista usuários ignorados: $($skippedList -join ', ')"
}

Write-Log "==== FIM DA LIMPEZA ===="