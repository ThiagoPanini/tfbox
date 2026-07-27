// O padrão de mensagem de commit deste repo, lido pelo `commit-msg` de
// `lefthook.yml`. Conventional Commits com subject minúsculo.
//
// O arquivo é `.mjs` e não `.js` por um motivo mecânico: a raiz deste repo não
// tem `package.json`, então o Node trata `.js` como CommonJS e `export default`
// falha. A extensão é o que declara o módulo aqui.
//
// **O `type-enum` não é o default do Conventional Commits, e essa diferença é a
// razão de este arquivo existir com regra própria.** Neste repo a mensagem de
// commit é a entrada do release: o `techpivot/terraform-module-releaser` lê o
// subject dos commits do PR e decide o incremento de versão de cada módulo
// tocado a partir de palavra-chave.
//
//   major   `major change`, `breaking change`
//   minor   `feat`, `feature`
//   patch   `fix`, `hotfix`, `chore`, `docs`, `config`, `ci`
//
// Um tipo fora dessa lista muda código e **não gera versão nenhuma**:
// `refactor:` num módulo publica a mudança sem tag que a nomeie, e nada acusa.
// A lista abaixo é exatamente a do releaser, para que o portão local recuse no
// commit o tipo que o release ignoraria depois, que é o único momento em que a
// correção ainda é barata.
//
// Incremento major continua sendo expresso no subject, com as palavras que o
// releaser procura, depois de um tipo válido: `feat(iam-role): breaking change
// no contrato de saída`.
export default {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "subject-case": [2, "always", "lower-case"],
    "type-enum": [
      2,
      "always",
      ["feat", "feature", "fix", "hotfix", "chore", "docs", "config", "ci"],
    ],
  },
};
