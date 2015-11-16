# para instalar os pacotes use
# install.packages("nomepacote", dep = TRUE)

library(lubridate)
library(plyr)
library(dplyr)
library(XML)
#library(XML2R)
library(reshape2)
library(tidyr)
library(doBy)
library(stringr)
library(openair)

options(stringsAsFactors = FALSE)

####################################################
# funcao para calcular ultimo dia do mês
####################################################
last_day <- function(idate = as.Date("2010-02-16")) {
  lubridate::ceiling_date(idate, "month") - lubridate::days(1)
}


# funcao para construir url 
wyoming_site <- function(idate = as.Date("2010-02-16")
                         ,stnm    = 83937
){
  stopifnot(class(idate) %in% c("Date", "character", "POSIXct", "POSIXt"))
  if(class(idate) == "character") idate <- as.Date(idate)
  
  # url com dados de sondagens da University of Wyoming, EUA
  url_address <- paste0("http://weather.uwyo.edu/cgi-bin/sounding?"
                        ,"region=samer"
                        ,"&TYPE=TEXT%3ALIST"
                        ,"&YEAR=YYYY"
                        ,"&MONTH=MM"
                        ,"&FROM=0100"
                        ,"&TO=ED12"
                        ,"&STNM=STATION")
  
  iyear <- lubridate::year(idate)
  imonth <- lubridate::month(idate)
  end_day <- lubridate::day(last_day(idate))
  
  # substitui data do mês atual no link da página de sondagens
  the_url <- 
    url_address %>% 
    gsub("YYYY", iyear, .) %>%
    gsub("MM", imonth, .) %>%
    gsub("ED" , end_day, .) %>%
    gsub("STATION" , stnm, .) 
  
  return(the_url) 
}
# TEST
# wyoming_site(idate = as.Date("2012-10-16"), stnm = 83937)

####################################################
# funcao para converter texto do html para lista
####################################################
extract_data_html <- function(x) {
  con <- x %>% xmlValue %>% textConnection()
  out <- con %>% readLines() 
  close(con)
  rm(x)
  return(out)
}

####################################################
# Funcao para converter linhas de texto para dataframe
####################################################
textlines2dataframe<- function(y, ncols = 11){
  #ncols: colunas que devem ter o arquivo , 7 eh o espaco
  # y <- profiles_list[[1]]
  
  con <- y %>% textConnection()
  sonde_data <- read.fwf(con, width = rep(7, ncols), head = F, skip = 4)
  close(con)
  # original
  #names(sonde_data) <- tolower(c("PRES", "HGHT", "TEMP", "DWPT", "RELH", "MIXR", "DRCT", "SKNT", "THTA", "THTE", "THTV"))
  # new
  names(sonde_data) <- tolower(c("PRES", "HGEOP", "TEMP", "DEWP", "RH", "MIXR", "WD", "WS", "THETA", "THETAE", "THETAV"))
  #   Description of Sounding Columns
  #   Parameter	Description	Units
  #   PRES:	Atmospheric Pressure	[hPa]
  #   HGHT:	Geopotential Height	[meter]
  #   TEMP:	Temperature	[celsius]
  #   DWPT:	Dewpoint Temperature	[celsius]
  #   RELH:	Relative Humidity	[%]
  #   MIXR:	Mixing Ratio	[gram/kilogram]
  #   DRCT:	Wind Direction	[degrees true]
  #   SKNT:	Wind Speed	[knot]
  #   THTA:	Potential Temperature	[kelvin]
  #   THTE:	Equivalent Potential Temperature	[kelvin]
  #   THTV:	Virtual Potential Temperature	[kelvin]
  return(sonde_data)
}

####################################################
# funcao para gerar vetor que converte 
# strings com abb dos meses para numero do mes
####################################################
month_num <- function() {
  v <- 1:12
  v %>% 
    setNames(month.abb) %>%
    return()
}

####################################################
# converte html com dados das sondagens do mes para data.frame
####################################################
download_sounding <- function(sounding_date_url = wyoming_site(idate)){
  
  
  http_data <- 
    sounding_date_url %>% 
    XML::htmlTreeParse(useInternalNodes = FALSE) %>%
    XML::xmlRoot() 
  
  x <- http_data[["body"]] %>% 
    XML::xmlSApply(extract_data_html) %>% 
    reshape2::melt()
  #head(x)
  #x[1:10, 1]
  rm(http_data, sounding_date_url)
  return(x)
}

