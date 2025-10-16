setwd("C:/Users/prez519/OneDrive - PNNL/Documents/ArcGIS/Projects/DEWWind Graphics")

library(dplyr)
library(ggplot2)

# Read in colleges and universities
colleges <- read.csv("CollegesAndUniversities_IPEDS_HIFLD.csv")
# Set all addresses to lower case for left_join
colleges <- colleges %>%
  mutate(ADDRESS = tolower(ADDRESS))
# Rename ADDRESS column for left_join
colnames(colleges)[which(colnames(colleges) == "ADDRESS")] <- "streetAddress"

# Read in NASA's MSI list
NASA_MSI <- read.csv("institutions_NASA_MSI.csv")
# Set all addresses to lower case for left_join
NASA_MSI <- NASA_MSI %>%
  mutate(streetAddress = tolower(streetAddress))

# left_join to combine colleges and universities
# with MSI list
colleges_MSI <- left_join(colleges, NASA_MSI, by = "streetAddress",
                          multiple = "any")

# write file to uplaod to ArcGIS Pro
write.csv(colleges_MSI, "colleges_with_MSI_data.csv", row.names = FALSE)
