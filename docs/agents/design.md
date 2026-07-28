# Design

Este documento existe porque o repo **tem interface**: o site de catálogo de `web/`, declarado em manifesto Node com `next` e `react`. A anatomia panlabs cobra o documento de design onde há interface, e não cobra onde não há.

## A especificação canônica é [`DESIGN.md`](../../DESIGN.md)

Ela é da raiz e é a fonte-da-verdade. **Leia antes de escrever ou alterar qualquer UI.** Este arquivo não a resume: ele diz o que ela é, onde cada decisão dela vive em código, e o que um agente precisa saber antes de tocar em pixel.

O que `DESIGN.md` carrega, em ordem:

| Seção | O que decide |
| --- | --- |
| Design brief | A direção estética, os padrões de layout adotados, as interações que valem copiar e os anti-padrões deliberadamente evitados. |
| Tipografia e tokens de cor | Os valores, em HSL, com **dark como default**. |
| Inventário de componentes | Qual componente existe e o que é dele. |
| Checklist de auto-verificação | O que conferir antes de declarar uma mudança de UI pronta. |
| Registro de desvio | Onde o código divergiu da spec **de propósito**, com o motivo. Um desvio novo entra aqui; sem isso, o próximo leitor conserta o que era intenção. |

## Onde cada decisão de design mora em código

| Decisão | Arquivo |
| --- | --- |
| Tokens de cor, espaçamento, camada de tipografia | `web/app/globals.css` e `web/tailwind.config.ts` |
| Tema e default escuro | `next-themes`, via `web/components/theme-provider.tsx` e `theme-toggle.tsx` |
| Primitivas acessíveis (diálogo, abas, tooltip) | Radix, nos componentes de `web/components/` |
| Realce de sintaxe HCL | Shiki, em `web/lib/shiki.ts`, resolvido em **build time** dentro de RSC |
| Busca e paleta de comandos | Fuse.js e `cmdk`, em `web/components/command-palette.tsx` |
| Diagrama de recursos | `reactflow` mais `dagre`, em `web/components/diagram-client.tsx` |

## Restrições que mudam o desenho, não só a implementação

O site é **static export** (`output: "export"`). Isso não é detalhe de deploy: é limite de design, porque interação que dependeria de servidor não existe aqui.

- Sem handler de servidor, sem middleware, sem `headers()` nem `cookies()`.
- Rota dinâmica só com `generateStaticParams`.
- `next/image` sem loader remoto (`images.unoptimized: true`).
- **RSC por default.** `"use client"` só onde o componente precisa de estado, efeito, ref ou API de navegador: busca, paleta, diagrama e alternador de tema.
- O site é publicado sob o basePath `/tfbox`. Link interno relativo; URL absoluta prefixa `NEXT_PUBLIC_BASE_PATH`.

## O que o portão verifica, e o que ele não verifica

A perna `checks-node` roda typecheck e build de `web/`. A build é a parte que importa aqui: o static export **falha alto** em erro de RSC e de serialização que o typecheck sozinho não vê.

O **lint não roda**, e é dívida conhecida: `npm run lint` está quebrado na `main` por incompatibilidade entre o ESLint 10 e o `eslint-plugin-react` embutido no `eslint-config-next`. Ver [`workflow.md`](workflow.md).

O que nenhum portão verifica é se a mudança **parece** certa. Os pontos de acessibilidade e responsividade que `DESIGN.md` cobra (anel de foco visível, navegação por teclado nas primitivas Radix, layout em 375, 768 e 1440) têm asserção em `web/e2e/smoke.spec.ts`, que é Playwright e roda sob demanda, fora do portão. Rodar é decisão de quem mexeu na UI.
