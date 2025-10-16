setwd("C:/Users/prez519/OneDrive - PNNL/Documents/ArcGIS/Projects/DEWWind Graphics")

library(dplyr)
library(ggplot2)

# Call rubric script
source("dewwind_rubric.R")

# Import Institutions after GIS joins
institutions <- read.csv("colleges_universities_MSIs_EJScreen_Installers_dWind.csv", check.names = FALSE)
# Rename the Join_Count columns for easy identification
colnames(institutions)[which(colnames(institutions) == "Join_Count")] <- c("Join_Count_REAP",
                                                                           "Join_Count_Installers",
                                                                           "Join_Count_EJ")

# Create new dataframe for results only containing columns that are needed
# for post-processing and matching
results <- institutions[ , c("IPEDSID", #Colleges and Universities
                             "NAME", #Colleges and Universities
                             "LATITUDE", #Colleges and Universities
                             "LONGITUDE", #Colleges and Universities
                             "NAICS_DESC", #NASA MSI
                             "categories", #NASA MSI
                             "Join_Count_EJ", #EJScreen
                             "withinInstallerProximity",
                             "PEOPCOLORPCT", #EJScreen
                             "LOWINCPCT", #EJScreen
                             "UNEMPPCT", #EJScreen
                             "LESSHSPCT", #EJScreen
                             "LINGISOPCT", #EJScreen
                             "FOM Breakeven Cost", #dWind
                             "BTM Breakeven Cost", #dWind
                             "Join_Count_REAP")] #USDAREAP


# Calculate points for each rubric criteria

#####################################################################
# Institution Points 

# MSI
# No points if the field is blank
results[which(is.na(results$categories)), "MSI_points"] <- 0
# Assign points for any category of MSI
results[which(!is.na(results$categories)), "MSI_points"] <- MSI_points

# Community colleges and vocational Institutions
# Assign points for community colleges and vocational institutions
results[which(results$NAICS_DESC ==
                       "OTHER TECHNICAL AND TRADE SCHOOLS" |
                       results$NAICS_DESC == "JUNIOR COLLEGES"), "CC_Vocation_points"] <- CC_vocation_points
# No points otherwise
results[which(results$NAICS_DESC !=
                "OTHER TECHNICAL AND TRADE SCHOOLS" &
                results$NAICS_DESC != "JUNIOR COLLEGES"), "CC_Vocation_points"] <- 0

# No indicator for Womens College in data set

# Other Institution Type
# Assign points for other colleges, universities, and professional schools
results[which(results$NAICS_DESC == "COLLEGES, UNIVERSITIES, AND PROFESSIONAL SCHOOLS"),
        "Other_Institution_points"] <- other
# No points otherwise
results[which(results$NAICS_DESC != "COLLEGES, UNIVERSITIES, AND PROFESSIONAL SCHOOLS"),
        "Other_Institution_points"] <- 0

######################################################################
# Location Points 

# Institution within 100 mi of distributed wind installer
# Assign points if within 100 miles
results[which(results$withinInstallerProximity == "yes"), "installer_points"] <-
  installer_points
# No points otherwise
results[which(results$withinInstallerProximity != "yes"), "installer_points"] <- 0

# Institution in areas classified as USDA REAP
# Assign points if REAP eligible
results[which(results$Join_Count_REAP == 0), "REAP_eligible_points"] <- REAP_points
# No points otherwise
results[which(results$Join_Count_REAP == 1), "REAP_eligible_points"] <- 0

# Institution in wind-rich areas with behind-the-meter (BTM)/front-of-the-meter (FTM) DW capital expenditure at or above the 80th national percentile
# Assign points if either BTM or FOM threshold is met
results[which(results$`BTM Breakeven Cost` >= BTM_percentile |
                results$`FOM Breakeven Cost` >= FOM_percentile),
        "capex_points"] <- capex_points
# No points otherwise
results[which(results$`BTM Breakeven Cost` < BTM_percentile &
                results$`FOM Breakeven Cost` < FOM_percentile),
        "capex_points"] <- 0

######################################################################
# Demographic and Socioeconomic Indicators

# Institution census tract w/aggregate minority
# population at or about the 75th national percentile
# Assign points if minority threshold met
results[which(results$PEOPCOLORPCT >= minority_percentile),
        "minority_points"] <- minority_points
# No points otherwise
results[which(results$PEOPCOLORPCT < minority_percentile),
        "minority_points"] <- 0

# Institution census tract with "less than high school education"
# population at or above 10%
# Assign points if unemployment threshold met
results[which(results$LESSHSPCT >= .10),
        "education_points"] <- education_points
# No points otherwise
results[which(results$LESSHSPCT < .10),
        "education_points"] <- 0

# Institution census tract with low-income
# population at or above 90th national percentile
# Assign points if low-income threshold met
results[which(results$LOWINCPCT >= income_percentile),
        "income_points"] <- income_points
# No points otherwise
results[which(results$LOWINCPCT < income_percentile),
        "income_points"] <- 0

# Institution census tract with "limited English
# speaking" populations (linguistic isolation)
# at or above 90th national percentile
# Assign points if linguistic isolation threshold met
results[which(results$LINGISOPCT >= language_percentile),
        "language_points"] <- language_points
# No points otherwise
results[which(results$LINGISOPCT < language_percentile),
        "language_points"] <- 0

# Institution census tract w/unemployment
# at or above 90th national percentile
# Assign points if unemployment threshold met
results[which(results$UNEMPPCT >= employment_percentile),
        "employment_points"] <- employment_points
# No points otherwise
results[which(results$UNEMPPCT < employment_percentile),
        "employment_points"] <- 0


######################################################################
# Calculate totals
# Note this does not include womens colleges
results$total_points <- results$MSI_points +
  results$CC_Vocation_points +
  results$Other_Institution_points +
  results$installer_points +
  results$REAP_eligible_points +
  results$capex_points +
  results$income_points +
  results$language_points +
  results$minority_points +
  results$employment_points +
  results$education_points

write.csv(results, "colleges_universities_dewwind_results.csv", row.names = FALSE)
