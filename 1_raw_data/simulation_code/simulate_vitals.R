# Carico il dataset dei pazienti
patients <- read.csv("1_raw_data/simulated/patients.csv")

# Creo tutte le combinazioni di pazienti e giorni visita
# VISITDY = giorno della visita: 1, 7, 14, 21, 28
visits <- expand.grid(
  USUBJID = patients$USUBJID,
  VISITDY = c(1, 7, 14, 21, 28)
)

# Unisco la tabella delle visite con il gruppo trattamento di ogni paziente
vitals <- merge(visits, patients[, c("USUBJID", "ARMCD")], by = "USUBJID")

# Simulo i segni vitali
set.seed(456)

# Temperatura corporea: più alta all'inizio, poi migliora
vitals$TEMP <- rnorm(nrow(vitals),
                     mean = ifelse(vitals$ARMCD == "PBO",
                                   38 - vitals$VISITDY * 0.03,
                                   38 - vitals$VISITDY * 0.05),
                     sd = 0.3)

# Saturazione O2: migliore nel tempo, più velocemente con Viralblock
vitals$O2SAT <- round(rnorm(nrow(vitals),
                            mean = ifelse(vitals$ARMCD == "PBO",
                                          94 + vitals$VISITDY * 0.1,
                                          94 + vitals$VISITDY * 0.2),
                            sd = 1.2), 1)

# Salvo il file vitals.csv
write.csv(vitals, "1_raw_data/simulated/vitals.csv", row.names = FALSE)