####################################################
# extract date time from downloaded sounding data
####################################################
date_time_from_sounding <- function(x){
  
  x %>%  dplyr::filter(L1 == "h2") %>%
    dplyr::select(value) %>% 
    `[[`(1) %>%
    strsplit("Observations at") %>% 
    unlist() %>% 
    `[`(c(FALSE, TRUE)) %>%
    strsplit("Z") %>% 
    llply(function(x) x %>% 
            rev() %>% 
            paste0(collapse = " ") %>%
            stringr::str_trim() %>%
            stringr::str_replace_all(month_num()) %>%
            paste("00 00")
    ) %>%
    unlist() %>%
    parse_date_time(" %d %m %Y  %H %M %S") %>%
    return()
}# end date_time_from_sounding

####################################################
# extract profile for each date time
####################################################
extract_profiles <- function(x, dates){
  # rows intervals containing sounding data tables
  profile_rows <- cbind(srow = which(x$L1 == "h2") + 1, erow = which(x$L1 == "h3") - 1)
  # list with data from each sounding
  profiles_list <- 
    seq %>%
    mapply(from = profile_rows[, "srow"], to = profile_rows[,"erow"], SIMPLIFY = FALSE) %>%
    plyr::llply(function(index_range) x[index_range, "value"]) %>%
    setNames(dates) 
  # dataframe with data from each sounding including a date colum
  profiles_df <- ldply(seq_along(profiles_list)
                       ,function(i){
                         # i <- 1
                         y <- profiles_list[i]
                         idate <- names(y)
                         my_df <- textlines2dataframe(y[[1]]) %>%
                           dplyr::mutate(date = ymd_hms(idate), id_prof = i)
                         rm(i, y, idate)
                         return(my_df)
                       }) 
  rm(profiles_list, profile_rows, x) 
  return(profiles_df)
} # end extract_profiles

####################################################
# lookup table to replace parameters names
# by parameter abb
####################################################
recode_vars_names <- function(x){
  
  tab <- 
    data.frame(description = c("Station identifier",
                               "Station number",
                               "Observation time",
                               "Station latitude",
                               "Station longitude",
                               "Station elevation",
                               "Showalter index",
                               "Lifted index",
                               "LIFT computed using virtual temperature",
                               "SWEAT index",
                               "K index",
                               "Cross totals index",
                               "Vertical totals index",
                               "Totals totals index",
                               "Convective Available Potential Energy",
                               "CAPE using virtual temperature",
                               "Convective Inhibition",
                               "CINS using virtual temperature",
                               
                               "Equilibrum Level",
                               #"EQLV computed by using the virtual temperature",
                               "Equilibrum Level using virtual temperature",
                               "Level of Free Convection",
                               "LFCT using virtual temperature",
                               
                               "Bulk Richardson Number",
                               "Bulk Richardson Number using CAPV",
                               "Temp [K] of the Lifted Condensation Level",
                               "Pres [hPa] of the Lifted Condensation Level",
                               "Mean mixed layer potential temperature",
                               "Mean mixed layer mixing ratio",
                               "1000 hPa to 500 hPa thickness",
                               "Precipitable water [mm] for entire sounding"),
               parameter = tolower(c("stn_id",
                                     "stn_num",
                                     "obs_time",
                                     "lat",
                                     "lon",
                                     "elev",
                                     "SHOW",
                                     "LIFT",
                                     "LFTV",
                                     "SWET",
                                     "K",
                                     "CTOT",
                                     "VTOT",
                                     "TTOT",
                                     "CAPE",
                                     "CAPEV",
                                     "CINS",
                                     "CINV",
                                     
                                     "EQLV",
                                     "EQTV",
                                     "LFCT",
                                     "LFCTV",
                                     
                                     "BRICH",
                                     "BRICHV",
                                     "LCLT",
                                     "LCLP",
                                     "MLTH",
                                     "MLTR",
                                     "THTK",
                                     "PWAT"
               )))
  new_names <- doBy::recodeVar(x = x, 
                               src = as.list(tab$description), 
                               tgt = as.list(tab$parameter))
  return(new_names)
}# end recode_var_names


####################################################
# conversion of text with station info and sounding indices
# to a dataframe
####################################################
sounding_indices_text2data_frame <- function(list_element){
  # list_element <- y[1]
  
  list_element[[1]] %>% 
    # remove spaces
    stringr::str_trim() %>%
    # split names and values
    stringr::str_split(":") %>%
    ldply() %>%
    setNames(c("parameter", "value")) %>%
    mutate(parameter = recode_vars_names(x = parameter))
  
}# end sounding_indices_text2data_frame

