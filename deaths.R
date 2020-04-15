library("dplyr")
library("tidyr")
library("readr")

col_types <- readr::cols(
  county = readr::col_character(),
  age    = readr::col_character(),
  count  = readr::col_integer()
)

read_deaths_csv = function(f, into) {
  readr::read_csv(f, col_types = col_types) %>%
    dplyr::mutate(file = f) %>%
    tidyr::separate(file, into) 
}

read_deaths_dir = function(path, pattern, into) {
  files = list.files(path       = path,
                     pattern    = pattern,
                     recursive  = TRUE,
                     full.names = TRUE)
  plyr::ldply(files, read_deaths_csv, into = into)
}

deaths = read_deaths_dir("deaths", "*.csv", 
                      into = c("deaths","date","csv")) %>%
  
  select(date, county, age, count)

readr::write_csv(deaths, path = "deaths.csv")
