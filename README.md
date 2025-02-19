<div align="center">
    <br><img src="https://github.com/ThiagoPanini/tf-modules-showcase/blob/feature/mvp-dynamodb-table-module/docs/logo.png?raw=true" width=200 alt="tf-modules-showcase-logo">
</div>

<div align="center">

  <a href="https://www.terraform.io/">
    <img src="https://img.shields.io/badge/terraform-grey?style=for-the-badge&logo=terraform&logoColor=B252D0">
  </a>

  <a href="https://aws.amazon.com/">
    <img src="https://img.shields.io/badge/aws-grey?style=for-the-badge&logo=amazon-web-services&logoColor=B252D0">
  </a>

  <a href="https://github.com/">
    <img src="https://img.shields.io/badge/github-grey?style=for-the-badge&logo=github&logoColor=B252D0">
  </a>
</div>

___

<div align="center">
  <br>
</div>

## Visão Geral

A iniciativa **Terraform Modules Showcase** visa consolidar uma série de módulos Terraform criados mediante a necessidades reais de implantação de recursos em *cloud providers*.

Em estudos ou situações práticas de trabalho envolvendo computação em nuvem, serviços precisam ser criados em *workspaces* para atender determinadas exigências de uma aplicação. Em muitos casos, a dinâmica de implementação de alguns desses serviços não envolve, necessariamente, a definição pura e individual de recursos Terraform.

Exemplificando em outras palavras, a devida implementação de um [Glue job](https://docs.aws.amazon.com/pt_br/glue/latest/dg/what-is-glue.html) na AWS dificilmente será alcançada apenas através da reclaração do recurso Terraform [aws_glue_job](https://registry.terraform.io/providers/hashicorp/aws/2.70.1/docs/resources/glue_job), mas também de outros recursos adicionais, como [aws_glue_security_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_security_configuration) para configurações de segurança do job ou até mesmo [aws_s3_bucket_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) para *upload* de *assets* utilizados no ETL.

Inspirado pelo compilado de módulos Terraform disponível em [github/terraform-aws-modules](https://github.com/terraform-aws-modules) e, visando aprimorar os conhecimentos em modularização de recursos em Terraform, este repositório tem como objetivo consolidar diferentes módulos Terraform criados para atender as mais variadas necessidades práticas encontradas em experiências reais vividas nos mundos de Engenharia de Dados, Analytics e Plataforma.

> 🚀 Sempre que um novo recurso precisar ser explorado a níveis de projetos pessoais ou corporativos, eventualmente a dinâmica prática de sua implementação será transformada em um novo módulo neste repositório.

## Documentações dos Módulos

📚 O repositório foi pré configurado para lançar novas *releases* dos módulos construídos de forma automática através da *action* [terraform-module-releaser](https://github.com/techpivot/terraform-module-releaser). Para verificar as versões e todos os detalhes de documentação disponíveis, acesse a [wiki do repositório](https://github.com/ThiagoPanini/tf-modules-showcase/wiki).

## Entre em Contato

- GitHub: [@ThiagoPanini](https://github.com/ThiagoPanini)
- LinkedIn: [Thiago Panini](https://www.linkedin.com/in/thiago-panini/)
- Hashnode: [panini-tech-lab](https://panini.hashnode.dev/)
- DevTo: [thiagopanini](https://dev.to/thiagopanini)