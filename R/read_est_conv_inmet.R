
## pacotes necessarios para funcionanamento da funcao
# install.packages("nomedopacote")
require(openair)
require(descr)
require(reshape2)
require(doBy)

###############################################################################
## Função para ler dados das estações convencionais do INMET
###############################################################################
read_est_conv_inmet <- function(filename = "82042.txt", 
                      dup.first = T,
                      limiar = 0.0,
                      selVars = c("date",  "site", "prec", "tar", "tw",
                                  "tmax", "tmin", "patm", "wd", 
                                  "n", "cc", "evap", "ur", "ws")
                      ){
  
  # filename <- "/home/hidrometeorologista/UFSM/orientacoes/iniciacaoCientifica/andre_carolina/desagragacaoTemperatura/dados/CONV_INMET"
  ## row with header
  rowheader <- readLines(filename)
  #rowheader <- toUTF8(rowheader)
  rowheader <- grep("Data;Hora;", rowheader)
  
  ## extraindo cabecalho(h) e corrigindo se necessario
  tmp <- readLines(filename)
  h <- grep("Data;Hora;",tmp, value = T)
  
  ## caso 1: nomes das vars (VelocidadeVento e Insolacao) grudados
   h2 <- gsub("VelocidadeVentoInsolacao;", "VelocidadeVento;Insolacao;", h)
  ## caso2 : dados horarios
  # h <- gsub("VelocidadeVentoNebulosidade;", "VelocidadeVento;Nebulosidade", h)
  
  ## transformando h de string para vetor (hvec)
  hvec <- unlist(strsplit(h2, ";"))
  
  ## correspondencia entre variveis originais e novos nomes
  ## variaveis horarias do arquivo bruto baixado do inmet
  #    Estacao;Data;Hora;
  #    Precipitacao;TempBulboSeco;TempBulboUmido;TempMaxima;TempMinima;UmidadeRelativa;
  #    PressaoAtmEstacao;PressaoAtmMar;DirecaoVento;VelocidadeVentoInsolacao;Nebulosidade;
  #    Evaporacao Piche;Temp Comp Media;Umidade Relativa Media;Velocidade do Vento Media;
  ## novos nomes para variaveis horarias
  vnames <- c("codigo", "Data","Hora",
              "prec", "tar", "tw", "tmax", "tmin", "urx", 
              "patm", "pnmm", "wd", "wsx", "n", "cc", "evap", "tcomp", "ur", "ws")
  
  varnames <-  recodeVar(as.character(hvec),
                         src = as.list(as.character(hvec)), 
                         tgt = as.list(vnames))
   
  
  ## read da1ta (pulando linhas que nao interessam)
  x <- read.csv2(filename, 
                 header = F, 
                 skip = rowheader,
                 stringsAsFactors = F,
                 na.strings = "")
 
  ## seleciona somente o numero de colunas igual ao do cabecalho
  x <- x[, 1:length(hvec)]
  ## elimina linha com </pre>
  x <- x[-grep("pre",x[,1]),]

  ## stop if there is conflict between ncol(x) and length(hvec)
  if(ncol(x) != length(hvec)) {
    print(head(x))
    cat("ncol(x) = ", ncol(x), "\n", 
        "hvec = ", hvec, "\n", "\n")
    
    stop("conflito entre o num. colunas dos dados e o num. de variaveis")
  } else {
    names(x) <- varnames
  }# end if

  ## converte para numeric os dados que aparecem como <NA>
  selCols <- which(!names(x) %in% c("Estacao","Data", "Hora"))
    x[,selCols] <- apply(x[,selCols],2, as.numeric)
    
    
  ## coversao de datas
  x$Hora <- recodeVar(as.character(x$Hora),
                      src= as.list(c("1800","0","1200")), 
                      tgt=as.list(c("18:00","00:00","12:00")))
  ## gerando coluna date no formato de variavel temporal para uso do pacote openair
  x <- transform(x, date = as.POSIXct(paste(as.Date(x$Data,format="%d/%m/%Y"),
                                            x$Hora,
                                            sep = " "), tz = "GMT"),
                    Data = NULL,
                    Hora = NULL)
  
  x <- data.frame(date = x[,"date"], subset(x, sel =-date))
   

  ## Dados duplicados
  ## se o parametro dup.first = T, considera-se somente o primeiro elemento da 
  ## duplicacao e vice-versa
  ## data frame tmp com dados unicos
  if(dup.first)  xu <- x[!duplicated(x[, "date"]), ] else 
    xu <- x[!duplicated(x[, "date"], fromLast=T), ]
  
  x <- xu; rm(xu)
  
  cat("dados em horário UTC!", "\n")
  
  return(x)
}## end function readInmet

library(plyr)
fl <- list.files("data/", full.names = TRUE)
a <- ldply(fl, read_est_conv_inmet)
#a <- read_est_conv_inmet(filename =  "data/83897.txt")

