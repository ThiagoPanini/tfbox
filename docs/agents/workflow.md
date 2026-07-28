# Fluxo de desenvolvimento

## A esteira

```
worktree por issue  →  /tdd  →  commit  →  push  →  checks verdes  →  PR automático  →  merge no verde
```

O worktree nasce **aninhado no próprio repo**, em `.claude/worktrees/<nome>`, que é onde o script de espaço de trabalho da máquina espera encontrá-lo. Aninhar deixa visível na árvore a relação entre worktree e repo, que de outro modo só existe dentro do git.

## Branch, e o que ela dispara

O gatilho da CI é o **nome da branch**, e uma branch fora dos padrões declarados em [`.github/workflows/pr-checks.yml`](../../.github/workflows/pr-checks.yml) não dispara checagem nenhuma. Isso não é aviso teórico: sob o ruleset da org, um PR sem os required checks publicados não fica vermelho, fica **pendurado para sempre** esperando um status que ninguém vai publicar.

Os padrões que valem hoje: `feature**` e `docs**` (a convenção histórica deste repo), as branches de versão (`v0.1.0`, `v0.1.x`, `0.1.x`), os prefixos convencionais (`feat/`, `fix/`, `chore/`, `config/`, `ci/`, `refactor/`, `test/`), as branches de worktree de agente e `dependabot/**`.

O prefixo do Dependabot está lá pelo mesmo motivo: sem ele, o PR do robô não dispara checagem nenhuma e nunca alcança condição de merge.

## Os dois portões

**Portão 1, local, antes do commit.** Mora em [`lefthook.yml`](../../lefthook.yml) e [`commitlint.config.mjs`](../../commitlint.config.mjs). Ele formata e verifica o que está no índice, roda o scan de segredos e verifica a mensagem de commit. A anatomia panlabs o cobra em três itens: `local-commit-gate-exists`, `commit-message-standard-declared` e `secret-scan-before-commit`.

O scanner é `gitleaks` e não outro **por decisão, não por gosto**: é o mesmo binário que o portão 2 roda, e dois scanners diferentes fariam "passou no local" e "passou na CI" significarem coisas diferentes, que é exatamente o que o par de portões existe para impedir.

As ferramentas do portão 1 (`lefthook`, `gitleaks`, o runtime que serve o `npx`) são **equipamento da máquina**, provisionado globalmente; o que este repo versiona é a **declaração** de adesão. Um repo aberto numa máquina sem equipamento provisionado perde capacidade por design, e não por omissão.

**Portão 2, CI, no push.** Mora em `.github/workflows/pr-checks.yml`, e é ele que decide se o PR pode mergear.

## O contrato de nomes de status check

Todo repo da org publica os **mesmos dois nomes** de status check, `checks` e `security`, independentemente de quantas superfícies tem por baixo. Isso é feito por um **job de rollup** de id fixo `checks`, que declara `needs` sobre as pernas por superfície e agrega o resultado delas explicitamente.

Aqui as pernas são duas, e as duas são **locais**:

| perna | o que roda | por que é local |
| --- | --- | --- |
| `checks-terraform` | `fmt -check`, `init -backend=false` e `validate`, um por módulo de `aws/` | Terraform existe em um repo só da frota, e um reusable workflow de um consumidor único é abstração sem retorno. |
| `checks-node` | constrói o catálogo em `scripts/`, roda os testes do parser, e então typecheck e build em `web/` | A superfície Node deste repo tem **dois** manifestos com dependência de ordem entre eles: `web/` não compila antes de `scripts/` gerar `catalog.json`. O `checks-node.yml` compartilhado roda numa pasta só, sem passo entre a instalação e o lint, e não tem como expressar essa ordem. |

**O lint de `web/` não roda em portão nenhum, e isso é dívida conhecida, não decisão.** `npm run lint` está quebrado na `main`: o ESLint 10 que o Dependabot trouxe é incompatível com o `eslint-plugin-react` que vem dentro do `eslint-config-next`, e o comando morre com `TypeError: ... getFilename is not a function` antes de avaliar regra nenhuma. Ligar a etapa na CI hoje deixaria a perna vermelha por causa da dependência, e não do código. Consertar a dependência e então ligar a etapa é trabalho à parte.

Manter perna local é caminho previsto, não desvio: o `life-under-control` faz o mesmo com a perna Python dele, porque `services` de job não é parametrizável por input de `workflow_call`.

