/* --------------------------------------------------------
ARQUIVO: variables.tf @ aws/lambda-layer module

Variáveis utilizadas no módulo aws/lambda-layer para
definição, criação e configuração de layers (e versões) de
layers a serem utilizados em funções Lambda na AWS
-------------------------------------------------------- */

variable "flag_create_from_dir" {
  description = "Flag para indicar se o(s) layer(s) será(ão) criado(s) através de arquivo(s) .zip disponibilizado(s) em um path específico passado pelo usuário."
  type        = bool
  default     = true
}

/*
variable "flag_create_from_map" {
  description = "Flag para indicar se o(s) layer(s) será(ão) criado(s) através de um map (dicionário) passado pelo usuário contendo todas as informações do(s) layer(s)."
  type        = bool
  default     = false
}
*/

variable "compatible_architectures" {
  description = "Lista contendo todas as arquitetras compatíveis para a versão do layer Lambda a ser criada."
  type        = list(string)
  default     = ["arm64", "x86_64"]
}

variable "compatible_runtimes" {
  description = "Lista contendo todos os runtimes compatíveis para a versão do layer a ser criada"
  type        = list(string)
}

variable "license_info" {
  description = "Informações relacionadas a licença de software relacionada ao layer. Pode ser no formado de identificador SPDX (ex: MIT), uma URL que hospeda a licença (ex: https://opensource.org/licenses/MIT) ou então o texto completo da licença."
  type        = string
  default     = null
}

variable "layers_source_code_dir" {
  description = "Diretório contendo todos os arquivos .zip a serem utilizados para a criação dos layers."
  type        = string
  default     = ""

  validation {
    condition     = !var.flag_create_from_dir || var.flag_create_from_dir && var.layers_source_code_dir != ""
    error_message = "Quando var.flag_create_from_dir é igual a true, a variável var.layers_source_code_dir precisa ser explicitamente definida pelo usuário com um caminho de diretório onde os arquivos .zip dos layers a serem criados estão armazenados."
  }
}


/*
variable "layer_name" {
  description = "Nome do layer Lambda."
  type        = string
}

variable "layer_description" {
  description = "Descrição do layer Lambda."
  type        = string
  default     = null
}







variable "layer_zip_filepath" {
  description = "Caminho do arquivo .zip utilizado como fonte de contéudo para o layer Lambda."
  type        = string
}

variable "layer_s3_bucket" {
  description = "Nome do bucket S3 onde o código fonte do layer (arquivo .zip) está hospedado. Esta variável conflita com var.layer_zip_filepath, visto que o arquivo .zip pode existir em dois locais mutualmente exclusivos: ou no ambiente local da chamada deste módulo (utilizar var.layer_zip_filepath) ou então como um objeto no S3 (utilizar var.layer_s3_bucket + var.layer_s3_key + opcionalmente var.s3_object_version)"
  type        = string
  default     = null
}

variable "layer_s3_object_key" {
  description = "Referência de chave do objeto no S3 que representa o código fonte do layer (arquivo .zip). Esta variável conflita com var.layer_zip_filepath, visto que o arquivo .zip pode existir em dois locais mutualmente exclusivos: ou no ambiente local da chamada deste módulo (utilizar var.layer_zip_filepath) ou então como um objeto no S3 (utilizar var.layer_s3_bucket + var.layer_s3_key + opcionalmente var.s3_object_version)"
  type        = string
  default     = null
}

variable "layer_s3_object_version" {
  description = "Referência de versão do objeto no S3 que representa o código fonte do layer (arquivo .zip). Esta variável conflita com var.layer_zip_filepath, visto que o arquivo .zip pode existir em dois locais mutualmente exclusivos: ou no ambiente local da chamada deste módulo (utilizar var.layer_zip_filepath) ou então como um objeto no S3 (utilizar var.layer_s3_bucket + var.layer_s3_key + opcionalmente var.s3_object_version)"
  type        = string
  default     = null
}

variable "layer_source_code_hash" {
  description = "Atributo virtual utilizado para gerenciar a substituição do recurso (layer) conforme mudanças no código fonte."
  type        = string
  default     = null
}

variable "layers_info" {
  description = "string"
  type        = map(any)
}
*/
