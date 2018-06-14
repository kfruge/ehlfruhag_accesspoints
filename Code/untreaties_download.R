# Author: Kimberly R. Frugé 
# File: untreaites_download.R 
# Date: 14 June 2018 
# Purpose- Download - this file downloads the data from the untreaties repository by Zachary M. Jones (https://github.com/zmjones/untreaties). # Results: This file creates untreaties.csv 


setwd("~/Dropbox/ehlfruhag_accesspoints/Data")
library(countrycode); library(assertthat);library(RCurl)

#--------------------------------------------------------------------------------------------------------------------------------------------------#
### Read in "untreaties" repository necessary files ### 

#The untreaties is using an older version of stringr so make sure to have that installed, otherwise will throw an error for regex 
#install_version("stringr", version = "0.6.1", repos = "http://cran.us.r-project.org")

#script for utilities.R  
script <- getURL("https://raw.githubusercontent.com/opetchey/RREEBES/Beninca_developmehttps://raw.githubusercontent.com/zmjones/untreaties/master/utilities.R", ssl.verifypeer = FALSE)

#source script 
eval(parse(text = script))

#download treaties of interest (4-3,4-4,4-9) list (https://github.com/zmjones/untreaties/blob/master/index.csv) 
treatycescr<- read.csv(text=getURL("https://raw.githubusercontent.com/zmjones/untreaties/master/treaties/4-3.csv")) 
treatyccpr<- read.csv(text=getURL("https://raw.githubusercontent.com/zmjones/untreaties/master/treaties/4-4.csv")) 
treatycat<- read.csv(text=getURL("https://raw.githubusercontent.com/zmjones/untreaties/master/treaties/4-9.csv")) 

#create treaties folder if it doesn't exist 
if(!dir.exists("./treaties"))
     dir.create("./treaties")
#save to treaties folder so that utilities.R can read files 
write.csv(treatycescr, "./treaties/4-3.csv", row.names=FALSE) 
write.csv(treatyccpr, "./treaties/4-4.csv", row.names=FALSE) 
write.csv(treatycat, "./treaties/4-9.csv", row.names=FALSE) 


#load data 
cescr<- loadData(chap="4", treaty="3", expand=TRUE, panel=TRUE, syear="1945", eyear="2013")
ccpr<- loadData(chap="4", treaty="4", expand=TRUE, panel=TRUE, syear="1945", eyear="2013")
cat <- loadData(chap="4", treaty="9", expand=TRUE, panel=TRUE, syear="1945", eyear="2013")


#--------------------------------------------------------------------------------------------------------------------------------------------------#
### Create ratify variable ### 

colnames(cescr) <- c("participant", "year", "signature", "ratification", "accession", "succession") 
cescr$cescr_ratify <- ifelse(cescr$ratification == 1 | cescr$accession == 1 | cescr$succession == 1, 1, 0)
cescr<- cescr[, c("participant", "year", "cescr_ratify")]


colnames(ccpr) <- c("participant", "year", "signature", "ratification", "accession", "succession")
ccpr$ccpr_ratify <- ifelse(ccpr$ratification == 1 | ccpr$accession == 1 | ccpr$succession == 1, 1, 0)
ccpr<- ccpr[, c("participant", "year", "ccpr_ratify")]


colnames(cat) <- c("participant", "year", "signature", "ratification", "accession", "succession") 
cat$cat_ratify <- ifelse(cat$ratification == 1 | cat$accession == 1 | cat$succession == 1, 1, 0)
cat<- cat[, c("participant", "year", "cat_ratify")]


#--------------------------------------------------------------------------------------------------------------------------------------------------#
### Merge ### 

dat<- merge(cescr, ccpr, all.x=TRUE, all.y=TRUE, by=c("participant", "year"))
dat<- merge(dat, cat, all.x=TRUE, all.y=TRUE, by=c("participant", "year"))


#--------------------------------------------------------------------------------------------------------------------------------------------------#
### Fill in blanks ### 

dat$cescr_ratify[is.na(dat$cescr_ratify)] <- 0 
dat$ccpr_ratify[is.na(dat$ccpr_ratify)] <- 0 
dat$cat_ratify[is.na(dat$cat_ratify)] <- 0

#--------------------------------------------------------------------------------------------------------------------------------------------------#
### Set Country Codes ### 

dat <- dat[!(dat$participant %in% c("Serbia", "State of Palestine")), ]
dat$ccode <- countrycode(dat$participant, "country.name", "cown")


assert_that(!anyDuplicated(dat[, c("ccode", "year")])) #Make sure there are no duplicates 

#--------------------------------------------------------------------------------------------------------------------------------------------------#
### Save Data ### 

write.csv(dat, "./untreaties.csv", row.names=FALSE) 
