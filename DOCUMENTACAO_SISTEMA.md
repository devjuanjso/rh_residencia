# Documentação do Sistema — RH Residência

**Versão:** 1.0  
**Data:** Maio de 2026  
**Projeto:** Plataforma de Gestão de RH — Venturus  

---

## Sumário

1. [Visão Geral do Sistema](#1-visão-geral-do-sistema)
2. [Perfis de Usuário](#2-perfis-de-usuário)
3. [Acesso ao Sistema — Login](#3-acesso-ao-sistema--login)
4. [Tela Inicial e Navegação](#4-tela-inicial-e-navegação)
5. [Projetos](#5-projetos)
6. [Vagas](#6-vagas)
7. [Candidaturas](#7-candidaturas)
8. [Recomendações por IA](#8-recomendações-por-ia)
9. [Perfil do Usuário](#9-perfil-do-usuário)
10. [Fluxo Completo por Tipo de Usuário](#10-fluxo-completo-por-tipo-de-usuário)

---

## 1. Visão Geral do Sistema

O **RH Residência** é uma plataforma mobile desenvolvida para a Venturus com o objetivo de centralizar e facilitar o processo de divulgação de projetos, abertura de vagas internas e candidatura de colaboradores. O sistema também conta com um mecanismo de **recomendação automática por Inteligência Artificial**, que sugere os candidatos mais compatíveis com cada vaga com base no perfil de cada colaborador.

A plataforma conecta três partes:
- O time de **RH/Administração**, responsável por cadastrar projetos e vagas;
- Os **Colaboradores**, que podem se candidatar às vagas disponíveis;
- O **Motor de IA**, que analisa perfis e sugere candidatos automaticamente.

---

> **[IMAGEM — Diagrama geral do sistema ou tela inicial do app]**

---

## 2. Perfis de Usuário

O sistema possui três tipos de usuário, cada um com permissões específicas:

### Administrador (Admin)
Possui acesso completo ao sistema. Pode criar e gerenciar projetos, vagas e visualizar todas as candidaturas e recomendações.

### RH
Perfil destinado ao time de Recursos Humanos. Pode criar projetos, abrir vagas, consultar candidaturas e visualizar as recomendações geradas pela IA.

### Colaborador
Perfil dos funcionários da empresa. Pode visualizar os projetos publicados, se candidatar a vagas disponíveis e acompanhar o status das suas candidaturas.

---

| Funcionalidade              | Admin | RH  | Colaborador |
|-----------------------------|:-----:|:---:|:-----------:|
| Criar projetos              | ✅    | ✅  | ❌          |
| Editar e publicar projetos  | ✅    | ✅  | ❌          |
| Criar vagas                 | ✅    | ✅  | ❌          |
| Ver candidatos por vaga     | ✅    | ✅  | ❌          |
| Ver recomendações de IA     | ✅    | ✅  | ❌          |
| Candidatar-se a vagas       | ✅    | ✅  | ✅          |
| Ver projetos publicados     | ✅    | ✅  | ✅          |
| Acompanhar candidaturas     | ✅    | ✅  | ✅          |
| Editar perfil pessoal       | ✅    | ✅  | ✅          |

---

## 3. Acesso ao Sistema — Login

Ao abrir o aplicativo, o usuário é direcionado para a tela de login. O acesso é feito com usuário e senha cadastrados previamente pelo time de RH.

- Caso o usuário não possua cadastro, a tela indica como entrar em contato com o RH para solicitar acesso.
- Caso o usuário esqueça a senha, há uma opção para contatar diretamente o RH.
- Após o login bem-sucedido, o sistema mantém a sessão ativa automaticamente, dispensando novo login a cada uso.

---

> **[IMAGEM — Tela de login]**

---

## 4. Tela Inicial e Navegação

Após o login, o usuário acessa a tela principal do aplicativo, que é dividida em três abas na parte inferior da tela:

### Aba "Descobrir"
Exibe todos os projetos publicados disponíveis. O colaborador pode navegar pelos projetos, visualizar detalhes e acessar as vagas de cada projeto.

### Aba "Projetos"
- **Para RH/Admin:** Mostra os projetos criados pelo usuário, com opções de filtragem por status (todos, publicados, rascunho, encerrados). Também permite criar novos projetos.
- **Para Colaborador:** Exibe as candidaturas realizadas pelo usuário, com filtro por status (pendente, aceito, recusado).

### Aba "Perfil"
Mostra as informações do usuário logado, com opção de editar o perfil e sair do sistema.

---

> **[IMAGEM — Tela principal com as três abas de navegação]**

---

## 5. Projetos

Projetos são a unidade central do sistema. Cada projeto representa uma iniciativa da empresa e pode conter uma ou mais vagas.

### Criando um Projeto (RH/Admin)

Para criar um projeto, o usuário de RH acessa a aba "Projetos" e utiliza o botão de criação. As informações necessárias são:

- **Nome do projeto**
- **Descrição** — breve apresentação do projeto
- **Tipo** — pode ser: Produto Digital, Serviço, Pesquisa ou Outro
- **Data de início**
- **Imagem** (opcional) — foto ou capa do projeto
- **Status inicial** — Rascunho ou Publicado

---

> **[IMAGEM — Tela de criação/edição de projeto]**

---

### Status de um Projeto

Um projeto pode estar em três estados:

- **Rascunho:** visível apenas para RH/Admin. Ainda não foi divulgado aos colaboradores.
- **Publicado:** visível para todos os colaboradores na aba "Descobrir". Aceita candidaturas.
- **Encerrado:** projeto finalizado. As vagas não aceitam mais candidaturas.

---

> **[IMAGEM — Lista de projetos com diferentes status]**

---

### Visualizando um Projeto

Ao tocar em um projeto na lista, o usuário acessa a página de detalhes com todas as informações e a lista de vagas vinculadas ao projeto.

---

> **[IMAGEM — Tela de detalhe de um projeto]**

---

## 6. Vagas

Vagas são as posições abertas dentro de um projeto. Cada vaga possui requisitos específicos que servirão como base para as recomendações da IA.

### Criando uma Vaga (RH/Admin)

A criação de vaga é feita dentro de um projeto. As informações solicitadas são:

- **Título da vaga**
- **Nível de senioridade** — Estagiário, Júnior, Pleno, Sênior ou Especialista
- **Área de atuação** — Inovação, Tecnologia, Dados, Design, Produto, Negócios, Marketing ou Operações
- **Habilidades necessárias** — lista de competências técnicas ou comportamentais
- **Certificações necessárias** (opcional)
- **Formação desejada** (opcional)

---

> **[IMAGEM — Tela de criação/edição de vaga]**

---

### Visualizando Vagas

A lista de vagas aparece na página de detalhes do projeto. Cada vaga exibe o título, área e o número de candidatos inscritos. Ao tocar em uma vaga, o usuário visualiza todos os requisitos detalhados.

---

> **[IMAGEM — Lista de vagas de um projeto]**

---

> **[IMAGEM — Tela de detalhe de uma vaga]**

---

## 7. Candidaturas

### Como o Colaborador se Candidata

Ao visualizar os detalhes de uma vaga, o colaborador pode submeter sua candidatura com um único toque. O sistema registra a candidatura e notifica o time de RH.

Cada colaborador pode se candidatar a uma vaga apenas uma vez.

---

> **[IMAGEM — Botão de candidatura na tela de vaga]**

---

### Acompanhamento de Candidaturas (Colaborador)

Na aba "Projetos", o colaborador visualiza todas as suas candidaturas com as seguintes informações:

- Nome do projeto e da vaga
- Data da candidatura
- Status atual: **Pendente**, **Aceito** ou **Recusado**

O colaborador pode usar filtros para visualizar candidaturas por status e buscar pelo nome do projeto ou vaga.

---

> **[IMAGEM — Tela de candidaturas do colaborador com filtros]**

---

### Gestão de Candidaturas (RH/Admin)

O time de RH pode visualizar todos os candidatos inscritos em cada vaga e atualizar o status de cada candidatura (aceitar ou recusar).

---

> **[IMAGEM — Lista de candidatos por vaga, visão do RH]**

---

## 8. Recomendações por IA

O sistema conta com um mecanismo de Inteligência Artificial que analisa automaticamente os perfis dos colaboradores e sugere os mais compatíveis para cada vaga aberta.

### Como Funciona

A IA compara os dados do perfil de cada colaborador (habilidades, área de atuação, senioridade, certificações, formação) com os requisitos definidos na vaga. Com base nessa análise, é gerado um **índice de compatibilidade** para cada candidato em potencial.

### Consultando Recomendações (RH/Admin)

Dentro da página de uma vaga, o RH pode abrir o painel de recomendações. Nele são exibidos:

- Lista de colaboradores recomendados, ordenados por compatibilidade
- Percentual de compatibilidade de cada candidato
- Informações do perfil: nome, área, senioridade, habilidades, LinkedIn e foto

O RH pode aceitar ou recusar cada recomendação diretamente nessa tela.

---

> **[IMAGEM — Painel de recomendações com lista de candidatos e scores]**

---

> **[IMAGEM — Detalhe do perfil de um candidato recomendado]**

---

## 9. Perfil do Usuário

Cada usuário possui um perfil com informações profissionais que são utilizadas tanto para exibição quanto para o motor de recomendação da IA.

### Informações do Perfil

- Nome e foto
- Cargo atual e nível de senioridade
- Área de atuação
- Habilidades técnicas e comportamentais
- Certificações
- Formação acadêmica
- Bio / Descrição pessoal
- Link para o LinkedIn

### Editando o Perfil

O usuário pode editar suas informações a qualquer momento acessando a aba "Perfil" e tocando na opção de edição. Manter o perfil atualizado é importante para que as recomendações da IA sejam precisas.

---

> **[IMAGEM — Tela de visualização do perfil]**

---

> **[IMAGEM — Tela de edição do perfil]**

---

## 10. Fluxo Completo por Tipo de Usuário

### Fluxo do Colaborador

```
Login
  └── Aba "Descobrir"
        └── Visualizar projetos publicados
              └── Abrir projeto → Ver vagas
                    └── Abrir vaga → Candidatar-se
  └── Aba "Projetos"
        └── Acompanhar candidaturas (status: pendente / aceito / recusado)
  └── Aba "Perfil"
        └── Visualizar e editar perfil pessoal
```

---

> **[IMAGEM — Diagrama de fluxo do colaborador]**

---

### Fluxo do RH / Admin

```
Login
  └── Aba "Descobrir"
        └── Visualizar todos os projetos publicados
  └── Aba "Projetos"
        └── Criar novo projeto
        └── Gerenciar projetos (rascunho / publicado / encerrado)
              └── Criar vagas no projeto
                    └── Ver candidatos inscritos
                    └── Consultar recomendações da IA
                    └── Aceitar ou recusar candidaturas
  └── Aba "Perfil"
        └── Visualizar e editar perfil pessoal
        └── Sair do sistema
```

---

> **[IMAGEM — Diagrama de fluxo do RH/Admin]**

---

*Documento gerado em maio de 2026 — Projeto RH Residência / Venturus*
