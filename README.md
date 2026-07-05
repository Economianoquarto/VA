# Participacao Setorial no Valor Adicionado

Painel interativo em Quarto + Shiny para visualizar a participacao da agropecuaria, da industria e dos servicos no Valor Adicionado municipal em 2021.

O projeto usa dados do SIDRA/IBGE e a malha municipal do pacote `geobr` para construir mapas interativos por unidade da federacao.

## Arquivos principais

- `01_preparar_dados.R`: coleta os dados, calcula as participacoes setoriais e gera o arquivo `my_workspace.RData`.
- `VA.qmd`: documento Quarto com o painel interativo.
- `VA.Rproj`: projeto R.

## Como executar

Instale os pacotes necessarios:

```r
install.packages(c(
  "sidrar",
  "dplyr",
  "geobr",
  "sf",
  "shiny",
  "scales",
  "leaflet",
  "htmltools"
))
```

Prepare os dados:

```r
source("01_preparar_dados.R")
```

Renderize ou visualize o painel:

```r
quarto::quarto_preview("VA.qmd")
```

## Dados

Os dados de Valor Adicionado municipal sao obtidos da tabela 5938 do SIDRA/IBGE, para o ano de 2021.

As participacoes sao calculadas como:

- Agropecuaria: Valor Adicionado da agropecuaria dividido pelo Valor Adicionado total.
- Industria: Valor Adicionado da industria dividido pelo Valor Adicionado total.
- Servicos: soma dos componentes de servicos dividida pelo Valor Adicionado total.

## Publicacao

O arquivo `my_workspace.RData` deve ser gerado localmente antes do deploy, pois o painel carrega esse arquivo para evitar baixar dados do SIDRA e do `geobr` durante a inicializacao no servidor.
