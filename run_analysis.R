# Getting and Cleaning Data - Class Assignment
# 
# Author: pmarkt
###############################################################################

## Load dplyr library
library(dplyr)

## This script assumes that the zipped file of Samsung data exists in your working directory

## Create a sub directory to contain the various directories and files from the zip file
if (!file.exists("data"))   {
    dir.create("data")
}
## Unzip the file into the "data" directory
unzip ("./getdata-projectfiles-UCI HAR Dataset.zip",exdir = "./data")


## READ AND PREPARE FILES 

  ## Read in the datasets
    test_data_X <- read.table("./data/UCI HAR Dataset/test/X_test.txt",)              # read in test datasets
    test_data_Y <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
    subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
    train_data_X <- read.table("./data/UCI HAR Dataset/train/X_train.txt")             # read in training datasets
    train_data_Y <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
    subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

  ## Change column names in the "subject" files and "Y" files, 
  ##     to facilitate the merge of the data with the "X" files
  ##     (this prevents duplicate column names in the merged data)

  ## rename "V1" to "subject" in the subject files (both train and test)
    names(subject_test)[names(subject_test)=="V1"] <- "subject"         
    names(subject_train)[names(subject_train)=="V1"] <- "subject" 

  ## rename "V1" to "activity_label" in the 
    names(train_data_Y)[names(train_data_Y)=="V1"] <- "activity_label"
    names(test_data_Y)[names(test_data_Y)=="V1"] <- "activity_label"

  ## Merge the X and Y data for each dataset (test,train)
    test_dataset  <- cbind(subject_test,test_data_Y,test_data_X)
    train_dataset <- cbind(subject_train,train_data_Y,train_data_X)

## PART 1 - Merge (concatenate) the training and the test sets to create one data set
combined_dataset <- rbind(test_dataset,train_dataset)
combined_table <- tbl_df(combined_dataset)

## PART 4 - Appropriately label the data set with descriptive variable names
##          (done out of order, to facilitate easy choosing of "mean" and "std" columns later)
  ## Read in feature names
    feature_names <- tbl_df(read.table("./data/UCI HAR Dataset/features.txt",stringsAsFactors=F))           

  ## Create the column names from the feature names. I used the
  ##   "make.unique" option to create unique column labels where duplicate names exist
    colnames(combined_table) <- make.unique(c("subject","activity_label",paste(feature_names$V2)))

  ## I substituted "BE" for "bandsEnergy" in some of the longer column names,
  ##   to prevent a warning message about truncation of these names later
    colnames(combined_table) <- gsub("bandsEnergy", "BE", colnames(combined_table)) 

## PART 3 - Use descriptive activity names to name the activities in the data set
    activity_labels <- tbl_df(read.table("./data/UCI HAR Dataset/activity_labels.txt",stringsAsFactors=F))
  ## Change column names in the "activity labels" file, to facilitate a merge
    names(activity_labels)[names(activity_labels)=="V1"] <- "activity_label"
    names(activity_labels)[names(activity_labels)=="V2"] <- "activity"
    data3 <- merge(combined_table,activity_labels,by="activity_label")

## PART 2 - Extract only the measurements on the mean and standard deviation for each measurement
    new_data <- tbl_df(select(data3,subject,activity,contains("mean"),contains("std")))

## PART 5 - From the data set, create a second, independent tidy data set with 
##          the average of each variable for each activity and each subject
    tidy_data <- summarise_each(group_by(new_data,subject,activity),funs(mean))  
  ## tidied up the column names by removing the "()" characters
    colnames(tidy_data) <- gsub("()", "", colnames(tidy_data),fixed=TRUE) 
  ## furhter cleaned up the column names to indicate that they are Means of the different statistics
    colnames(tidy_data)[3:88] <- paste( "Mean_of", colnames(tidy_data)[3:88],sep="_")
  ## write the resulting tidy dataset to a file using "row.names=FALSE"
    write.table(tidy_data,file="./tidy_data.txt",row.names=FALSE)


