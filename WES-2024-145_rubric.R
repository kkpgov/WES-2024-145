setwd("C:/Users/prez519/OneDrive - PNNL/Documents/ArcGIS/Projects/DEWWind Graphics")

library(dplyr)
library(ggplot2)

# Set Institution points based on rubric

# Minority-Serving Institutions (MSIs), e.g., historically
# black colleges and universities, tribal colleges, etc. 
MSI_points <- 5

# Community colleges and vocational Institutions
# i.e., technical colleges, trade schools 
CC_vocation_points <- 3

# Women's colleges and universities
women_points <- 2

# All other institutions
other <- 1


################################################################################
# Set Location points based on rubric

# Institution within 100 mi of distributed wind installer
installer_points <- 3

# Institution in areas classified as USDA REAP
REAP_points <- 2

# Institution in wind-rich areas with behind-the-meter (BTM)/front-of-the-meter (FTM) DW capital expenditure at or above the 80th national percentile
capex_points <- 1

################################################################################
# Calculate Demographic and Socioeconomic Indicators from
# EJScreen at tract level, nationwide: https://www.epa.gov/ejscreen/download-ejscreen-data
EJ_screen <- read.csv("EJScreen_Full_with_AS_CNMI_GU_VI_Tracts.csv")

# Institution census tract w/aggregate minority
# population at or about the 75th national percentile
minority_points <- 3
# note that quantile() returns five values, the fourth of which
# is hte 75th percentile
minority_percentile <- quantile(as.numeric(EJ_screen$PEOPCOLORPCT), na.rm = TRUE)[4]

# Institution census tract with "less than high school education"
# population at or above 10%
education_points <- 2

# Institution census tract with low-income
# population at or above 90th national percentile (specified as probs)
income_points <- 2
income_percentile <- quantile(as.numeric(EJ_screen$LOWINCPCT), na.rm = TRUE,
                              probs = .9)


# Institution census tract with "limited English
# speaking" populations (linguistic isolation)
# at or above 90th national percentile (specified as probs)
language_points <- 2
language_percentile <- quantile(as.numeric(EJ_screen$LINGISOPCT), na.rm = TRUE,
                                probs = .9)

# Institution census tract w/unemployment
# at or above 90th national percentile (specified as probs)
employment_points <-2
employment_percentile <- quantile(as.numeric(EJ_screen$UNEMPPCT), na.rm = TRUE,
                                  probs = .9)

################################################################################
# Calculate BTM/FOM CapEx from https://a2e.energy.gov/ds/dw/btm
# and https://a2e.energy.gov/ds/dw/fom

dWind <- read.csv("dWind_BTM_and_FOM.csv")
BTM_percentile <- quantile(as.numeric(dWind$BTM.Breakeven.Cost), na.rm = TRUE, probs = .8)
FOM_percentile <- quantile(as.numeric(dWind$FOM.Breakeven.Cost), na.rm = TRUE, probs = .8)
