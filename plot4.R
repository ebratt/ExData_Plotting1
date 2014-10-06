## subject: Coursera exdata-007 project 1
## title: "plot4.R"
## author: "Eric Bratt"
## date: "Monday, October 6,2014"
## output: R script
################################################################################
## clear out the environment
rm(list=ls())

################################################################################
## function that checks to see if a package is installed and,if not,installs it
## portions of this code came from http://stackoverflow.com/questions/9341635/how-can-i-check-for-installed-r-packages-before-running-install-packages
load_package <- function(x) {
  if (x %in% rownames(installed.packages())) { print("package already installed...") }
  else { install.packages(x) }
}

################################################################################
# install necessary packages
load_package("lubridate") # for easy date-handling

# load necessary libraries
library(lubridate)

################################################################################
## UTILITY FUNCTIONS
## function that reads a file and returns a data.frame
read_file <- function(x) {
  result <- read.table(x,header=T,sep = ";", na.strings=c("?",""), 
                       stringsAsFactors=F, dec = ".", 
                       colClasses =c("character","character","numeric","numeric",
                                     "numeric","numeric","numeric","numeric",
                                     "numeric"))
  return(result)
}

## function that concatenates strings (useful for directory paths)
concat <- function(x1,x2) {
  result <- paste(x1,x2,sep="")
  return(result)
}

################################################################################
## define some global variables
DATA_DIR      <- "./data"
DATA_FILE     <- concat(DATA_DIR,"/data.zip")
FILE_URL      <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
RAW_DATA_FILE <- concat(DATA_DIR,"/household_power_consumption.txt")

################################################################################
# ensure the local data directory exists
if (!file.exists(DATA_DIR)) { dir.create(DATA_DIR) }
# log the date the archive was downloaded
dateDownloaded <- now()
# download the archive file
if (.Platform$OS.type == "unix") {
  download.file(FILE_URL,destfile = DATA_FILE,method="curl")
} else {
  download.file(FILE_URL,destfile = DATA_FILE)
}
# unzip the archive file to the data directory
unzip(DATA_FILE,exdir = DATA_DIR)

################################################################################
# step 1. Read the file into data.                                             #
################################################################################
file_size <- file.info(RAW_DATA_FILE)$size / 1048576 # file size in Mb's
raw_data   <- read_file(RAW_DATA_FILE)
labels <- c("date", "time", "globalActivePower", 
            "globalReactivePower", "voltage", 
            "glboalIntensity", "subMetering1","subMetering2",
            "subMetering3")
names(raw_data) <- labels
# add a column for date-time
raw_data$dateTime <- strptime(paste(raw_data[,1], raw_data[,2],sep=" "), format="%d/%m/%Y %H:%M:%S")

# only want data from dates 2007-02-01 and 2007-02-02
data <- raw_data[raw_data$date == "1/2/2007" | raw_data$date == "2/2/2007",]

################################################################################
# step 2. Make Plots.                                                          #
################################################################################
png(filename="plot4.png", width=480, height=480)
par(mfcol=c(2,2))
# top-left
plot(data$dateTime, data$globalActivePower, type="l", xlab="",
     ylab="Global Active Power")
# bottom-left
plot(data$dateTime, data$subMetering1, type="l", xlab="",
     ylab="Energy sub metering")
lines(data$dateTime, data$subMetering2, col="red")
lines(data$dateTime, data$subMetering3, col="blue")
legend("topright", lty=c(1,1,1), col=c("black","red","blue"),
       bty = "n", 
       legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))
# top-right
plot(data$dateTime, data$voltage, type="l", xlab="datetime",
     ylab="Voltage")
# bottom-right
plot(data$dateTime, data$globalReactivePower, type="l", xlab="datetime",
     ylab="Glboal_reactive_power")
dev.off()