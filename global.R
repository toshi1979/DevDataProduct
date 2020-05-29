preProcess <- function (){
# Download csv file from Japan Meteorological Agency public website.
# Conduct pre processing and return entire tidy data set for later analysis
        
        library(lubridate)
        library(dplyr)
        
        for (i in 1:19){  # from year 2001 to 2019 data is available as of 2020 May. note that this is hardcoded
                h_url <- "https://www.data.jma.go.jp/fcd/yoho/typhoon/position_table/table20"
                fname <- paste0(sprintf("%02d",i),".csv")
                tmpDF <- read.csv(paste0(h_url,fname), header = FALSE, skip=1) # skip reading first rows include Japanese as shinny.io deploy error occur
                
                # Assign english column name since original one is all Japanese. 
                colnames(tmpDF) <- c("year","month","day","time","id","name","level",
                                     "lat","lng","centerPressure","maxWindSpeed",
                                     "majorAxis50Direction","majorAxis50","minerAxis50",
                                     "majorAxis30Direction","majorAxis30","minerAxis30",
                                     "land")
                # original timestamp are "UTC" time. explicitly assign UTC time zone.
                tmpDF[,"timeUTC"] <- as.POSIXct(with(tmpDF,
                                                     as.POSIXlt(strptime(paste(year,month,day,time),format = "%Y%m%d%H"))),tz="UTC") 
                
                tmpDF[,"yearJST"] <- year(as.POSIXlt(tmpDF$timeUTC , tz="Japan"))   # JST 
                tmpDF[,"monthJST"] <- month(as.POSIXlt(tmpDF$timeUTC , tz="Japan"))   # JST as
                
                if (i == 1) { 
                        df <- tmpDF
                } else {
                        df <- rbind(df,tmpDF)  # append rows
                }
        }
        return(select(df,timeUTC,yearJST,monthJST,id,name,level,lat,lng,majorAxis30,centerPressure,land))
}
df <- preProcess()