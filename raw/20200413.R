library("dplyr")
library("tidyr")
library("readr")

col_types <- readr::cols(
  county = readr::col_character(),
  age    = readr::col_character(),
  count  = readr::col_integer()
)

read_cases_csv = function(f, into) {
  readr::read_csv(f, col_types = col_types) %>%
    dplyr::mutate(file = f) %>%
    tidyr::separate(file, into) 
}

read_cases_dir = function(path, pattern, into) {
  files = list.files(path       = path,
                     pattern    = pattern,
                     recursive  = TRUE,
                     full.names = TRUE)
  plyr::ldply(files, read_cases_csv, into = into)
}

cases = read_cases_dir("cases/Until20200413", "*.csv", 
                      into = c("cases","until","date","csv")) %>%
  
  dplyr::mutate(date = as.Date(date, format = "%Y%m%d")) %>%
  
  select(date, county, age, count) 

cumulative = cases %>% 
  group_by(county, age) %>%
  summarize(count = sum(count)) 
  
readr::write_csv(cumulative, path = "20200413.csv")
