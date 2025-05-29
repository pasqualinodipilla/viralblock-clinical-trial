#obiettivo script: creare un dataset con 300 pazienti simulati e contenente:
# ID paziente, età, sesso, gruppo trattamento (Viralblock o Placebo), paese.

#Imposto il seed per la riproducibilità (così otteniamo sempre gli stessi dati)
set.seed(123)

#Definisco il numero totale di soggetti da simulare
n <- 300

#Creo un dataframe chiamato "patients" con 300 righe
patients <- data.frame(
  # USUBJID= Unique Subject Identifier, standard CDISC (es. SUBJ001, SUBJ002,..)
  USUBJID = paste0("SUBJ", sprintf("%03d", 1:n)),
  # Età dei pazienti: valori casuali tra 20 e 85 anni
  AGE = sample(20:85, n, replace = TRUE),
  # Sesso biologico: "M" (maschio) o "F" (femmina), distribuzione casuale
  SEX = sample(c("M", "F"), n, replace = TRUE),
  # Gruppo di trattamento: "PBO" = placebo, "VRB" = Viralblock
  ARMCD = sample(c("PBO", "VRB"), n, replace = TRUE),
  # Paese di provenienza del paziente
  COUNTRY = sample(c("ITA", "USA", "DEU", "FRA"), n, replace = TRUE)
)

# Salvo il dataset come file csv nella corrispondente cartella
write.csv(patients, "1_raw_data/simulated/patients.csv", row.names = FALSE)