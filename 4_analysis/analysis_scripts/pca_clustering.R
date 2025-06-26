# Load required libraries
library(tidyverse)
library(cluster)
library(factoextra)

# Load datasets
adsl <- read.csv("/Users/pasqualinodipilla/Desktop/viralblock-clinical-trial/3_adam/data/adsl.csv")
advs <- read.csv("/Users/pasqualinodipilla/Desktop/viralblock-clinical-trial/3_adam/data/advs.csv")

# Filter only SPO2 from ADVS and calculate mean per subject
spo2_summary <- advs %>%
  filter(PARAMCD == "SPO2") %>%
  group_by(USUBJID) %>%
  summarise(SPO2_mean = mean(AVAL, na.rm = TRUE))

# Merge ADSL with mean SPO2
merged <- adsl %>%
  select(USUBJID, AGE) %>%
  left_join(spo2_summary, by = "USUBJID") %>%
  drop_na()

# Prepare data for PCA and clustering
df_numeric <- merged %>%
  select(AGE, SPO2_mean) %>%
  scale()

# Principal Component Analysis
pca <- prcomp(df_numeric, center = TRUE, scale. = TRUE)

# Plot PCA
pdf("/Users/pasqualinodipilla/Desktop/viralblock-clinical-trial/4_analysis/analysis_outputs/pca_plot.pdf")
fviz_pca_biplot(pca, repel = TRUE, title = "PCA: AGE and SPO2")
dev.off()

# K-means clustering (2 clusters as example)
set.seed(123)
k2 <- kmeans(df_numeric, centers = 2, nstart = 25)

# Visualize clusters
pdf("/Users/pasqualinodipilla/Desktop/viralblock-clinical-trial/4_analysis/analysis_outputs/cluster_plot.pdf")
fviz_cluster(k2, data = df_numeric, geom = "point", ellipse.type = "norm",
             main = "K-means Clustering (k=2)")
dev.off()
