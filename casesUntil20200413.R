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

casesUntil20200413 = read_cases_dir("raw/cases/Until20200413", "*.csv", 
                      into = c("raw","cases","until","date","csv")) %>%
  
  dplyr::mutate(date = as.Date(date, format = "%Y%m%d"),
                age = dplyr::recode(age, 
                                 `0-17` = "Child",
                                 `18-40` = "Adult",
                                 `41-60` = "Middle Age",
                                 `61-80` = "Older Adult",
                                 `81+`   = "Elderly")) %>%
  
  select(date, county, age, count)
