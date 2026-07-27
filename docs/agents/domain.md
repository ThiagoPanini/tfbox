# Domain docs

Este repo é **single-context**: um domínio só, e nenhum limite interno que valha um diretório por contexto. Os documentos de domínio moram na raiz, e este diretório carrega só a configuração de agente.

## Onde está o quê

| Documento | Papel |
| --- | --- |
| [`AGENTS.md`](../../AGENTS.md) (raiz) | A fonte-da-verdade da orientação de agente: layout, comandos, CI, convenções por camada. `CLAUDE.md` a referencia em vez de duplicá-la. |
| [`DESIGN.md`](../../DESIGN.md) (raiz) | A especificação de design do site de catálogo. Ver [`design.md`](design.md). |
| [`catalog.schema.json`](../../catalog.schema.json) (raiz) | O contrato entre o construtor de catálogo e o site: o que `scripts/` emite e o que `web/` consome. |
| `docs/agents/` | Como um agente trabalha **neste** repo. |
| `docs/articles/` | Material de apresentação, datado no nome do arquivo. Não é contrato de nada. |

## A direção do fluxo, que é a regra mais importante daqui

Os módulos Terraform de `aws/` são **o produto**. `scripts/` e `web/` renderizam documentação a partir deles, e nunca o contrário.

A consequência prática: para corrigir o que o catálogo diz sobre um módulo, edite o `.tf` e regenere. Editar a saída do catálogo produz uma descrição que a próxima build apaga, e o defeito volta sem ninguém entender por quê.

## Vocabulário

Termos que aparecem em issues, commits e código, e que significam algo específico aqui:

- **Módulo**: um diretório `aws/<nome>/`, publicável e consumível por si, com versão própria. Não é pasta de organização: é a unidade de release.
- **Catálogo**: o `catalog.json` gerado por `scripts/build-catalog.ts` a partir de todos os módulos. Artefato de build, fora do git, nunca editado à mão.
- **Header de arquivo**: o bloco de comentário no topo de todo `.tf`, com `FILE`, `MODULE`, `DESCRIPTION` e `RESOURCES`. É **crítico para o parser**, não decoração: é de `DESCRIPTION:` que sai o resumo do módulo no catálogo.
- **Categoria**: a classificação do módulo no site, inferida do tipo do recurso principal por `scripts/category-map.ts`. Recurso novo sem entrada no mapa cai sem categoria.
- **Releaser**: o `techpivot/terraform-module-releaser`, que lê o subject dos commits e corta tag por módulo tocado. Ver [`workflow.md`](workflow.md).
- **Superfície**: uma stack presente no repo. Aqui são três: `terraform` em `aws/`, e `node` em `scripts/` e `web/`. A anatomia panlabs avalia item de stack **por superfície**, não por repo.
- **Perna**: um job de checks de uma superfície, agregado pelo rollup. Ver [`workflow.md`](workflow.md).
- **Conforme**: o checker de conformidade da org passa inteiro neste repo. Leitura binária; não existe nível intermediário.

## Invariantes entre camadas

Três amarras que atravessam o repo e que uma mudança de um lado só quebra em silêncio no outro:

1. `catalog.schema.json` e `web/lib/types.ts` descrevem a mesma coisa em duas linguagens. Mudam **juntos**.
2. A lista `modules` existe em dois workflows, sem descoberta automática. Módulo novo entra nos dois.
3. As flags de CLI de `scripts/build-catalog.ts` são chamadas pelo script `catalog` de `web/package.json` e pela perna de checks. Renomear flag sem atualizar os dois chamadores quebra a build, e não o teste.

## Onde o porquê está escrito

Este repo é parte da frota `panlabs-tech`, e o padrão que ele obedece (anatomia de repo, CI compartilhada, contrato de status check, conformidade) é definido em [`panlabs-tech/.github`](https://github.com/panlabs-tech/.github). Quando uma escolha de configuração daqui parecer arbitrária, o motivo dela provavelmente está lá, e não aqui.
