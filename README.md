<div align="center">
    <br><img src="https://github.com/ThiagoPanini/tf-modules-showcase/blob/feature/lambda-layer-module/docs/logo-tfbox.png?raw=true" width=200 alt="tf-modules-showcase-logo">
</div>

<div align="center">

  <a href="https://www.terraform.io/">
    <img src="https://img.shields.io/badge/terraform-grey?style=for-the-badge&logo=terraform&logoColor=FFFFFF">
  </a>

  <a href="https://www.hashicorp.com/">
    <img src="https://img.shields.io/badge/hashicorp-grey?style=for-the-badge&logo=hashicorp&logoColor=FFFFFF">
  </a>

  <a href="https://github.com/">
    <img src="https://img.shields.io/badge/github-grey?style=for-the-badge&logo=github&logoColor=FFFFFF">
  </a>

  <a href="https://github.com/copilot">
    <img src="https://img.shields.io/badge/copilot-grey?style=for-the-badge&logo=githubcopilot&logoColor=FFFFFF">
  </a>
</div>

# tfbox: Terraform AWS Modules Collection

**tfbox** is a curated collection of reusable [Terraform](https://www.terraform.io/) modules for AWS infrastructure, designed to simplify and standardize cloud resource provisioning. Each module is self-contained, documented, and ready to integrate into your Terraform workflows.

## Modules Included

- **DynamoDB Table**  
  Flexible provisioning of DynamoDB tables with configurable keys, attributes, and billing modes.

- **IAM Role**  
  Automated creation of IAM roles, trust policies, and attachment of inline or existing policies using template-driven workflows.

- **Lambda Layer**  
  Build and deploy AWS Lambda layers from Python requirements, with automated packaging and cleanup.


>[!IMPORTANT]
> All relevant information about every module in this repository, including input variables, outputs, usage examples, and documentation, is available on the repository's [Wiki](https://github.com/ThiagoPanini/tfbox/wiki) page. 

## Repository Structure

```
aws/
  dynamodb-table/
  iam-role/
  lambda-layer/
```

Each subdirectory contains a standalone Terraform module with its own variables, resources, and documentation.

## Usage

To use a module, reference it in your Terraform configuration using the GitHub repository URL and the desired version tag:

```hcl
module "dynamodb_table" {
  source  = "git::https://github.com/ThiagoPanini/tfbox.git//aws/dynamodb-table?ref=v1.0.0"
  # ...module variables...
}
```

Replace `v1.0.0` with the desired module version.

## Automated Module Versioning

This repository uses the [terraform-module-releaser](https://github.com/marketplace/actions/terraform-module-releaser) GitHub Action to automatically release and version Terraform modules. When changes are merged, new module versions are published and all relevant documentation is updated on the [Wiki](https://github.com/ThiagoPanini/tfbox/wiki) page.

## Contributing

Contributions are welcome! Please open issues or pull requests to suggest improvements, new modules, or bug fixes.

## Get In Touch

- GitHub: [@ThiagoPanini](https://github.com/ThiagoPanini)
- LinkedIn: [Thiago Panini](https://www.linkedin.com/in/thiago-panini/)
- Hashnode: [panini-tech-lab](https://panini.hashnode.dev/)
- DevTo: [thiagopanini](https://dev.to/thiagopanini)

---

<div align="center">
  <sub>Built with ❤️ using Terraform and GitHub Actions</sub>
</div>