# 🚀 Infra Automation Scripts **(Em Construcao)** ...

Automação de rotinas de infraestrutura com PowerShell, focado em otimização de ambientes corporativos e servidores TS.

---

## 📂 Case Study: Otimização de Storage e Rede (Google Chrome em TS)

### 🚩 O Problema
Em ambientes de **Terminal Service (TS)**, o Google Chrome tornou-se um grande vilão de storage. Identifiquei perfis de usuários ocupando entre **1.7GB a 4.62GB** cada. Em um cenário que servidores com muito usuários entre 25 a 40 perfils, isso impacta muito no storage do Servidor e degrada demais a performance. Ocasionando travamentos, lentidao ao abrir um simples arquivos entre outros problemas. Cheguei a me deparar com um servidor com apenas 380 mb de espaco disponivel, imagina como estava sendo a experiencia do usuario final!?

### 🔍 A Investigação
Apos analisar mais de 20 perfil`s de usuarios, cheguei a conclusao de que os Modelos de IA do Google Chrome + cache de navegacao dos usuarios estavam impactando negativamente a performance do servidor.
Identifiquei 6 pastas principais como as maiores consumidoras de espaço:
* `OptGuideOnDeviceModel`, `optimization_guide_model_store` e `OnDeviceHeadSuggestModel` (Modelos de IA).
* `Cache`, `Code Cache` e `GPUCache`. (Cache de navegacao).

### 💡 A Solução Híbrida
Ao tentar apagar as pastas de modelos de IA, percebi que a solução era paliativa: no dia seguinte, o Chrome baixava tudo novamente, congestionando ("topando") a rede da empresa. 

Para resolver isso de forma definitiva, dividi o problema em duas partes:

1. **Camada de Política (GPO/ADMX):** Padronizei modelos ADMX para **Chrome, Edge e Firefox**. Desativei recursos desnecessários e serviços de predição, impedindo o download automático dos modelos e otimizando a experiência do usuário.
2. **Camada de Automação (PowerShell):** Desenvolvi um script que percorre a pasta raiz do navegador, identifica a existência de múltiplos perfis e realiza a limpeza seletiva das pastas de `Cache`, `Code Cache` e `GPUCache`, por seguranca caso o usuario esteja logado no servidor com o Chrome aberto, ele pulava o usuario alem de auditar o que foi apagado e quanto de espaco foi liberado no servidor.

> **Nota:** Este é um cenário específico para atender necessidades de infraestrutura. Lembre-se: cada caso é um caso!

---

## 🛠️ Scripts Disponíveis

### 🧹 [Limpeza de Cache Multi-Perfil](./CacheCleanup-Chrome.ps1)
* **Finalidade:** Manutenção de espaço em disco em servidores TS/Multi-usuário.
* **Diferencial:** Varredura dinâmica em todos os perfis do Browser dentro do perfil do Windows.

### ⚠️ [Alerta de disco](./Get-DiskSpaceReport.ps1)
* **Finalidade:** Informa quanto de espaço o disco tem disponivel e seu estado atual. 

---

## 👨‍💻 Tecnologias Utilizadas
* **PowerShell** (Automação de limpeza)
* **Modelos ADMX / GPO** (Governança e controle de rede)
* **Windows Server** 

---
*Mantido por [Pablo Vinicius](https://github.com/Pbzin)*
