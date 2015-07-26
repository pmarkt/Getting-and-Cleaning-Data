## Getting and Cleaning Data - Programming Assignment 3
## created by Pam Markt

The R code in this repository, run_analysis.R, demonstrates the ability to collect, work with, and clean a data set.The code analyzes data collected from the Samsung Galaxy smartphone. The data was obtained from the following web link:
https://d396qusza40orc.cloudfront.net/getdata-projectfiles-UCI HAR Dataset.zip" 
The attached R code assumes that the downloaded zipped file resides in your working directory. The code handles the unzipping of the file to give you access to the individual files needed to run the analysis.

The code accomplishes the following:
- Merges the training and test sets to create one data set
- Extracts only the measurement on the mean and standard deviation for each measurement
- Uses descriptive activity names to name the activities in the data set
- Appropriately labels the data set with descriptive variable names
- Creates a second independent tidy dataset from the above, which contains the average of each variable for each activity and each subject.
