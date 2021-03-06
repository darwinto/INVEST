#INVEST TEAM - Transfer Function Code
#PREDICT 412

setwd("C:/Users/a19602/Documents/INVEST")

#initial installs addon package
install.packages('quantmod')
install.packages('forecast')
install.packages('TSA')
insall.packages('zoo')

library('forecast')
library('quantmod')
library('TSA')
library('zoo')

#read in file
stock <- read.csv('UPL2013.csv')

#convert factor to date
stock$DATE <- as.Date(stock$DATE, format = "%m/%d/%Y")

#subset the first half of the year to create the models
stock.firsthalf.2013 <- stock[1:126,]

#Graphs current data
pdf(file = "First_Half_2013_plot.pdf", width = 11, height = 8.5)
plot(stock.firsthalf.2013$CLOSE)
dev.off()

#Log Transformation
stock.firsthalf.2013$log_close<-log(stock.firsthalf.2013$CLOSE)
stock.firsthalf.2013$log_nymex_ngas<-log(stock.firsthalf.2013$NYMEX_NGAS)
stock.firsthalf.2013$log_WTI <- log(stock.firsthalf.2013$WTI)

#plot Log transformations
pdf(file = "logs_plot.pdf", width = 11, height = 8.5)
plot(stock.firsthalf.2013$log_close)
plot(stock.firsthalf.2013$log_nymex_ngas)
plot(stock.firsthalf.2013$log_WTI)
dev.off()

#NGas indicator appears to move in a similar pattern as UPL, 
#but the WTI does not appear to be related

#difference the transfer functions
log_nymex_ngas.diff <- diff(stock.firsthalf.2013$log_nymex_ngas, differences=1)
log_WTI.diff <- diff(stock.firsthalf.2013$log_WTI, differences=1)
log_close.diff <- diff(stock.firsthalf.2013$log_close, differences=1)

#plot the differenced ts
pdf(file = "difference_plot.pdf", width = 11, height = 8.5)
plot(log_nymex_ngas.diff)
plot(log_WTI.diff)
plot(log_close.diff)
dev.off()
#differenced log plots appear ready for model scoring

#Arima model - to score the stock price and the transfer functions
arima_model <- auto.arima(as.ts(log_close.diff))
arima_model.ngas <- auto.arima(as.ts(log_nymex_ngas.diff))
arima_model.WTI <- auto.arima(as.ts(log_WTI.diff))

##ARIMAX CODE##
#nymex
arimax.upl.nymex <- arimax(log_close.diff, order=c(0,0,1), 
                           xtransf = log_nymex_ngas.diff, 
                           transfer=list(c(2,0)), method = 'ML')

#WTI
arimax.upl.WTI <- arimax(log_close.diff, order=c(0,0,1),
                         xtransf = log_WTI.diff, 
                         transfer=list(c(0,0)), method = 'ML') 


#Log Transformation to entire 2013 data frame
stock$log_close<-log(stock$CLOSE)
stock$log_nymex_ngas<-log(stock$NYMEX_NGAS)
stock$log_WTI <- log(stock$WTI)

#difference the transfer functions
log_nymex_ngas.diff.fullyear <- diff(stock$log_nymex_ngas, differences=1)
log_WTI.diff.fullyear <- diff(stock$log_WTI, differences=1)
log_close.diff.fullyear <- diff(stock$log_close, differences=1)

#create full 2013 data fame for rolling window
teststock <- data.frame(log_close.diff = c(log_close.diff.fullyear),
                       log_nymex_ngas.diff = c(log_nymex_ngas.diff.fullyear),
                       log_WTI.diff = c(log_WTI.diff.fullyear))



