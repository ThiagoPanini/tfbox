<div align="center">
    <br><img src="https://github.com/ThiagoPanini/tf-modules-showcase/blob/main/docs/logo.png?raw=true" width=200 alt="tf-modules-showcase-logo">
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


## Overview

The **Terraform Modules Showcase** initiative aims to consolidate a series of Terraform modules created based on real needs for deploying resources in *cloud providers*.

In studies or practical work situations involving cloud computing, services need to be created in *workspaces* to meet specific application requirements. In many cases, the implementation dynamics of some of these services do not necessarily involve the pure and individual definition of Terraform resources.

To illustrate with other words, the proper implementation of a [Glue job](https://docs.aws.amazon.com/glue/latest/dg/what-is-glue.html) on AWS can hardly be achieved only through the declaration of the Terraform resource [aws_glue_job](https://registry.terraform.io/providers/hashicorp/aws/2.70.1/docs/resources/glue_job), but also requires other additional resources, such as [aws_glue_security_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_security_configuration) for job security configurations or even [aws_s3_bucket_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) for uploading *assets* used in ETL.

Inspired by the compilation of Terraform modules available at [github/terraform-aws-modules](https://github.com/terraform-aws-modules) and aiming to improve knowledge in Terraform resource modularization, this repository aims to consolidate different Terraform modules created to meet the most varied practical needs found in real experiences in the worlds of Data Engineering, Analytics and Platform.

> 🚀 Whenever a new resource needs to be explored at personal or corporate project levels, eventually the practical dynamics of its implementation will be transformed into a new module in this repository.

## Module Documentation

📚 The repository was pre-configured to launch new *releases* of the built modules automatically through the *action* [terraform-module-releaser](https://github.com/techpivot/terraform-module-releaser).

To check versions and all available documentation details, access the [repository wiki](https://github.com/ThiagoPanini/tf-modules-showcase/wiki).

## Get in Touch

- GitHub: [@ThiagoPanini](https://github.com/ThiagoPanini)
- LinkedIn: [Thiago Panini](https://www.linkedin.com/in/thiago-panini/)
- Hashnode: [panini-tech-lab](https://panini.hashnode.dev/)
- DevTo: [thiagopanini](https://dev.to/thiagopanini)