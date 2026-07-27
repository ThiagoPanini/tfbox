# Triage labels

As skills de engenharia falam em cinco papéis de triagem. Este arquivo mapeia esses papéis para as strings de label efetivamente usadas neste tracker.

Este repo usa o **vocabulário canônico verbatim**: sem aliases e sem namespace.

| Papel na skill    | Label neste tracker | Significado                                   |
| ----------------- | ------------------- | --------------------------------------------- |
| `needs-triage`    | `needs-triage`      | Mantenedor precisa avaliar                    |
| `needs-info`      | `needs-info`        | Aguardando informação de quem reportou        |
| `ready-for-agent` | `ready-for-agent`   | Especificada; pronta para um agente AFK pegar |
| `ready-for-human` | `ready-for-human`   | Requer decisão ou implementação humana        |
| `wontfix`         | `wontfix`           | Não será tratada                              |

## A família ortogonal, que já existia

Este tracker carrega uma segunda família de labels, de **assunto**, anterior aos papéis de triagem e independente deles: `app`, `bug`, `config`, `doc`, `enhancement`, `feature`, `infra`, `observability`, `tests`, mais `breaking-change` e `in-progress`.

As duas famílias não competem: uma issue tem um papel de triagem e zero ou mais assuntos. Ler um assunto como papel é o erro que este parágrafo existe para evitar, porque `feature` e `bug` **parecem** estados de fila e não são.

Os labels de automação (`github-bot`, `dependencies`, `javascript`, `github_actions`) são escritos por robô e não são triagem: eles descrevem a origem do PR, não o que falta nele.

> **O vocabulário é um slot, não um invariante.** A anatomia panlabs obriga que todo repo **declare** seu vocabulário neste arquivo; não obriga que declare *este* vocabulário. Outros repos da org usam dialetos diferentes e são igualmente conformes.
>
> Consequência para qualquer script de frota, incluindo o checker de conformidade: **leia o valor declarado, nunca crave o label no código.**
