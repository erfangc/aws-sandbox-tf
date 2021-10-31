variable "target_account" {
  type = number
}

variable "table" {
  type = object({name: string, stream_arn: string})
}