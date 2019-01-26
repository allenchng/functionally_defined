library(dplyr)
library(readr)
library(tidyr)
library(stringr)

arbys.locations <- read_csv('./Arbys_USA_CAN.csv',
                            col_names = FALSE)

names(arbys.locations) <- c('longitude', 'latitude', 'city-state', 'address')

arbys.cleaned <- arbys.locations %>%
  separate('city-state', c('city', 'state'), ',') %>%
  separate(city, c('store', 'city'), '-') %>%
  select(-store) %>%
  separate(address, c("street", "city", "state", "phone"), ",") %>%
  mutate(phone = str_trim(phone),
         city = str_trim(city))

write_csv(arbys.cleaned, "./arbys_data.csv")