O que **não** é local é o scan de segredos: `security-scan` chama o [`security.yml` compartilhado](https://github.com/panlabs-tech/.github/blob/v1.0.0/.github/workflows/security.yml), pinado por tag exata. É por essa referência que este repo deixa de ser mais um YAML copiado que deriva sozinho.

Duas armadilhas moram nesse desenho, e as duas já morderam alguém:

- **Sem `if: always()` mais checagem explícita de `needs.*.result`**, uma perna vermelha faz o rollup ser **pulado** em vez de reprovado. Pulado não satisfaz um required check, mas também não bloqueia.
- **Um job que chama reusable workflow via `uses:` publica o check como `<job do caller> / <job do chamado>`**, nunca só com o nome do job do caller, e não há como suprimir. É por isso que existe um `security-scan` que chama, e um `security` de fachada que só agrega: o nome exato que o ruleset exige é o do segundo.

Enquanto a CI de um repo não publica esses dois nomes, o script de ruleset da org **retém** aquele repo em vez de convergi-lo, e `--only panlabs-tech/tfbox` é como o operador afirma que o retrofit aterrissou.

## Mensagem de commit, que aqui também é a versão

Neste repo a mensagem de commit não é só convenção: ela é a **entrada do release**. O `techpivot/terraform-module-releaser` lê o **subject** dos commits do PR e decide o incremento de versão de cada módulo tocado a partir de palavra-chave:

| incremento | palavra-chave no subject |
| --- | --- |
| major | `major change`, `breaking change` |
| minor | `feat`, `feature` |
| patch | `fix`, `hotfix`, `chore`, `docs`, `config`, `ci` |

A consequência é dura e fácil de não notar: um commit de tipo **fora** dessa lista muda código e **não gera versão nenhuma**. `refactor:` num módulo publica a mudança sem tag que a nomeie, e nada acusa.

É por isso que o `type-enum` do [`commitlint.config.mjs`](../../commitlint.config.mjs) é exatamente essa lista, e não a lista default do Conventional Commits. O portão local recusa no commit o tipo que o release ignoraria depois, que é o único momento em que a correção ainda é barata.

**Prefixo de branch e tipo de commit são dois eixos, e as duas listas divergem de propósito.** A lista de gatilho é deliberadamente **mais larga** que o `type-enum`: uma branch `refactor/` ou `test/` dispara a CI normalmente, e os commits dela levam um tipo da lista de cima (`chore:` costuma ser o certo). A assimetria segue a assimetria dos danos. Branch que não dispara CI pendura o PR para sempre, então o gatilho erra para o lado de aceitar; tipo fora da lista publica mudança sem versão, então o `type-enum` erra para o lado de recusar.

Tags de módulo saem como `aws/<nome>/vX.Y.Z`.

## Os arquivos de workflow, e uma restrição da plataforma

Reusable workflow referenciado localmente precisa estar no **topo** de `.github/workflows/`. Subdiretório não é suportado para referência local, e o sintoma é um erro de resolução no momento do disparo, não um aviso na edição.

Nome de workflow, de job e de passo é **descritivo e sem emoji**. Os arquivos antigos deste repo carregam emoji no `name:` e ficaram como estão; arquivo novo não ganha mais. O nome do job não é enfeite quando ele é o nome de um status check: é string que o ruleset compara.

Os arquivos, e o gatilho de cada um:

| arquivo | gatilho | papel |
| --- | --- | --- |
| `pr-checks.yml` | push nas branches de trabalho | o portão 2: as duas pernas, o rollup, o scan de segredos e o PR automático |
| `pr-gate.yml` | `pull_request` para `main`, inclusive `closed` | valida de novo no PR e **corta o release** no merge; precisa do evento `closed`, e é por isso que não foi absorvido pelo `pr-checks.yml` |
| `deploy.yml` | push na `main` | publica `web/out` no GitHub Pages |
| `reusable-modules-validation.yml`, `reusable-catalog-validation.yml` | `workflow_call` | as duas pernas, chamadas pelos dois callers acima |

Módulo novo em `aws/` entra na lista `modules` em **dois** lugares, `pr-checks.yml` e `pr-gate.yml`, porque não há descoberta automática. Esquecer um dos dois deixa o módulo sem validação numa das metades da esteira.

## Merge autônomo

O agente mergeia no verde. Sob squash como único método de merge, quem assina o commit que aterrissa na branch default é o GitHub, e por isso o commit local do agente não precisa ser assinado.

O título do PR vira a mensagem do commit que aterrissa. Ele obedece o mesmo contrato da seção de mensagem de commit, pela mesma razão: é ele que o histórico da `main` vai carregar.
