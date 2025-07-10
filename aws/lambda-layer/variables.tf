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

  validation {
    condition     = var.flag_create_from_dir || var.flag_create_from_input
    error_message = "Pelo menos um dos valores das variáveis var.flag_create_from_dir ou var.flag_create_from_input precisa ser verdadeiro. O usuário precisa escolher se deseja criar layer(s) através de arquivos .zip salvos em um diretório específico (var.flag_create_from_dir = true) ou se deseja criar layer(s) passando uma lista de maps de parâmetros com os detalhes do(s) layer(s) a ser(em) criado(s) diretamente para a chamada do módulo (var.flag_create_from_input = true)."
  }
}

variable "flag_create_from_input" {
  description = "Flag para indicar se o(s) layer(s) será(ão) criado(s) através de um map (dicionário) passado pelo usuário contendo todas as informações do(s) layer(s)."
  type        = bool
  default     = false
}

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
    condition     = var.flag_create_from_input || (var.flag_create_from_dir && var.layers_source_code_dir != "")
    error_message = "Quando var.flag_create_from_dir é igual a true e var.flag_create_from_input for igual a false, a variável var.layers_source_code_dir precisa ser explicitamente definida pelo usuário com um caminho de diretório onde os arquivos .zip dos layers a serem criados estão armazenados."
  }
}

variable "layers_input_params" {
  description = "Lista de map(s) (dicionário) contendo as informações necessárias para criação dos layers. Este dicionário pode conter todo os parâmetros aceitos pelo resource aws_lambda_layer_version (verificar documentação). O conteúdo desta variável é interpretado pelo módulo e utilizado como base para parametrização do resource aws_lambda_layer_version."
  type        = list(map(string))
  default     = []

  validation {
    condition     = (var.flag_create_from_input && var.layers_input_params != [])
    error_message = "Quando var.flag_create_from_input é igual a true, a variável var.layers_input_params precisa ser explicitamente definida pelo usuário com uma lista de maps contendo as informações do(s) layer(s) a ser(em) criado(s). ${var.flag_create_from_input && var.layers_input_params == []}"
  }
}


output "condition" {
  value = (var.flag_create_from_input && var.layers_input_params != [])
}
