/* --------------------------------------------------------
FILE: locals.tf @ aws/lambda-layer module

File responsible for declaring local variables/values
capable of assisting in obtaining dynamic information
used during project deployment, such as the target 
deployment account ID or region name.
-------------------------------------------------------- */

/*
locals {

  # Obtendo todos os arquivos no diretório fornecido para os layers
  all_files_in_layers_path = [
    for file in fileset(var.layers_source_code_dir, "**") : file
  ]

  # Filtrando apenas arquivos .zip
  zip_files_in_layers_path = [
    for file in local.all_files_in_layers_path : file
    if can(regex(".+\\.zip$", file))
  ]

  # Montando estrutura contendo informações do nome do layer e do path do zip extraídos do diretório
  layers_input_params_from_dir = [
    for file in local.zip_files_in_layers_path :
    {
      layer_name = trimsuffix(basename(file), ".zip")
      filename   = "${var.layers_source_code_dir}/${file}"
    }
  ]

  # Obtendo apenas o nome dos arquivos .zip (referência para nomear os layers)
  layers_names = [
    for file in local.zip_files_in_layers_path : trimsuffix(basename(file), ".zip")
  ]

  # Obtendo caminho completo dos arquivos de código fonte dos layers
  layers_source_code_paths = [
    for file in local.zip_files_in_layers_path : "${var.layers_source_code_dir}/${file}"
  ]

  # Gerando estrutura aninhada para

  # Montando estrutura com todas as informações dos layers
  layers_info_from_dir = {
    for path, name in zipmap(local.layers_source_code_paths, local.layers_names) :
    "layer-${name}@${path}" => {
      layer_name               = name
      filename                 = path
      description              = "Layer ${name} criado para aprimorar o gerenciamento e o reuso de códigos entre funções Lambda"
      compatible_architectures = var.compatible_architectures
      compatible_runtimes      = var.compatible_runtimes
      license_info             = var.license_info
    }
  }



  # Montando estrutura com todas as informações dos layers
  layers_info_from_details = {
    for info in var.layers_input_params :
    "layer-${info.layer_name}@${info.filename}" => {
      layer_name               = info.layer_name
      filename                 = info.filename
      description              = contains(keys(info), "description") ? info.description : "Layer ${info.layer_name} criado para aprimorar o gerenciamento e o reuso de códigos entre funções Lambda."
      compatible_architectures = contains(keys(info), "compatible_architectures") ? info.compatible_architectures : var.compatible_architectures
      compatible_runtimes      = contains(keys(info), "compatible_runtimes") ? info.compatible_runtimes : var.compatible_runtimes
      license_info             = contains(keys(info), "license_info") ? info.license_info : var.license_info
    }
  }

  # Criando estrutura única para criação de layers com base em modo selecionado pelo usuário (dir ou details)
  layers_info_details = var.flag_create_from_input ? var.layers_input_params : local.layers_input_params_from_dir

  layers_info = {
    for info in local.layers_info_details :
    "layer-${info.layer_name}@${info.filename}" => {
      layer_name               = info.layer_name
      filename                 = info.filename
      description              = contains(keys(info), "description") ? info.description : "Layer ${info.layer_name} criado para aprimorar o gerenciamento e o reuso de códigos entre funções Lambda."
      compatible_architectures = contains(keys(info), "compatible_architectures") ? info.compatible_architectures : var.compatible_architectures
      compatible_runtimes      = contains(keys(info), "compatible_runtimes") ? info.compatible_runtimes : var.compatible_runtimes
      license_info             = contains(keys(info), "license_info") ? info.license_info : var.license_info
    }
  }

}


output "zipmap_teste" {
  value = zipmap(local.layers_source_code_paths, local.layers_names)
}

output "layers_input_params" {
  value = var.layers_input_params
}

output "layers_input_params_from_dir" {
  value = local.layers_input_params_from_dir
}

output "layers_info" {
  value = local.layers_info
}
*/

locals {
  # Analyzing condition to search for .zip files in target directory for layer creation
  create_from_dir_condition = var.flag_create_from_dir && !var.flag_create_from_input && var.layers_source_code_dir != ""

  # Obtaining all files in the directory provided for layers
  all_files_in_layers_path = local.create_from_dir_condition ? [
    for file in fileset(var.layers_source_code_dir, "**") : file
  ] : []

  # Filtering only .zip files
  zip_files_in_layers_path = local.create_from_dir_condition ? [
    for file in local.all_files_in_layers_path : file
    if can(regex(".+\\.zip$", file))
  ] : []

  # Building structure containing layer name and zip path information extracted from directory
  layers_input_params_from_dir = local.create_from_dir_condition ? [
    for file in local.zip_files_in_layers_path :
    {
      layer_name = trimsuffix(basename(file), ".zip")
      filename   = "${var.layers_source_code_dir}/${file}"
    }
  ] : []

  # Validating which object containing layer details will be used for building the creation map
  layers_info_details = var.flag_create_from_input ? var.layers_input_params : local.layers_input_params_from_dir

  # Building unique structure containing all details of layers to be created
  layers_info = {
    for info in local.layers_info_details :
    "layer-${info.layer_name}@${info.filename}" => {
      layer_name               = info.layer_name
      filename                 = info.filename
      description              = contains(keys(info), "description") ? info.description : "Layer ${info.layer_name} created to enhance management and code reuse between Lambda functions."
      compatible_architectures = contains(keys(info), "compatible_architectures") ? info.compatible_architectures : var.compatible_architectures
      compatible_runtimes      = contains(keys(info), "compatible_runtimes") ? info.compatible_runtimes : var.compatible_runtimes
      license_info             = contains(keys(info), "license_info") ? info.license_info : var.license_info
    }
  }

}

