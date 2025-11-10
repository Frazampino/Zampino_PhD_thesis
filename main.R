library(tidyverse)
options(scipen=999)

anonymize <- function(x, algo="crc32") {
  sapply(x, function(y) if(y == "" | is.na(y)) "" else digest(y, algo = algo))
}

setwd("C:/Users/zampino/Documents/Process mining/INAIL/Ciclo passivo")
file="v_rda.csv"
file3="v_contratti.csv"
file4="v_fatture_confrontate.csv"
file5="v_fatture_registrate.csv"
file6="v_oda.csv"
file7="v_pagamenti.csv"
file8="v_preventivi.csv"
file9="v_ricezioni.csv"
file10="v_rilasci.csv"
file11="v_rp.csv"
file12="List.csv"

df_rda <- read.csv(file, header = TRUE, sep = ",", stringsAsFactors = FALSE, row.names=NULL, na.strings=c("NA","NaN", " ","NULL"), colClasses=c("numero"="character"))
df_contratti <- read.csv(file3, header = TRUE, sep = ",", stringsAsFactors = FALSE, row.names=NULL, na.strings=c("NA","NaN", " ","NULL"), colClasses=c("determina_spesa"="character"))
df_oda <- read.csv(file6, header = TRUE, sep = ",", stringsAsFactors = FALSE, row.names=NULL, na.strings=c("NA","NaN", " ","NULL"), colClasses=c("numero_padre"="character"))


df_fatture_registrate <- read.csv(file5, header = TRUE, sep = ",", stringsAsFactors = FALSE, row.names=NULL, na.strings=c("NA","NaN", " ","NULL"), colClasses=c("numero"="character"))
df_fatture_confrontate <- read.csv(file4, header = TRUE, sep = ",", stringsAsFactors = FALSE, row.names=NULL, na.strings=c("NA","NaN", " ","NULL"))
df_pagamenti <- read.csv(file7, header = TRUE, sep = ",", stringsAsFactors = FALSE, row.names=NULL, na.strings=c("NA","NaN", " ","NULL"), colClasses=c("numero"="character"))
df_preventivi<- read.csv(file8, header = TRUE, sep = ",", stringsAsFactors = FALSE, row.names=NULL, na.strings=c("NA","NaN", " ","NULL"), colClasses=c("determina_spesa"="character"))
df_ricezioni <- read.csv(file9, header = TRUE, sep = ",", stringsAsFactors = FALSE, row.names=NULL, na.strings=c("NA","NaN", " ","NULL"), colClasses=c("determina_spesa"="character"))
df_rilasci <- read.csv(file10, header = TRUE, sep = ",", stringsAsFactors = FALSE, row.names=NULL, na.strings=c("NA","NaN", " ","NULL"), colClasses=c("determina_spesa"="character"))
df_rp <- read.csv(file11, header = TRUE, sep = ",", stringsAsFactors = FALSE, row.names=NULL, na.strings=c("NA","NaN", " ","NULL"), colClasses=c("identificativo_padre"="character"))
df_list <- read.csv(file12, header = TRUE, sep = ",", stringsAsFactors = FALSE,row.names=NULL, na.strings=c("NA","NaN", " ","NULL"), colClasses=c("ID"="character"))

names(df_rda) <- toupper(names(df_rda))
names(df_contratti) <- toupper(names(df_contratti))
names(df_fatture_confrontate) <- toupper(names(df_fatture_confrontate))
names(df_fatture_registrate) <- toupper(names(df_fatture_registrate))
names(df_oda) <- toupper(names(df_oda))
names(df_pagamenti) <- toupper(names(df_pagamenti))
names(df_preventivi) <- toupper(names(df_preventivi))
names(df_ricezioni) <- toupper(names(df_ricezioni))
names(df_rilasci) <- toupper(names(df_rilasci))
names(df_rp) <- toupper(names(df_rp))
names(df_list) <- toupper(names(df_list))

###CAPIRE I FILTRI PER CONTRATTI E PREVENTIVI CREAZIONE

