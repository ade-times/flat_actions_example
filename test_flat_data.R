


#region_data <- read_csv("https://api.coronavirus.data.gov.uk/v2/data?areaType=region&metric=newCasesByPublishDate&metric=newCasesBySpecimenDate&metric=cumCasesByPublishDate&format=csv")
raw_data <- readr::read_csv("./raw2.csv")


# Get Regional data into NHS regions --------------------------------------
region_data_conv <- raw_data %>%
  mutate(region = case_when(
    areaName =="West Midlands" ~ "Midlands",
    areaName =="East Midlands" ~ "Midlands",
    areaName =="North East" ~ "North East and Yorkshire",
    areaName =="Yorkshire and The Humber" ~ "North East and Yorkshire",
    TRUE ~ areaName
  ))%>%
  group_by(date, region)%>%
  summarise(value = sum(newCasesByPublishDate, na.rm = TRUE))%>%
  mutate(metric = "cases")

# Hospitalisations --------------------------------------------------------
hosp <- read_csv("https://api.coronavirus.data.gov.uk/v2/data?areaType=nhsRegion&metric=hospitalCases&metric=newAdmissions&metric=covidOccupiedMVBeds&format=csv")

hosp.1 <- hosp %>%
  select(date, region = areaName, newAdmissions, "hospitalBeds" = hospitalCases, covidOccupiedMVBeds)%>%
  pivot_longer(c(3:ncol(.)), names_to="metric")%>%
  drop_na()


#  Combine datasets -------------------------------------------------------
region_data_tot <- bind_rows(region_data_conv, hosp.1)

region_data.2 <- region_data_tot %>%
  arrange(date)%>%
  mutate(pop=case_when(
    region=="East of England" ~ 6269161,
    region=="London" ~ 9002488,
    region=="Midlands" ~ 4865583+5961929,
    region=="North East and Yorkshire" ~ 2680763+5526350,
    region=="North West" ~ 7367456,
    region=="South East" ~ 9217265,
    region=="South West" ~ 5659143),
    rate=value*100000/pop) %>%
  filter(date > "2020-08-30")%>%
  group_by(region, metric)%>%
  mutate(
    rollraw = rollmean(value, 7, align="right", fill=NA),
    rollrate = rollmean(rate, 7, align="right", fill=NA),
    roll_change = (rollraw - lag(rollraw, 7)) / lag(rollraw, 7) *100
  )%>%
  group_by(date, metric)%>%
  arrange(desc(rollrate))%>%
  mutate(rank = row_number())

readr::write_csv(region_data.2, "./output2.csv")
