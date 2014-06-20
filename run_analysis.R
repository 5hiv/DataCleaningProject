analysis <- function()
{
  library(data.table)
  
  x_train <- read.table ("./train/X_train.txt",sep="")
  y_train <- read.table ("./train/y_train.txt",sep="",colClasses=c("character"))
  subject_train <- read.table ("./train/subject_train.txt",sep="",colClasses=c("character"))
  
  
  x_test <- read.table ("./test/X_test.txt",sep="")
  y_test <- read.table ("./test/y_test.txt",sep="",colClasses=c("character"))
  subject_test <- read.table ("./test/subject_test.txt",sep="",colClasses=c("character"))
  
  
  # Read the column names from features file
  
  labels = read.table("features.txt")
  
  
  # Assign col names to all the data read so far
  
  colnames(subject_train) = "SubjectId"
  colnames(subject_test)  = "SubjectId"
  
  colnames(y_train) = "ActivityId"
  colnames(y_test)  = "ActivityId"
  
  colnames(x_test)  = labels[,2]
  colnames(x_train) = labels[,2]
  
  
  # Concatenate the subject, Activity and measurement datas for both train and test
  
  training_data = cbind(subject_train,y_train,x_train)
  test_data     = cbind(subject_test ,y_test ,x_test)
  
  # Merge the training and test data 
  
  merge_data = rbind(training_data,test_data)
  
  # Read the mean and median columns from the labels list
  
  meanColumns = as.data.frame(labels[grepl("*mean*",labels[,2]),2])
  stdColumns  = as.data.frame(labels[grepl("*std*",labels[,2]),2])
  
  # In order to rbind the above list, we need to have a common column name, so name one for both
  colnames(meanColumns) = "ColumnNames"
  colnames(stdColumns)  = "ColumnNames"
  
  
  # Concatenate the above column list for reading
  
  columns = rbind(meanColumns,stdColumns)
  
  temp= as.matrix(rbind("SubjectId","ActivityId"))
  colnames(temp) = "ColumnNames"
  
  columnNames= rbind(temp,columns)
  
  # Extracts only the measurements on the mean and standard deviation for each measurement.
  extractData = merge_data[,columnNames[,1]]  
  # Read the Activity names
  
  activitiesLabels = read.table("activity_labels.txt",colClasses=c("character"))
  
  # Replace the activity Id with a activity name thats read from the above file read
  
  for ( i in 1:length(activitiesLabels[,1])) 
  {
    extractData$ActivityId = gsub(i,activitiesLabels[i,]$V2,extractData$ActivityId)
    #replace(extractData$ActivityId,extractData$ActivityId==i,activitiesLabels[i,]$V2)
    #extractData[extractData$ActivityId==i,]$ActivityId=activitiesLabels[i,]$V2
  }
  
  # Convert the data frame into a data table
  extractData.table = data.table(extractData)
  
  # Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
  
  data = extractData.table[, lapply(.SD,mean), by=eval(colnames(extractData.table)[1:2])]
  
  # Write the tidy data into a file in CSV format
  write.table(data, file = "tidayData.txt",sep = "\t",row.names=FALSE)
}