df_RDA_CREAZIONE <- unique(df_rda[, c("NUMERO","PREPARATORE","DATA_CREAZIONE","TIPO")])
df_RDA_CREAZIONE["ACTIVITY"] <- "RDA CREAZIONE"
names(df_RDA_CREAZIONE) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_RDA_CREAZIONE$END_DATE <- as.POSIXct(df_RDA_CREAZIONE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_RDA_CREAZIONE$CASE_ID <- as.character(df_RDA_CREAZIONE$CASE_ID)
df_RDA_CREAZIONE <- df_RDA_CREAZIONE[!is.na(df_RDA_CREAZIONE$CASE_ID),]

#############RDA EVENTI SUCCESSIVI##################
df_RDA_EVENTI_SUCCESSIVI <- unique(df_rda[! is.na(df_rda$CRONOLOGIA_AZIONE), c("NUMERO","ESEGUITO_DA","DATA_ESECUZIONE","TIPO","CRONOLOGIA_AZIONE")])
names(df_RDA_EVENTI_SUCCESSIVI) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_RDA_EVENTI_SUCCESSIVI$ACTIVITY <- paste0("RDA ", df_RDA_EVENTI_SUCCESSIVI$ACTIVITY)
df_RDA_EVENTI_SUCCESSIVI$END_DATE <- as.POSIXct(df_RDA_EVENTI_SUCCESSIVI$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_RDA_EVENTI_SUCCESSIVI$CASE_ID <- as.character(df_RDA_EVENTI_SUCCESSIVI$CASE_ID)
df_RDA_EVENTI_SUCCESSIVI <- df_RDA_EVENTI_SUCCESSIVI[!is.na(df_RDA_EVENTI_SUCCESSIVI$CASE_ID),]

#############RDA STATO ATTUALE##################
df_RDA_STATO_ATTUALE <- unique(df_rda[, c("NUMERO","UTENTE_STATO_ATTUALE","DATA_STATO_ATTUALE","TIPO","STATO_ATTUALE")])
names(df_RDA_STATO_ATTUALE) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_RDA_STATO_ATTUALE$ACTIVITY <- paste0("RDA ", df_RDA_STATO_ATTUALE$ACTIVITY)
df_RDA_STATO_ATTUALE$END_DATE <- as.POSIXct(df_RDA_STATO_ATTUALE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_RDA_STATO_ATTUALE$CASE_ID <- as.character(df_RDA_STATO_ATTUALE$CASE_ID)
df_RDA_STATO_ATTUALE <- df_RDA_STATO_ATTUALE[!is.na(df_RDA_STATO_ATTUALE$CASE_ID),]

#############ODA CREAZIONE##################
df_oda_s4 <- df_oda[is.na(df_oda$TIPO_PADRE) & is.na(df_oda$DETERMINA_SPESA),] %>%  group_by(NUMERO) %>% filter(DATA_CREAZIONE == max(DATA_CREAZIONE))

df_oda_s4$NUMERO <- paste0("S4_",df_oda_s4$NUMERO)

df_oda_caseid <- unique(df_oda_s4[,c ("NUMERO")])
#############ODA CREAZIONE s4##################

df_ODA_CREAZIONE_s4 <- unique(df_oda_s4[, c("NUMERO","BUYER","DATA_CREAZIONE","TIPO")])
df_ODA_CREAZIONE_s4["ACTIVITY"] <- "ODA CREAZIONE"
names(df_ODA_CREAZIONE_s4) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_ODA_CREAZIONE_s4$END_DATE <- as.POSIXct(df_ODA_CREAZIONE_s4$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_ODA_CREAZIONE_s4$CASE_ID <- as.character(df_ODA_CREAZIONE_s4$CASE_ID)
df_ODA_CREAZIONE_s4 <- df_ODA_CREAZIONE_s4[!is.na(df_ODA_CREAZIONE_s4$CASE_ID),]

#############ODA EVENTI SUCCESSIVI s4##################
df_ODA_EVENTI_SUCCESSIVI_s4 <- unique(df_oda_s4[! is.na(df_oda_s4$CRONOLOGIA_AZIONE), c("NUMERO","ESEGUITO_DA","DATA_ESECUZIONE","TIPO","CRONOLOGIA_AZIONE")])
names(df_ODA_EVENTI_SUCCESSIVI_s4) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_ODA_EVENTI_SUCCESSIVI_s4$ACTIVITY <- paste0("ODA ", df_ODA_EVENTI_SUCCESSIVI_s4$ACTIVITY)
df_ODA_EVENTI_SUCCESSIVI_s4$END_DATE <- as.POSIXct(df_ODA_EVENTI_SUCCESSIVI_s4$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_ODA_EVENTI_SUCCESSIVI_s4$CASE_ID <- as.character(df_ODA_EVENTI_SUCCESSIVI_s4$CASE_ID)
df_ODA_EVENTI_SUCCESSIVI_s4 <- df_ODA_EVENTI_SUCCESSIVI_s4[!is.na(df_ODA_EVENTI_SUCCESSIVI_s4$CASE_ID),]

#############ODA ULTIMA APPROVAZIONE S4##################
df_ODA_DATA_ULTIMA_APPROVAZIONE_s4 <- unique(df_oda_s4[! is.na(df_oda_s4$DATA_ULTIMA_APPROVAZIONE), c("NUMERO","DATA_ULTIMA_APPROVAZIONE","TIPO")])
df_ODA_DATA_ULTIMA_APPROVAZIONE_s4["ACTIVITY"] <- "ODA ULTIMA APPROVAZIONE"
names(df_ODA_DATA_ULTIMA_APPROVAZIONE_s4) <- c("CASE_ID","END_DATE","TIPO","ACTIVITY")
df_ODA_DATA_ULTIMA_APPROVAZIONE_s4$END_DATE <- as.POSIXct(df_ODA_DATA_ULTIMA_APPROVAZIONE_s4$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_ODA_DATA_ULTIMA_APPROVAZIONE_s4$CASE_ID <- as.character(df_ODA_DATA_ULTIMA_APPROVAZIONE_s4$CASE_ID)
df_ODA_DATA_ULTIMA_APPROVAZIONE_s4 <- df_ODA_DATA_ULTIMA_APPROVAZIONE_s4[!is.na(df_ODA_DATA_ULTIMA_APPROVAZIONE_s4$CASE_ID),]

subset_df_oda_s4 <- subset(df_oda_s4, STATO_ATTUALE  ==  "Approvato, Impegnato"| STATO_ATTUALE == "Riapprovazione obbligatoria"| STATO_ATTUALE == "Approvato"| STATO_ATTUALE == "Incompleto"| STATO_ATTUALE == "In lavorazione"| STATO_ATTUALE == "Approvato, Chiuso, Impegnato")

#corretto subset, gli stati non ci sono tutti

#############ODA STATO ATTUALE S4##################
df_ODA_DATA_STATO_ATTUALE_s4 <- unique(subset_df_oda_s4[! is.na(subset_df_oda_s4$DATA_STATO_ATTUALE), c("NUMERO","DATA_STATO_ATTUALE","TIPO","STATO_ATTUALE")])
names(df_ODA_DATA_STATO_ATTUALE_s4) <- c("CASE_ID","END_DATE","TIPO","ACTIVITY")
df_ODA_DATA_STATO_ATTUALE_s4$END_DATE <- as.POSIXct(df_ODA_DATA_STATO_ATTUALE_s4$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_ODA_DATA_STATO_ATTUALE_s4$CASE_ID <- as.character(df_ODA_DATA_STATO_ATTUALE_s4$CASE_ID)
df_ODA_DATA_STATO_ATTUALE_s4$ACTIVITY <- paste0("ODA ", df_ODA_DATA_STATO_ATTUALE_s4$ACTIVITY)
df_ODA_DATA_STATO_ATTUALE_s4 <- df_ODA_DATA_STATO_ATTUALE_s4[!is.na(df_ODA_DATA_STATO_ATTUALE_s4$CASE_ID),]

#crea lista case_id_s4 unique case id df_oda_s4 e aggiungo s4 case id
#dopo tutti i blocchi aggiungi S4 a case e poi aggiungo tutti i blocchi oda s4

#df_oda <- df_oda %>%  group_by(NUMERO_PADRE) %>% filter(DATA_CREAZIONE == max(DATA_CREAZIONE))

df_oda_RDA <- df_oda %>%  group_by(NUMERO_PADRE) %>% filter(TIPO_PADRE == "RDA")

df_ODA_CREAZIONE <- unique(df_oda_RDA[, c("NUMERO_PADRE","BUYER","DATA_CREAZIONE","TIPO")])
df_ODA_CREAZIONE["ACTIVITY"] <- "ODA CREAZIONE"
names(df_ODA_CREAZIONE) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_ODA_CREAZIONE$END_DATE <- as.POSIXct(df_ODA_CREAZIONE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_ODA_CREAZIONE$CASE_ID <- as.character(df_ODA_CREAZIONE$CASE_ID)
df_ODA_CREAZIONE <- df_ODA_CREAZIONE[!is.na(df_ODA_CREAZIONE$CASE_ID),]



#############ODA EVENTI SUCCESSIVI##################
df_ODA_EVENTI_SUCCESSIVI <- unique(df_oda_RDA[! is.na(df_oda$CRONOLOGIA_AZIONE), c("NUMERO_PADRE","ESEGUITO_DA","DATA_ESECUZIONE","TIPO","CRONOLOGIA_AZIONE")])
names(df_ODA_EVENTI_SUCCESSIVI) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_ODA_EVENTI_SUCCESSIVI$ACTIVITY <- paste0("ODA ", df_ODA_EVENTI_SUCCESSIVI$ACTIVITY)
df_ODA_EVENTI_SUCCESSIVI$END_DATE <- as.POSIXct(df_ODA_EVENTI_SUCCESSIVI$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_ODA_EVENTI_SUCCESSIVI$CASE_ID <- as.character(df_ODA_EVENTI_SUCCESSIVI$CASE_ID)
df_ODA_EVENTI_SUCCESSIVI <- df_ODA_EVENTI_SUCCESSIVI[!is.na(df_ODA_EVENTI_SUCCESSIVI$CASE_ID),]

#############ODA ULTIMA APPROVAZIONE##################
df_ODA_DATA_ULTIMA_APPROVAZIONE <- unique(df_oda_RDA[! is.na(df_oda$DATA_ULTIMA_APPROVAZIONE), c("NUMERO_PADRE","DATA_ULTIMA_APPROVAZIONE","TIPO")])
df_ODA_DATA_ULTIMA_APPROVAZIONE["ACTIVITY"] <- "ODA ULTIMA APPROVAZIONE"
names(df_ODA_DATA_ULTIMA_APPROVAZIONE) <- c("CASE_ID","END_DATE","TIPO","ACTIVITY")
df_ODA_DATA_ULTIMA_APPROVAZIONE$END_DATE <- as.POSIXct(df_ODA_DATA_ULTIMA_APPROVAZIONE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_ODA_DATA_ULTIMA_APPROVAZIONE$CASE_ID <- as.character(df_ODA_DATA_ULTIMA_APPROVAZIONE$CASE_ID)
df_ODA_DATA_ULTIMA_APPROVAZIONE <- df_ODA_DATA_ULTIMA_APPROVAZIONE[!is.na(df_ODA_DATA_ULTIMA_APPROVAZIONE$CASE_ID),]

subset_df_oda <- subset(df_oda_RDA, STATO_ATTUALE  ==  "Approvato, Impegnato"| STATO_ATTUALE == "Riapprovazione obbligatoria"| STATO_ATTUALE == "Approvato"| STATO_ATTUALE == "Incompleto"| STATO_ATTUALE == "In lavorazione"| STATO_ATTUALE == "Approvato, Chiuso, Impegnato")

#corretto subset, gli stati non ci sono tutti

#############ODA STATO ATTUALE##################
df_ODA_DATA_STATO_ATTUALE <- unique(subset_df_oda[! is.na(subset_df_oda$DATA_STATO_ATTUALE), c("NUMERO_PADRE","DATA_STATO_ATTUALE","TIPO","STATO_ATTUALE")])
names(df_ODA_DATA_STATO_ATTUALE) <- c("CASE_ID","END_DATE","TIPO","ACTIVITY")
df_ODA_DATA_STATO_ATTUALE$END_DATE <- as.POSIXct(df_ODA_DATA_STATO_ATTUALE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_ODA_DATA_STATO_ATTUALE$CASE_ID <- as.character(df_ODA_DATA_STATO_ATTUALE$CASE_ID)
df_ODA_DATA_STATO_ATTUALE$ACTIVITY <- paste0("ODA ", df_ODA_DATA_STATO_ATTUALE$ACTIVITY)
df_ODA_DATA_STATO_ATTUALE <- df_ODA_DATA_STATO_ATTUALE[!is.na(df_ODA_DATA_STATO_ATTUALE$CASE_ID),]

df_oda_PRE_CO <- df_oda %>% filter(TIPO_PADRE == "PREVENTIVO" | TIPO_PADRE == "CONTRATTO")

df_ODA_CREAZIONE <- unique(df_oda_PRE_CO[, c("DETERMINA_SPESA","BUYER","DATA_CREAZIONE","TIPO")])
df_ODA_CREAZIONE["ACTIVITY"] <- "ODA CREAZIONE"
names(df_ODA_CREAZIONE) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_ODA_CREAZIONE$END_DATE <- as.POSIXct(df_ODA_CREAZIONE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_ODA_CREAZIONE$CASE_ID <- as.character(df_ODA_CREAZIONE$CASE_ID)
df_ODA_CREAZIONE <- df_ODA_CREAZIONE[!is.na(df_ODA_CREAZIONE$CASE_ID),]



#############ODA EVENTI SUCCESSIVI##################
df_ODA_EVENTI_SUCCESSIVI <- unique(df_oda_PRE_CO[! is.na(df_oda$CRONOLOGIA_AZIONE), c("DETERMINA_SPESA","ESEGUITO_DA","DATA_ESECUZIONE","TIPO","CRONOLOGIA_AZIONE")])
names(df_ODA_EVENTI_SUCCESSIVI) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_ODA_EVENTI_SUCCESSIVI$ACTIVITY <- paste0("ODA ", df_ODA_EVENTI_SUCCESSIVI$ACTIVITY)
df_ODA_EVENTI_SUCCESSIVI$END_DATE <- as.POSIXct(df_ODA_EVENTI_SUCCESSIVI$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_ODA_EVENTI_SUCCESSIVI$CASE_ID <- as.character(df_ODA_EVENTI_SUCCESSIVI$CASE_ID)
df_ODA_EVENTI_SUCCESSIVI <- df_ODA_EVENTI_SUCCESSIVI[!is.na(df_ODA_EVENTI_SUCCESSIVI$CASE_ID),]

#############ODA ULTIMA APPROVAZIONE##################
df_ODA_DATA_ULTIMA_APPROVAZIONE <- unique(df_oda_PRE_CO[! is.na(df_oda$DATA_ULTIMA_APPROVAZIONE), c("DETERMINA_SPESA","DATA_ULTIMA_APPROVAZIONE","TIPO")])
df_ODA_DATA_ULTIMA_APPROVAZIONE["ACTIVITY"] <- "ODA ULTIMA APPROVAZIONE"
names(df_ODA_DATA_ULTIMA_APPROVAZIONE) <- c("CASE_ID","END_DATE","TIPO","ACTIVITY")
df_ODA_DATA_ULTIMA_APPROVAZIONE$END_DATE <- as.POSIXct(df_ODA_DATA_ULTIMA_APPROVAZIONE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_ODA_DATA_ULTIMA_APPROVAZIONE$CASE_ID <- as.character(df_ODA_DATA_ULTIMA_APPROVAZIONE$CASE_ID)
df_ODA_DATA_ULTIMA_APPROVAZIONE <- df_ODA_DATA_ULTIMA_APPROVAZIONE[!is.na(df_ODA_DATA_ULTIMA_APPROVAZIONE$CASE_ID),]

subset_df_oda2 <- subset(df_oda_PRE_CO, STATO_ATTUALE  ==  "Approvato, Impegnato"| STATO_ATTUALE == "Riapprovazione obbligatoria"| STATO_ATTUALE == "Approvato"| STATO_ATTUALE == "Incompleto"| STATO_ATTUALE == "In lavorazione"| STATO_ATTUALE == "Approvato, Chiuso, Impegnato")

#corretto subset, gli stati non ci sono tutti

#############ODA STATO ATTUALE##################
df_ODA_DATA_STATO_ATTUALE <- unique(subset_df_oda2[! is.na(subset_df_oda$DATA_STATO_ATTUALE), c("DETERMINA_SPESA","DATA_STATO_ATTUALE","TIPO","STATO_ATTUALE")])
names(df_ODA_DATA_STATO_ATTUALE) <- c("CASE_ID","END_DATE","TIPO","ACTIVITY")
df_ODA_DATA_STATO_ATTUALE$END_DATE <- as.POSIXct(df_ODA_DATA_STATO_ATTUALE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_ODA_DATA_STATO_ATTUALE$CASE_ID <- as.character(df_ODA_DATA_STATO_ATTUALE$CASE_ID)
df_ODA_DATA_STATO_ATTUALE$ACTIVITY <- paste0("ODA ", df_ODA_DATA_STATO_ATTUALE$ACTIVITY)
df_ODA_DATA_STATO_ATTUALE <- df_ODA_DATA_STATO_ATTUALE[!is.na(df_ODA_DATA_STATO_ATTUALE$CASE_ID),]

#oda tipo padre oda qual è il case id? (forse non lo considera)

#############RP CREAZIONE##################
df_RP_CREAZIONE <- unique(df_rp[, c("IDENTIFICATIVO_PADRE","BUYER","DATA_CREAZIONE","TIPO")])
df_RP_CREAZIONE["ACTIVITY"] <- "RP CREAZIONE"
names(df_RP_CREAZIONE) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_RP_CREAZIONE$END_DATE <- as.POSIXct(df_RP_CREAZIONE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_RP_CREAZIONE <- df_RP_CREAZIONE[!is.na(df_RP_CREAZIONE$CASE_ID),]


#############RP EVENTI SUCCESSIVI##################
df_RP_EVENTI_SUCCESSIVI <- unique(df_rp[! is.na(df_rp$STATO), c("IDENTIFICATIVO_PADRE","BUYER","DATA_ULTIMA_MODIFICA","TIPO_PADRE","STATO")])
names(df_RP_EVENTI_SUCCESSIVI) <- c("CASE_ID","RESOURCE","END_DATE","TIPO_PADRE","ACTIVITY")
df_RP_EVENTI_SUCCESSIVI$ACTIVITY <- paste0("RP ", df_RP_EVENTI_SUCCESSIVI$ACTIVITY)
df_RP_EVENTI_SUCCESSIVI$END_DATE <- as.POSIXct(df_RP_EVENTI_SUCCESSIVI$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_RP_EVENTI_SUCCESSIVI <- df_RP_EVENTI_SUCCESSIVI[!is.na(df_RP_EVENTI_SUCCESSIVI$CASE_ID),]


#############PREVENTIVI CREAZIONE##################
df_PREVENTIVI_CREAZIONE <- unique(df_preventivi[, c("DETERMINA_SPESA","BUYER","DATA_CREAZIONE","TIPO")])
df_PREVENTIVI_CREAZIONE["ACTIVITY"] <- "PREVENTIVO CREAZIONE"
names(df_PREVENTIVI_CREAZIONE) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_PREVENTIVI_CREAZIONE$END_DATE <- as.POSIXct(df_PREVENTIVI_CREAZIONE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_PREVENTIVI_CREAZIONE <- df_PREVENTIVI_CREAZIONE[!is.na(df_PREVENTIVI_CREAZIONE$CASE_ID),]


#############PREVENTIVI EVENTI SUCCESSIVI##################
df_PREVENTIVI_EVENTI_SUCCESSIVI <- unique(df_preventivi[! is.na(df_preventivi$CRONOLOGIA_AZIONE), c("DETERMINA_SPESA","BUYER","DATA_ESECUZIONE","TIPO","CRONOLOGIA_AZIONE")])
names(df_PREVENTIVI_EVENTI_SUCCESSIVI) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_PREVENTIVI_EVENTI_SUCCESSIVI$ACTIVITY <- paste0("PREVENTIVO ", df_PREVENTIVI_EVENTI_SUCCESSIVI$ACTIVITY)
df_PREVENTIVI_EVENTI_SUCCESSIVI$END_DATE <- as.POSIXct(df_PREVENTIVI_EVENTI_SUCCESSIVI$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_PREVENTIVI_EVENTI_SUCCESSIVI <- df_PREVENTIVI_EVENTI_SUCCESSIVI[!is.na(df_PREVENTIVI_EVENTI_SUCCESSIVI$CASE_ID),]


subset_df_preventivi <- subset(df_preventivi, STATO  ==  "Attiva")


#############PREVENTIVI STATO ATTUALE##################
df_PREVENTIVI_STATO_ATTUALE <- unique(subset_df_preventivi[, c("DETERMINA_SPESA","BUYER","DATA_ULTIMA_MODIFICA","TIPO","STATO")])
names(df_PREVENTIVI_STATO_ATTUALE) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_PREVENTIVI_STATO_ATTUALE$ACTIVITY <- paste0("PREVENTIVO ", df_PREVENTIVI_STATO_ATTUALE$ACTIVITY)
df_PREVENTIVI_STATO_ATTUALE$END_DATE <- as.POSIXct(df_PREVENTIVI_STATO_ATTUALE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_PREVENTIVI_STATO_ATTUALE <- df_PREVENTIVI_STATO_ATTUALE[!is.na(df_PREVENTIVI_STATO_ATTUALE$CASE_ID),]


#############PREVENTIVI ASSEGNATO##################
df_PREVENTIVI_ASSEGNATO <- unique(df_preventivi[!is.na(df_preventivi$DETERMINA_SPESA), c("DETERMINA_SPESA","DATA_INDICAZIONE_VINCITORE","TIPO")])
df_PREVENTIVI_ASSEGNATO["ACTIVITY"] <- "PREVENTIVO ASSEGNATO"
names(df_PREVENTIVI_ASSEGNATO) <- c("CASE_ID","END_DATE","TIPO","ACTIVITY")
df_PREVENTIVI_ASSEGNATO$END_DATE <- as.POSIXct(df_PREVENTIVI_ASSEGNATO$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_PREVENTIVI_ASSEGNATO <- df_PREVENTIVI_ASSEGNATO[!is.na(df_PREVENTIVI_ASSEGNATO$END_DATE),]
df_PREVENTIVI_ASSEGNATO <- df_PREVENTIVI_ASSEGNATO[!is.na(df_PREVENTIVI_ASSEGNATO$CASE_ID),]


#############RILASCIO CREAZIONE##################
df_RILASCI_CREAZIONE <- unique(df_rilasci[, c("DETERMINA_SPESA","BUYER","DATA_CREAZIONE","TIPO")])
df_RILASCI_CREAZIONE["ACTIVITY"] <- "RILASCIO CREAZIONE"
names(df_RILASCI_CREAZIONE) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_RILASCI_CREAZIONE$END_DATE <- as.POSIXct(df_RILASCI_CREAZIONE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_RILASCI_CREAZIONE <- df_RILASCI_CREAZIONE[!is.na(df_RILASCI_CREAZIONE$END_DATE),]
df_RILASCI_CREAZIONE <- df_RILASCI_CREAZIONE[!is.na(df_RILASCI_CREAZIONE$CASE_ID),]


#############RILASCIO EVENTI SUCCESSIVI##################
df_RILASCI_EVENTI_SUCCESSIVI <- unique(df_rilasci[! is.na(df_rilasci$CRONOLOGIA_AZIONE), c("DETERMINA_SPESA","ESEGUITO_DA","DATA_ESECUZIONE","TIPO","CRONOLOGIA_AZIONE")])
names(df_RILASCI_EVENTI_SUCCESSIVI) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_RILASCI_EVENTI_SUCCESSIVI$ACTIVITY <- paste0("RILASCIO ", df_RILASCI_EVENTI_SUCCESSIVI$ACTIVITY)
df_RILASCI_EVENTI_SUCCESSIVI$END_DATE <- gsub("\\..*","",df_RILASCI_EVENTI_SUCCESSIVI$END_DATE)
df_RILASCI_EVENTI_SUCCESSIVI$END_DATE <- as.POSIXct(df_RILASCI_EVENTI_SUCCESSIVI$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_RILASCI_EVENTI_SUCCESSIVI <- df_RILASCI_EVENTI_SUCCESSIVI[!is.na(df_RILASCI_EVENTI_SUCCESSIVI$END_DATE),]
df_RILASCI_EVENTI_SUCCESSIVI <- df_RILASCI_EVENTI_SUCCESSIVI[!is.na(df_RILASCI_EVENTI_SUCCESSIVI$CASE_ID),]


#############RILASCI ULTIMA_APPROVAZIONE##################
df_RILASCI_ULTIMA_APPROVAZIONE <- unique(df_rilasci[, c("DETERMINA_SPESA","BUYER","DATA_ULTIMA_APPROVAZIONE","TIPO")])
df_RILASCI_ULTIMA_APPROVAZIONE["ACTIVITY"] <- "RILASCIO_ULTIMA_APPROVAZIONE"
names(df_RILASCI_ULTIMA_APPROVAZIONE) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_RILASCI_ULTIMA_APPROVAZIONE$END_DATE <- gsub("\\..*","",df_RILASCI_ULTIMA_APPROVAZIONE$END_DATE)
df_RILASCI_ULTIMA_APPROVAZIONE$END_DATE <- as.POSIXct(df_RILASCI_ULTIMA_APPROVAZIONE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_RILASCI_ULTIMA_APPROVAZIONE <- df_RILASCI_ULTIMA_APPROVAZIONE[!is.na(df_RILASCI_ULTIMA_APPROVAZIONE$END_DATE),]
df_RILASCI_ULTIMA_APPROVAZIONE <- df_RILASCI_ULTIMA_APPROVAZIONE[!is.na(df_RILASCI_ULTIMA_APPROVAZIONE$CASE_ID),]

df_contratti_na_DS <- unique(df_contratti[is.na(df_contratti$DETERMINA_SPESA),])
#df_oda_s4 <- df_oda[is.na(df_oda$TIPO_PADRE) & is.na(df_oda$DETERMINA_SPESA),] %>%  group_by(NUMERO) %>% filter(DATA_CREAZIONE == max(DATA_CREAZIONE))

df_contratti_DS <- unique(df_contratti[!is.na(df_contratti$DETERMINA_SPESA),])


#############CONTRATTO CREAZIONE##################
df_CONTRATTI_CREAZIONE <- unique(df_contratti_DS[, c("DETERMINA_SPESA","BUYER","DATA_CREAZIONE","TIPO")])
df_CONTRATTI_CREAZIONE["ACTIVITY"] <- "CONTRATTI CREAZIONE"

names(df_CONTRATTI_CREAZIONE) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_CONTRATTI_CREAZIONE$END_DATE <- as.POSIXct(df_CONTRATTI_CREAZIONE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_CONTRATTI_CREAZIONE <- df_CONTRATTI_CREAZIONE[!is.na(df_CONTRATTI_CREAZIONE$END_DATE),]
df_CONTRATTI_CREAZIONE <- df_CONTRATTI_CREAZIONE[!is.na(df_CONTRATTI_CREAZIONE$CASE_ID),]


#############CONTRATTI EVENTI SUCCESSIVI##################
df_CONTRATTI_EVENTI_SUCCESSIVI <- unique(df_contratti_DS[! is.na(df_contratti$CRONOLOGIA_AZIONE), c("DETERMINA_SPESA","ESEGUITO_DA","DATA_ESECUZIONE","TIPO","CRONOLOGIA_AZIONE")])
names(df_CONTRATTI_EVENTI_SUCCESSIVI) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_CONTRATTI_EVENTI_SUCCESSIVI$ACTIVITY <- paste0("CONTRATTO ", df_CONTRATTI_EVENTI_SUCCESSIVI$ACTIVITY)
df_CONTRATTI_EVENTI_SUCCESSIVI$END_DATE <- gsub("\\..*","",df_CONTRATTI_EVENTI_SUCCESSIVI$END_DATE)
df_CONTRATTI_EVENTI_SUCCESSIVI$END_DATE <- as.POSIXct(df_CONTRATTI_EVENTI_SUCCESSIVI$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_CONTRATTI_EVENTI_SUCCESSIVI <- df_CONTRATTI_EVENTI_SUCCESSIVI[!is.na(df_CONTRATTI_EVENTI_SUCCESSIVI$END_DATE),]
df_CONTRATTI_EVENTI_SUCCESSIVI <- df_CONTRATTI_EVENTI_SUCCESSIVI[!is.na(df_CONTRATTI_EVENTI_SUCCESSIVI$CASE_ID),]



#############CONTRATTI ULTIMA APPROVAZIONE##################
df_CONTRATTI_ULTIMA_APPROVAZIONE <- unique(df_contratti_DS[!is.na(df_contratti$DETERMINA_SPESA), c("DETERMINA_SPESA","DATA_ULTIMA_APPROVAZIONE","TIPO")])
df_CONTRATTI_ULTIMA_APPROVAZIONE["ACTIVITY"] <- "CONTRATTO ULTIMA APPROVAZIONE"
names(df_CONTRATTI_ULTIMA_APPROVAZIONE) <- c("CASE_ID","END_DATE","TIPO","ACTIVITY")
df_CONTRATTI_ULTIMA_APPROVAZIONE$END_DATE <- as.POSIXct(df_CONTRATTI_ULTIMA_APPROVAZIONE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_CONTRATTI_ULTIMA_APPROVAZIONE <- df_CONTRATTI_ULTIMA_APPROVAZIONE[!is.na(df_CONTRATTI_ULTIMA_APPROVAZIONE$END_DATE),]
df_CONTRATTI_ULTIMA_APPROVAZIONE <- df_CONTRATTI_ULTIMA_APPROVAZIONE[!is.na(df_CONTRATTI_ULTIMA_APPROVAZIONE$CASE_ID),]


subset_df_contratti <- subset(df_contratti_DS, STATO_ATTUALE  ==  "In lavorazione" | STATO_ATTUALE  ==  "Incompleto" | STATO_ATTUALE  ==  "Rifiutato")


#############CONTRATTI STATO ATTUALE##################

df_CONTRATTI_STATO_ATTUALE <- unique(subset_df_contratti[, c("DETERMINA_SPESA","UTENTE_STATO_ATTUALE","DATA_STATO_ATTUALE","TIPO","STATO_ATTUALE")])
names(df_CONTRATTI_STATO_ATTUALE) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_CONTRATTI_STATO_ATTUALE$ACTIVITY <- paste0("CONTRATTO ", df_CONTRATTI_STATO_ATTUALE$ACTIVITY)
df_CONTRATTI_STATO_ATTUALE$END_DATE <- as.POSIXct(df_CONTRATTI_STATO_ATTUALE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_CONTRATTI_STATO_ATTUALE$CASE_ID <- as.character(df_CONTRATTI_STATO_ATTUALE$CASE_ID)
df_CONTRATTI_STATO_ATTUALE <- df_CONTRATTI_STATO_ATTUALE[!is.na(df_CONTRATTI_STATO_ATTUALE$CASE_ID),]

#############CONTRATTO CREAZIONE##################
df_CONTRATTI_CREAZIONE <- unique(df_contratti_na_DS[, c("NUMERO","BUYER","DATA_CREAZIONE","TIPO")])
df_CONTRATTI_CREAZIONE["ACTIVITY"] <- "CONTRATTI CREAZIONE"

names(df_CONTRATTI_CREAZIONE) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_CONTRATTI_CREAZIONE$END_DATE <- as.POSIXct(df_CONTRATTI_CREAZIONE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_CONTRATTI_CREAZIONE <- df_CONTRATTI_CREAZIONE[!is.na(df_CONTRATTI_CREAZIONE$END_DATE),]
df_CONTRATTI_CREAZIONE <- df_CONTRATTI_CREAZIONE[!is.na(df_CONTRATTI_CREAZIONE$CASE_ID),]


#############CONTRATTI EVENTI SUCCESSIVI##################
df_CONTRATTI_EVENTI_SUCCESSIVI <- unique(df_contratti_na_DS[! is.na(df_contratti$CRONOLOGIA_AZIONE), c("NUMERO","ESEGUITO_DA","DATA_ESECUZIONE","TIPO","CRONOLOGIA_AZIONE")])
names(df_CONTRATTI_EVENTI_SUCCESSIVI) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_CONTRATTI_EVENTI_SUCCESSIVI$ACTIVITY <- paste0("CONTRATTO ", df_CONTRATTI_EVENTI_SUCCESSIVI$ACTIVITY)
df_CONTRATTI_EVENTI_SUCCESSIVI$END_DATE <- gsub("\\..*","",df_CONTRATTI_EVENTI_SUCCESSIVI$END_DATE)
df_CONTRATTI_EVENTI_SUCCESSIVI$END_DATE <- as.POSIXct(df_CONTRATTI_EVENTI_SUCCESSIVI$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_CONTRATTI_EVENTI_SUCCESSIVI <- df_CONTRATTI_EVENTI_SUCCESSIVI[!is.na(df_CONTRATTI_EVENTI_SUCCESSIVI$END_DATE),]
df_CONTRATTI_EVENTI_SUCCESSIVI <- df_CONTRATTI_EVENTI_SUCCESSIVI[!is.na(df_CONTRATTI_EVENTI_SUCCESSIVI$CASE_ID),]



#############CONTRATTI ULTIMA APPROVAZIONE##################
df_CONTRATTI_ULTIMA_APPROVAZIONE <- unique(df_contratti_na_DS[!is.na(df_contratti$DETERMINA_SPESA), c("NUMERO","DATA_ULTIMA_APPROVAZIONE","TIPO")])
df_CONTRATTI_ULTIMA_APPROVAZIONE["ACTIVITY"] <- "CONTRATTO ULTIMA APPROVAZIONE"
names(df_CONTRATTI_ULTIMA_APPROVAZIONE) <- c("CASE_ID","END_DATE","TIPO","ACTIVITY")
df_CONTRATTI_ULTIMA_APPROVAZIONE$END_DATE <- as.POSIXct(df_CONTRATTI_ULTIMA_APPROVAZIONE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_CONTRATTI_ULTIMA_APPROVAZIONE <- df_CONTRATTI_ULTIMA_APPROVAZIONE[!is.na(df_CONTRATTI_ULTIMA_APPROVAZIONE$END_DATE),]
df_CONTRATTI_ULTIMA_APPROVAZIONE <- df_CONTRATTI_ULTIMA_APPROVAZIONE[!is.na(df_CONTRATTI_ULTIMA_APPROVAZIONE$CASE_ID),]


subset_df_contratti2 <- subset(df_contratti_na_DS, STATO_ATTUALE  ==  "In lavorazione" | STATO_ATTUALE  ==  "Incompleto" | STATO_ATTUALE  ==  "Rifiutato")


#############CONTRATTI STATO ATTUALE##################

df_CONTRATTI_STATO_ATTUALE <- unique(subset_df_contratti2[, c("NUMERO","UTENTE_STATO_ATTUALE","DATA_STATO_ATTUALE","TIPO","STATO_ATTUALE")])
names(df_CONTRATTI_STATO_ATTUALE) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_CONTRATTI_STATO_ATTUALE$ACTIVITY <- paste0("CONTRATTO ", df_CONTRATTI_STATO_ATTUALE$ACTIVITY)
df_CONTRATTI_STATO_ATTUALE$END_DATE <- as.POSIXct(df_CONTRATTI_STATO_ATTUALE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_CONTRATTI_STATO_ATTUALE$CASE_ID <- as.character(df_CONTRATTI_STATO_ATTUALE$CASE_ID)
df_CONTRATTI_STATO_ATTUALE <- df_CONTRATTI_STATO_ATTUALE[!is.na(df_CONTRATTI_STATO_ATTUALE$CASE_ID),]




df_ricezioni_s4 <- df_ricezioni[df_ricezioni$NUMERO_PADRE & df_ricezioni$TIPO_PADRE =="ODA", ]

df_ricezioni_s4$NUMERO_PADRE <- paste0("S4_",df_ricezioni_s4$NUMERO_PADRE)

df_RICEZIONI_STATO_ATTUALE_s4 <- unique(df_ricezioni_s4[, c("NUMERO_PADRE","UTENTE","DATA_CREAZIONE","TIPO","STATO")])
names(df_RICEZIONI_STATO_ATTUALE_s4) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_RICEZIONI_STATO_ATTUALE_s4$END_DATE <- as.POSIXct(df_RICEZIONI_STATO_ATTUALE_s4$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_RICEZIONI_STATO_ATTUALE_s4$ACTIVITY <- paste0("RICEZIONE ", df_RICEZIONI_STATO_ATTUALE_s4$ACTIVITY)

#df_ricezioni2 <- df_ricezioni [-226749,]
df_ricezioni2 <- df_ricezioni[!is.na(as.numeric(df_ricezioni$DETERMINA_SPESA)),]
df_ricezioni2 <- df_ricezioni2[ df_ricezioni2$TIPO_PADRE =="RILASCIO",]

#############RICEZIONI STATO ATTUALE##################
df_RICEZIONI_STATO_ATTUALE <- unique(df_ricezioni2[, c("DETERMINA_SPESA","UTENTE","DATA_CREAZIONE","TIPO","STATO")])
names(df_RICEZIONI_STATO_ATTUALE) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_RICEZIONI_STATO_ATTUALE$END_DATE <- as.POSIXct(df_RICEZIONI_STATO_ATTUALE$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_RICEZIONI_STATO_ATTUALE$ACTIVITY <- paste0("RICEZIONE ", df_RICEZIONI_STATO_ATTUALE$ACTIVITY)

#verifica se è solo tipo padre rilascio, da confrontare con fatture

#condizione:

df_fatture_confrontate <- unique(df_fatture_confrontate[,-c (13,14)])
subset_df_fatture1 <- subset(df_fatture_confrontate, STATO_FATTURA  ==  "APPROVED" | STATO_FATTURA  ==  "NEVER APPROVED")

df_ricezioni_solodetermina <- unique(df_ricezioni2[, c("DETERMINA_SPESA","NUMERO")])
subset_df_fatture1 <- merge(df_ricezioni_solodetermina,subset_df_fatture,by.x = "NUMERO", by.y = "NUMERO_PADRE")

subset_df_fatture2 <- merge(df_ricezioni_solodetermina,subset_df_fatture,by.x = "NUMERO", by.y = "NUMERO_PADRE")
subset_df_fatture2 <- subset(subset_df_fatture2, TIPO_PADRE =="RICEZIONE")

#############STATO FATTURA#################
df_FATTURA_STATO_FATTURA <- unique(subset_df_fatture[, c("DETERMINA_SPESA","UTENTE","DATA_CONFRONTO","TIPO","STATO_FATTURA")])
names(df_FATTURA_STATO_FATTURA) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_FATTURA_STATO_FATTURA$ACTIVITY <- paste0("FATTURA ", df_FATTURA_STATO_FATTURA$ACTIVITY)
df_FATTURA_STATO_FATTURA <- df_FATTURA_STATO_FATTURA %>%  group_by(CASE_ID,ACTIVITY) %>% filter(END_DATE == max(END_DATE))

df_FATTURA_STATO_FATTURA$END_DATE <- as.POSIXct(df_FATTURA_STATO_FATTURA$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_FATTURA_STATO_FATTURA <- df_FATTURA_STATO_FATTURA[!is.na(df_FATTURA_STATO_FATTURA$CASE_ID),]
df_FATTURA_STATO_FATTURA$CASE_ID <- as.character(df_FATTURA_STATO_FATTURA$CASE_ID)



#############PADRE FATTURA#################
df_FATTURA_RICEVUTA_FATTURA <- unique(subset_df_fatture2[, c("DETERMINA_SPESA","UTENTE","DATA_RICEZIONE_FATTURA","TIPO","TIPO_PADRE")])
names(df_FATTURA_RICEVUTA_FATTURA) <- c("CASE_ID","RESOURCE","END_DATE","TIPO","ACTIVITY")
df_FATTURA_RICEVUTA_FATTURA$ACTIVITY <- paste0("FATTURA ", df_FATTURA_RICEVUTA_FATTURA$ACTIVITY)
df_FATTURA_RICEVUTA_FATTURA$END_DATE <- as.POSIXct(df_FATTURA_RICEVUTA_FATTURA$END_DATE, format = "%Y-%m-%d %H:%M:%S")
df_FATTURA_RICEVUTA_FATTURA <- df_FATTURA_RICEVUTA_FATTURA[!is.na(df_FATTURA_RICEVUTA_FATTURA$CASE_ID),]
df_FATTURA_RICEVUTA_FATTURA$CASE_ID <- as.character(df_FATTURA_RICEVUTA_FATTURA$CASE_ID)



#verifica case_id e data fattura
#case id ricezioni


#

final11 <- bind_rows(df_RDA_CREAZIONE,df_RDA_EVENTI_SUCCESSIVI,df_RDA_STATO_ATTUALE,df_ODA_CREAZIONE,df_ODA_EVENTI_SUCCESSIVI,df_ODA_DATA_STATO_ATTUALE, df_ODA_DATA_ULTIMA_APPROVAZIONE,df_ODA_CREAZIONE_s4,df_ODA_EVENTI_SUCCESSIVI_s4,df_ODA_DATA_STATO_ATTUALE_s4, df_ODA_DATA_ULTIMA_APPROVAZIONE_s4, df_RICEZIONI_STATO_ATTUALE,df_RICEZIONI_STATO_ATTUALE_s4, df_RP_CREAZIONE,df_RP_EVENTI_SUCCESSIVI,df_RILASCI_CREAZIONE,df_RILASCI_EVENTI_SUCCESSIVI,df_RILASCI_ULTIMA_APPROVAZIONE, df_PREVENTIVI_CREAZIONE, df_PREVENTIVI_EVENTI_SUCCESSIVI, df_PREVENTIVI_STATO_ATTUALE, df_PREVENTIVI_ASSEGNATO, df_CONTRATTI_CREAZIONE,df_CONTRATTI_EVENTI_SUCCESSIVI, df_CONTRATTI_STATO_ATTUALE, df_CONTRATTI_ULTIMA_APPROVAZIONE,df_FATTURA_STATO_FATTURA, df_FATTURA_RICEVUTA_FATTURA)

#case

df_rda_case_attribute <- subset(df_rda,select = c(NUMERO, CODICE_SEDE, DESCRIZIONE_PRODOTTO, IMPORTO_NETTO, NOME_SEDE, PROCEDURA_AFFIDAMENTO))
colnames(df_rda_case_attribute) <- c("CASE_ID", "CODICE_SEDE", "DESCRIZIONE_PRODOTTO", "IMPORTO_NETTO", "NOME_SEDE", "PROCEDURA_AFFIDAMENTO")


df_oda_case_attribute_s4 <- subset(df_oda_s4,select = c(NUMERO, CODICE_SEDE, DESCRIZIONE_PRODOTTO, IMPORTO_NETTO, NOME_SEDE, PROCEDURA_AFFIDAMENTO))
colnames(df_oda_case_attribute_s4) <- c("CASE_ID", "CODICE_SEDE", "DESCRIZIONE_PRODOTTO", "IMPORTO_NETTO", "NOME_SEDE","PROCEDURA_AFFIDAMENTO")


df_oda_case_attribute <- subset(df_oda,select = c(NUMERO_PADRE, CODICE_SEDE, DESCRIZIONE_PRODOTTO, IMPORTO_NETTO, NOME_SEDE, PROCEDURA_AFFIDAMENTO))
colnames(df_oda_case_attribute) <- c("CASE_ID", "CODICE_SEDE", "DESCRIZIONE_PRODOTTO", "IMPORTO_NETTO", "NOME_SEDE", "PROCEDURA_AFFIDAMENTO")


df_rp_case_attribute <- subset(df_rp,select = c(IDENTIFICATIVO_PADRE, CODICE_SEDE, DESCRIZIONE_PRODOTTO, IMPORTO_NETTO, NOME_SEDE,PROCEDURA_AFFIDAMENTO))
colnames(df_rp_case_attribute) <- c("CASE_ID", "CODICE_SEDE", "DESCRIZIONE_PRODOTTO", "IMPORTO_NETTO", "NOME_SEDE","PROCEDURA_AFFIDAMENTO")


df_preventivi_case_attribute <- subset(df_preventivi,select = c(DETERMINA_SPESA, CODICE_SEDE, DESCRIZIONE_PRODOTTO, IMPORTO_NETTO, NOME_SEDE, PROCEDURA_AFFIDAMENTO))
colnames(df_preventivi_case_attribute) <- c("CASE_ID", "CODICE_SEDE", "DESCRIZIONE_PRODOTTO", "IMPORTO_NETTO", "NOME_SEDE","PROCEDURA_AFFIDAMENTO")


df_rilasci_case_attribute <- subset(df_rilasci,select = c(DETERMINA_SPESA, CODICE_SEDE, DESCRIZIONE_PRODOTTO, IMPORTO_NETTO, NOME_SEDE, PROCEDURA_AFFIDAMENTO))
colnames(df_rilasci_case_attribute) <- c("CASE_ID", "CODICE_SEDE", "DESCRIZIONE_PRODOTTO", "IMPORTO_NETTO", "NOME_SEDE","PROCEDURA_AFFIDAMENTO")


df_contratti_case_attribute <- subset(df_contratti,select = c(DETERMINA_SPESA, CODICE_SEDE, DESCRIZIONE_PRODOTTO, IMPORTO_TOTALE_NETTO, NOME_SEDE, PROCEDURA_AFFIDAMENTO))
colnames(df_contratti_case_attribute) <- c("CASE_ID", "CODICE_SEDE", "DESCRIZIONE_PRODOTTO", "IMPORTO_NETTO", "NOME_SEDE","PROCEDURA_AFFIDAMENTO")

#in ricezioni,fatture no importo netto


df_ricezioni_case_attribute_s4 <- subset(df_ricezioni_s4,select = c(NUMERO_PADRE, CODICE_SEDE, DESCRIZIONE_PRODOTTO, NOME_SEDE))
colnames(df_ricezioni_case_attribute_s4) <- c("CASE_ID", "CODICE_SEDE", "DESCRIZIONE_PRODOTTO", "NOME_SEDE")

df_ricezioni_case_attribute <- subset(df_ricezioni2,select = c(DETERMINA_SPESA, CODICE_SEDE, DESCRIZIONE_PRODOTTO, NOME_SEDE))
colnames(df_ricezioni_case_attribute) <- c("CASE_ID", "CODICE_SEDE", "DESCRIZIONE_PRODOTTO", "NOME_SEDE")
#in fatture no descrizione prodotto


subset_df_fatture_case_attribute <- subset(subset_df_fatture, select = c(DETERMINA_SPESA, CODICE_SEDE, NOME_SEDE))
colnames(subset_df_fatture_case_attribute) <- c("CASE_ID", "CODICE_SEDE", "NOME_SEDE")

#df_case_attribute <- bind_rows

df_case_attribute <- bind_rows(df_rda_case_attribute, df_oda_case_attribute, df_oda_case_attribute_s4,df_rp_case_attribute,df_preventivi_case_attribute,df_rilasci_case_attribute,df_ricezioni_case_attribute, df_ricezioni_case_attribute_s4, subset_df_fatture_case_attribute, df_contratti_case_attribute)
df_case_attribute <- unique(df_case_attribute)
#merge tra final11 e case attribute= final con case_id in comune

#final11 <- final11 %>%  group_by(CASE_ID,ACTIVITY) %>% filter(END_DATE == max(END_DATE))

final11 <- merge(final11,df_case_attribute,by = "CASE_ID",all.x = TRUE)

#modifica write csv con final

write.csv(final11,"test_ciclopassivo9.csv", row.names=FALSE)


