# Load libraries
library(dplyr)
library(stringr)

# Read in data, with the same name that we specified in `flat.yml`
raw_data <- readxl::read_excel("./raw.xlsx")

# All the processing!
clean_data <- raw_data %>%
  mutate(Zipcode = as.character(Zipcode),
         Year = lubridate::year(`Date of Incident (month/day/year)`),
         Sex = ifelse(is.na(`Victim's gender`), 'Unknown', `Victim's gender`))

### Additional processing goes here...

# Output data
readr::write_csv(clean_data, "./output.csv")
