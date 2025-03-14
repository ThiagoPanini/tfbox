/* --------------------------------------------------------
ARQUIVO: locals.tf @ aws/lambda-layer module

Arquivo responsável por declarar variáveis/valores locais
capazes de auxiliar na obtenção de informações dinâmicas
utilizadas durante a implantação do projeto, como por
exemplo, o ID da conta alvo de implantação ou o nome da
região.
-------------------------------------------------------- */

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

  # Obtendo apenas o nome dos arquivos .zip (referência para nomear os layers)
  layers_names = [
    for file in local.zip_files_in_layers_path : trimsuffix(basename(file), ".zip")
  ]

  # Obtendo caminho completo dos arquivos de código fonte dos layers
  layers_source_code_paths = [
    for file in local.zip_files_in_layers_path : "${var.layers_source_code_dir}/${file}"
  ]

  # Montando estrutura com todas as informações dos layers
  layers_info = {
    for path, name in zipmap(local.layers_source_code_paths, local.layers_names) :
    path => {
      layer_name               = name
      filename                 = path
      description              = "Layer ${name} criado para aprimorar o gerenciamento e o reuso de códigos entre funções Lambda"
      compatible_architectures = var.compatible_architectures
      compatible_runtimes      = var.compatible_runtimes
      license_info             = var.license_info
    }
  }

}

output "layers_info" {
  value = local.layers_info
}

