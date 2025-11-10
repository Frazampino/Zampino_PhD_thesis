library(digest)
options(scipen=999)

# Funzione per anonimizzazione
anonymize <- function(x, algo="crc32") {
  sapply(x, function(y) if(y == "" | is.na(y)) "" else digest(y, algo = algo))
}

setwd("C:/Users/zampino/Documents/Process mining/INAIL/Ciclo passivo")

# Rinomina dei dataset secondo logica P2P
richieste_acquisto <- read.csv("v_rda.csv", stringsAsFactors = FALSE)
contratti_acquisto <- read.csv("v_contratti.csv", stringsAsFactors = FALSE)
fatture_confrontate <- read.csv("v_fatture_confrontate.csv", stringsAsFactors = FALSE)
fatture <- read.csv("v_fatture_registrate.csv", stringsAsFactors = FALSE)
ordini_acquisto <- read.csv("v_oda.csv", stringsAsFactors = FALSE)
pagamenti <- read.csv("v_pagamenti.csv", stringsAsFactors = FALSE)
preventivi <- read.csv("v_preventivi.csv", stringsAsFactors = FALSE)
ricezioni_materiali <- read.csv("v_ricezioni.csv", stringsAsFactors = FALSE)
rilasci_ordini <- read.csv("v_rilasci.csv", stringsAsFactors = FALSE)
richieste_preventivo <- read.csv("v_rp.csv", stringsAsFactors = FALSE)
lista_articoli <- read.csv("List.csv", stringsAsFactors = FALSE)

# Funzione per creare log uniforme in stile P2P
create_event_log <- function(df, case_col, resource_col=NULL, date_col, activity_col, tipo_col=NULL, prefix=NULL){
  df <- df[!is.na(df[[case_col]]), ]
  data.frame(
    CASE_ID = as.character(df[[case_col]]),
    RESOURCE = if(!is.null(resource_col)) df[[resource_col]] else NA,
    END_DATE = as.POSIXct(df[[date_col]], format="%Y-%m-%d %H:%M:%S"),
    ACTIVITY = if(!is.null(prefix)) paste(prefix, df[[activity_col]]) else df[[activity_col]],
    TIPO = if(!is.null(tipo_col)) df[[tipo_col]] else NA,
    stringsAsFactors = FALSE
  )
}

# Esempio: creare un log dalle richieste di acquisto
log_richieste <- create_event_log(richieste_acquisto, 
                                  case_col="numero", 
                                  resource_col="responsabile", 
                                  date_col="data_creazione", 
                                  activity_col="stato", 
                                  tipo_col="tipo_richiesta", 
                                  prefix="Richiesta Acquisto")

# Salvataggio CSV finale P2P
write.csv(log_richieste, "Procure-to-Pay asis", row.names = FALSE)
