# CODE BOOK for run_analysis.R
##   Getting and Cleaning Data - Class Assignment
##   Author: pmarkt

### Background information

The R code, run_analysis.R, demonstrates the ability to collect, work with, and clean a data set.The code analyzes data collected from Samsung Galaxy smartphone accelerometers. 

The data was obtained from the following web link:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
A full description of the data is available at the site where the data was initially obtained:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The code accomplishes the following:
- Merges the training and test data sets to create one data set
- Extracts only the measurement on the mean and standard deviation for each measurement
- Uses descriptive activity names to name the activities in the data set
- Appropriately labels the data set with descriptive variable names
- Creates a second independent tidy dataset from the above, which contains the average of each variable for each activity and each subject.


### Required R libraries

The code requires the use of the dplyr function, which was developed by Hadley Wickham, an Assistant Professor of Statistics at Rice University. For more information on Mr. Wickham, see his web site "http://had.co.nz/"
The dplyr function facilitates easier analysis using tabular data tools.
The library is loaded using the following code:

	 library(dplyr)

### Downloading and preparing files

This script assumes that **the zipped file of Samsung data has already been downloaded into your working directory.** The zipped file name is "getdata-projectfiles-UCI HAR Dataset.zip" You should be sure to check that this zipped file exists in your working directory before running the code in run_analysis.R.

I created a sub_directory to contain the various directories and files obtained from the zip file, after first checking to see if the directory already exists
	
	 if (!file.exists("data"))   {
	 dir.create("data")
         }
I then unzip the file into the "data" directory

	 unzip ("./getdata-projectfiles-UCI HAR Dataset.zip",exdir = "./data")

and read in the desired datasets. I determined that I needed the following 6 files to create a full set of data for each of the training and test datasets.

	 test_data_X <- read.table("./data/UCI HAR Dataset/test/X_test.txt",)              
	 test_data_Y <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
	 subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
	 train_data_X <- read.table("./data/UCI HAR Dataset/train/X_train.txt")     
   	 train_data_Y <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
  	 subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

The next step was to merge the subject files with the X and Y files for each of the 2 datasets.This creates a row of data for each subject. It required me to change some of the variable names, in order to eliminate duplicate names in the resulting merged dataset.I changed column names in the "subject" files and "Y" files as follows:
rename "V1" to "subject" in the subject files (both train and test)

	 names(subject_test)[names(subject_test)=="V1"] <- "subject"         
	 names(subject_train)[names(subject_train)=="V1"] <- "subject" 

rename "V1" to "activity_label" in the Y files

	 names(train_data_Y)[names(train_data_Y)=="V1"] <- "activity_label"
	 names(test_data_Y)[names(test_data_Y)=="V1"] <- "activity_label"

I then merged the subject, X and Y data (using cbind) for each dataset (test,train)

	 test_dataset  <- cbind(subject_test,test_data_Y,test_data_X)
	 train_dataset <- cbind(subject_train,train_data_Y,train_data_X)

## PART 1 
of the assignment asked us to merge (concatenate) the training and the test sets to create one data set

	 combined_dataset <- rbind(test_dataset,train_dataset)
	 combined_table <- tbl_df(combined_dataset)

## PART 4
of the assignment asked us to appropriately label the data set with descriptive variable names. **I chose to do this step out of order**, in order to facilitate an easy way to choose just the columns containing the words "mean" or "std" required in Step 2.The column names are descriptions of the various readings in the data, contained in the file features.txt. I read the features into a table called "feature_names".I used the argument "stringsAsFactors=F so that the resulting feature names would be characters, rather than factors.
 	 feature_names <- tbl_df(read.table("./data/UCI HAR Dataset/features.txt",stringsAsFactors=F))           

I then created the column names for the combined_table from the feature names. I used the "make.unique" option to create unique column labels where duplicate names existed. It appeared that the column names were duplicates, but the data in the columns was not duplicated. This required that the data be kept, but given a unique column name. In the end, we end up deleting these columns, but the duplicate names can still cause issues.

	 colnames(combined_table) <- make.unique(c("subject","activity_label",paste(feature_names$V2)))

While working with the data, I receiving warning messages that some of the longer column names had to be truncated. Initially, I thought that these trucated names were causing the duplicate column names, so I shortened some of the longer column names, all of which included the phrase "bandsEnergy". I substituted "BE" for "bandsEnergy" in these column names. I eventually realized that this wasn't necessary, but I discovered the powerful "gsub" function that will be good to know in future programming assignments.

	  colnames(combined_table) <- gsub("bandsEnergy", "BE", colnames(combined_table)) 

## PART 3 
of the assignment asked us to Use descriptive activity names to name the activities in the data set, for example, instead of an activity label of "1" or "5", use the associated activity name like "LAYING" or "SITTING". I read in the activity labels and activity names from the activity_labels.txt file. It also required a change of variable names, to prevent duplicate column names in the data after it was merged. I changed the column names and merged the combined_table with the activity_labels, putting the result into a new table "data3". (Again using "stringsAsFactors=F" when reading the activity labels, so they would be characters rather than factors.

  	  activity_labels <- tbl_df(read.table("./data/UCI HAR Dataset/activity_labels.txt",stringsAsFactors=F))
  	  names(activity_labels)[names(activity_labels)=="V1"] <- "activity_label"
  	  names(activity_labels)[names(activity_labels)=="V2"] <- "activity"
 	  data3 <- merge(combined_table,activity_labels,by="activity_label")

## PART 2 
of the assignment asked us to extract only the measurements on the mean and standard deviation for each measurement. I opted to use the "contains" option to select all columns where the word "mean" or "std" existed in the column name. Although I did not see the use for the "MeanFreq" columns, I thought this was a small price to pay for such a quick and easy way to select the desired columns. (I later learned that I could have looked for names that contained the "mean(" or "std(" string to get just the columns I wanted.)

    	  new_data <- tbl_df(select(data3,subject,activity,contains("mean"),contains("std")))

## PART 5 
of the assignment asked us to create a second, independent tidy data set with the average of each variable for each activity and each subject. I used the group_by and summarise_each functions to accomplish this.
    tidy_data <- summarise_each(group_by(new_data,subject,activity),funs(mean))  
I tidied up the column names by removing the "()" characters and added a prefix os "Mean_of_" to each of the column names in the final tidy dataset. I then wrote the resulting table "tidy_data" to a file using the row.names=F option, as requested in the instructions.

	  colnames(tidy_data) <- gsub("()", "", colnames(tidy_data),fixed=TRUE) 
	  colnames(tidy_data)[3:88] <- paste( "Mean_of", colnames(tidy_data)[3:88],sep="_")
	  write.table(tidy_data,file="./tidy_data.txt",row.names=FALSE)

There are additional efficiencies that could be introduced into this program including the following:
- I kept renaming the data table (data3,combined_table,new_data,tidy_data....) which probably used a lot of unnecessary space. I could have made the changes in the original dataset.
- I could have used more of the functionality in dplyr, rather than using the summarize and group_by commands on their own
- I could have done more chaining of commands

Overall I found the assignment to be a valuable learning tool for learning many new concepts in R. There are a variety of ways to accomplish things in R, and I suspect that my style in writing R will improve over time and will product more efficient code. I plan to, in the future, use some of the system metrics to measure the efficiency of this code, then make improvements to it.