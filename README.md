# 🚀 Infra Automation Scripts

Repositório dedicado à automação de rotinas de infraestrutura, focado em otimização de recursos e padronização de ambientes Windows/Cloud.

---

## 📂 Case Real: O "Vilão" do Disco em Ambientes TS
### 🚩 O Problema
Com o avanço da inteligência artificial e motores de renderização pesados, os navegadores (especialmente o **Google Chrome**) tornaram-se grandes consumidores de disco. 

Em ambientes de **Terminal Service (TS)**, isso é um desafio crítico. No meu dia a dia, identifiquei perfis de usuários com **3GB a 6GB** de tamanho. Em um servidor com 50 usuários, estamos falando de até **300GB de lixo eletrônico** ocupando storage de alta performance.

### 💡 A Solução
Após analisar quais pastas eram as grandes vilãs, identifiquei que o `Cache`, `Code Cache` e `GPUCache` poderiam ser limpos sem quebrar a experiência do usuário ou as políticas da empresa. Desenvolvi então uma automação em PowerShell para realizar essa manutenção de forma silenciosa e eficiente.

---

## 🛠️ Scripts Disponíveis

### 🧹 [Limpeza de Cache - Chrome](./CacheCleanup-Chrome.ps1)
* **Finalidade:** Reduzir o tamanho dos perfis de usuários em servidores TS.
* **Alvos:** Pastas de Cache, Code Cache e GPUCache.
* **Tecnologia:** PowerShell.

> **Nota:** Para ver o código-fonte e instruções de uso, [clique aqui](./CacheCleanup-Chrome.ps1).

---

## 👨‍💻 Tecnologias Utilizadas
* **PowerShell** (Automação Core)
* **Windows Server / Active Directory** (Ambiente alvo)
* **KACE SMA** (Orquestração e Deploy)

---
*Mantido por [Pablo Vinicius](https://github.com/Pbzin)*
