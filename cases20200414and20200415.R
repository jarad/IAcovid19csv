library("dplyr")
library("tidyr")
library("readr")

source("casesUntil20200413.R") # Creates casesUntil20200413 data.frame

# Read in and combine cumulative data
cum20200413 <- casesUntil20200413 %>% 
  group_by(county, age) %>% 
  summarize(`20200413` = sum(count)) %>%
  na.omit

cum20200414 <- readr::read_csv("raw/20200414.csv") %>% 
  select(-deaths) %>%
  rename(`20200414` = confirmed) %>%
  na.omit

cum20200415 <- readr::read_csv("raw/20200415.csv") %>% 
  filter(type == "confirmed") %>%
  select(-type, -total) %>%
  tidyr::gather(age, count, -county) %>%
  na.omit
    
cases20200414 <- cum20200414 %>% 
  left_join(cum20200413, by = c("county","age")) %>%
  mutate(`20200413` = ifelse(is.na(`20200413`), 0, `20200413`)) %>%
  mutate(count = `20200414` - `20200413`)

all = cum20200415 %>% left_join(cum20200414) %>% left_join(cum20200413)

readr::write_csv(cases, path = "cases.csv")
