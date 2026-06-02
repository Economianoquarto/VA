# 01_preparar_dados.R
#
# Objetivo:
# Este script prepara a base usada pelo documento Quarto + Shiny.
# Ele deve ser executado localmente antes do deploy.
#
# Saída principal:
# - my_workspace_light.RData, contendo apenas os objetos br_map e lista_estados.
#
# Observação:
# O arquivo .qmd de deploy não deve baixar dados do SIDRA nem baixar a malha
# municipal do geobr durante a inicialização. Isso evita timeout no servidor.

# -----------------------------------------------------------------------------
# 1. Pacotes
# -----------------------------------------------------------------------------

library(sidrar)
library(dplyr)
library(geobr)
library(sf)

# -----------------------------------------------------------------------------
# 2. Função auxiliar
# -----------------------------------------------------------------------------

# Em alguns ambientes, a coluna de código municipal pode chegar como lista.
# Esta função força uma conversão segura para número.
converter_codigo_municipio <- function(x) {
  as.numeric(as.character(unlist(x)))
}

# -----------------------------------------------------------------------------
# 3. Coleta dos dados do SIDRA
# -----------------------------------------------------------------------------

va <- get_sidra(x = 5938, variable = 498, period = "2021", geo = "City") |>
  select(Município, `Município (Código)`, Valor) |>
  rename(
    va = Valor,
    code_muni = `Município (Código)`,
    MUN = Município
  ) |>
  mutate(code_muni = converter_codigo_municipio(code_muni))

agro <- get_sidra(x = 5938, variable = 513, period = "2021", geo = "City") |>
  select(Município, `Município (Código)`, Valor) |>
  rename(
    va_agro = Valor,
    code_muni = `Município (Código)`,
    MUN = Município
  ) |>
  mutate(code_muni = converter_codigo_municipio(code_muni))

ind <- get_sidra(x = 5938, variable = 517, period = "2021", geo = "City") |>
  select(Município, `Município (Código)`, Valor) |>
  rename(
    va_ind = Valor,
    code_muni = `Município (Código)`,
    MUN = Município
  ) |>
  mutate(code_muni = converter_codigo_municipio(code_muni))

serv1 <- get_sidra(x = 5938, variable = 6575, period = "2021", geo = "City") |>
  select(Município, `Município (Código)`, Valor) |>
  rename(
    va_serv1 = Valor,
    code_muni = `Município (Código)`,
    MUN = Município
  ) |>
  mutate(code_muni = converter_codigo_municipio(code_muni))

serv2 <- get_sidra(x = 5938, variable = 525, period = "2021", geo = "City") |>
  select(Município, `Município (Código)`, Valor) |>
  rename(
    va_serv2 = Valor,
    code_muni = `Município (Código)`,
    MUN = Município
  ) |>
  mutate(code_muni = converter_codigo_municipio(code_muni))

# -----------------------------------------------------------------------------
# 4. Cálculo das participações setoriais
# -----------------------------------------------------------------------------

serv <- inner_join(serv1, serv2, by = c("code_muni", "MUN")) |>
  mutate(va_serv = va_serv1 + va_serv2) |>
  select(code_muni, MUN, va_serv)

participacao <- va |>
  inner_join(agro, by = c("code_muni", "MUN")) |>
  inner_join(ind,  by = c("code_muni", "MUN")) |>
  inner_join(serv, by = c("code_muni", "MUN")) |>
  mutate(
    part_agro = va_agro / va,
    part_ind  = va_ind  / va,
    part_serv = va_serv / va
  ) |>
  select(code_muni, MUN, part_agro, part_ind, part_serv)

# -----------------------------------------------------------------------------
# 5. Malha municipal e união com os dados setoriais
# -----------------------------------------------------------------------------

br_muni <- read_municipality(code_muni = "all", year = 2020)

br_map <- br_muni |>
  left_join(participacao, by = "code_muni")

# Mantém somente as colunas necessárias para o aplicativo.
# Isso reduz o tamanho do arquivo e melhora a inicialização no deploy.
br_map <- br_map |>
  select(
    code_muni,
    name_muni,
    abbrev_state,
    name_state,
    part_agro,
    part_ind,
    part_serv,
    geom
  )

lista_estados <- sort(na.omit(unique(br_map$abbrev_state)))

# -----------------------------------------------------------------------------
# 6. Salvamento do arquivo leve para deploy
# -----------------------------------------------------------------------------

save(
  br_map,
  lista_estados,
  file = "my_workspace.RData",
  compress = "xz"
)