####################################################
# extract profile for each date time
####################################################
extract_thermo_index <- function(x, dates){
  # rows intervals containing sounding data tables
  tindex_rows <- cbind(srow = x$value %>% grep("Station information", .) + 1
                       ,erow = x$value %>% grep("Precipitable water", .))
  
  # list with data from each sounding
  tindexes_list <- 
    seq %>%
    mapply(from = tindex_rows[, "srow"], to = tindex_rows[,"erow"], SIMPLIFY = FALSE) %>%
    plyr::llply(function(index_range) x[index_range, "value"]) %>%
    setNames(dates) 
  # dataframe with data from each sounding including a date colum
  tindexes_df <- ldply(seq_along(tindexes_list)
                       ,function(i){
                         # i <- 1
                         y <- tindexes_list[i]
                         idate <- names(y)
                         my_df <- sounding_indices_text2data_frame(list_element = y[1]) 
                         
                         stn_num <- my_df %>%
                           filter(parameter == "stn_num") %>% 
                           select(value) %>% 
                           `[[`(1) %>% 
                           as.integer()
                         
                         my_df %<>% dplyr::mutate(date = ymd_hms(idate)
                                                  ,id_prof = i
                                                  ,stn_num = stn_num) %>%
                           filter(!parameter %in% c("stn_num", "obs_time", "lat", "elev"))
                         
                         rm(i, y, idate)
                         return(my_df)
                       }) 
  rm(tindexes_list, tindex_rows, x) 
  # tidy df
  suppressWarnings(tindexes_df$value <- as.numeric(tindexes_df$value))
  tindexes_df <- tindexes_df %>% 
    spread(parameter, value) %>%
    select(-stn_id)
  
  return(tindexes_df)
} # end extract_profiles



####################################################
# Function to get sounding data for the entire month
####################################################
get_sounding_data <- function(idate  = as.Date("2010-10-16") # 62 soundings
                              ,stnm  = 83378
                              ,sleep = TRUE
                              ,nsec  = 10){
  
  # aguarda n segundos (para evitar sobrecarregar o site)
  if(sleep){
    Sys.sleep(time = sample(1:nsec, 1))
  }
  
  # wyoming_site from date
  wyoming_url <- wyoming_site(idate)
  
  # get sounding data for all month
  # in a data frame with 2 columns
  # value: sounding profile data and 
  # L1: headers
  x <- download_sounding(sounding_date_url = wyoming_url) 
  
  # data time from data
  dates <- date_time_from_sounding(x)
  
  # profiles dataframe
  profiles_d <- extract_profiles(x, dates)
  
  # thermodinamic indexes 
  indices_d <- extract_thermo_index(x, dates)
  
  
  return(list(profiles = profiles_d, indices = indices_d))
  
}# end get_sounding_data


# Funcao para criar nome a partir da saida de get_sounding_data
set_file_name <- function(xlist, type = "profile"){
  y_m <- unique(format(xlist$profiles$date, "%Y_%m"))
  site <- as.character(unique(xlist$indices$stn_num))
  return(paste0(y_m, "_",site,"_", ifelse(type!="profile", "index", type), ".csv"))
}

res <- get_sounding_data(idate = "2014-12-16", stnm = 83378)
head(res$profiles)
head(res$indices)
# escrita dos resultados
(out_filename1 <- set_file_name(res, type = "profile"))
(out_filename2 <- set_file_name(res, type = "index"))
write.csv(x = res$profiles, file = out_filename1, row.names = FALSE)
write.csv(x = res$indices, file = out_filename2, row.names = FALSE)

#inds <- res$indices; s <- select(inds, -id_prof, -stn_num) 
#timePlot(s, names(s)[-1], ylab = "thermo index")

# teste para uma sequência de datas
#dates <- seq(as.Date("2010-01-16"), as.Date("2015-10-31"), by = "month")

# looping nas datas para download de dados das radiossondagens do mês
# l <- plyr::ldply(1:nrow(d),
#                  #l <- plyr::ldply(1:3, 
#                  function(i) {
#                    cat(i, "\n")
#                    get_sounding(iyear = d[i, "y"]
#                                 ,imonth = d[i, "m"]
#                                 ,end_day = d[i, "ld"]
#                                 ,stnm = 83378)
#                  })
# # nome dos arquivos baixados
# l