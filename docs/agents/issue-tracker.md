# Issue tracker

As issues deste repo vivem como **issues do GitHub** em `panlabs-tech/tfbox`. Use a CLI `gh` para todas as operações.

## O que entra

Trabalho sobre o **produto** deste repo, que são as três camadas descritas em [`AGENTS.md`](../../AGENTS.md):

- os módulos Terraform de `aws/`, que são o produto;
- o construtor de catálogo de `scripts/`, que os lê;
- o site de catálogo de `web/`, que renderiza o resultado.

## O que não entra

**O padrão panlabs em si.** Configuração da org, anatomia de repo, CI compartilhada e conformidade têm tracker próprio, em [`panlabs-tech/.github`](https://github.com/panlabs-tech/.github/issues). Uma issue de retrofit deste repo mora **lá**, e não aqui: abrir issue em outro projeto é tocar outro projeto, e o alvo daquele trabalho é do repo meta por natureza. O retrofit que trouxe este arquivo é a [issue #38](https://github.com/panlabs-tech/.github/issues/38) daquele tracker.

## Como uma issue nasce

Issue em branco está **desligada** (`.github/ISSUE_TEMPLATE/config.yml`): toda issue nova entra por um dos cinco formulários de `.github/ISSUE_TEMPLATE/`, que são bug, documentação, feature, performance e pergunta. O formulário é a triagem mais barata que existe, porque ele cobra o campo antes de alguém precisar pedir.

## O que não é superfície de triagem

**PRs externos.** Esta é uma org de um mantenedor; PR de fora não faz parte do fluxo de triagem.

**PR do Dependabot.** Ele abre, os checks rodam, e o destino dele é o portão de CI, não a fila de triagem.
