/* --------------------------------------------------------
ARQUIVO: locals.tf @ aws/iam-role module

Arquivo responsável por declarar variáveis/valores locais
capazes de auxiliar na obtenção de informações dinâmicas
utilizadas durante a implantação do projeto, como por
exemplo, o ID da conta alvo de implantação ou o nome da
região.
-------------------------------------------------------- */

locals {
  # Definindo diretório de saída dos templates de policies
  rendered_templates_dir             = "${var.policy_templates_source_dir}/../${basename(var.policy_templates_source_dir)}_rendered"
  policies_templates_destination_dir = var.policy_templates_destination_dir == "" ? local.rendered_templates_dir : var.policy_templates_destination_dir

  # Obtendo lista de todos os templates resultantes filtrando apenas extensões permitidas
  templates_filenames = [
    for file in fileset(var.policy_templates_source_dir, "**") :
    file if lower(element(split(".", file), -1)) == "json" || lower(element(split(".", file), -1)) == "tpl"
  ]

  # Contruindo path de todos os templates obtidos para criação das roles
  templates_filepaths = {
    for tpl in local.templates_filenames :
    split(".", tpl)[0] => "${local.policies_templates_destination_dir}/${tpl}"
  }
}
