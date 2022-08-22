
# Load packages 
x <- c("data.table", "dplyr", "tidyr", "stringr")
lapply(x, require, character.only=TRUE)

# Download zipped file and extract
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI HAR Dataset.zip"
download.file(url, destfile = "C:\\Users\\tsuim\\Documents\\R\\JHU Data Course\\Module 3\\Project\\dataset.zip")
unzip_this <- "C:\\Users\\tsuim\\Documents\\R\\JHU Data Course\\Module 3\\Project\\dataset.zip"
unzip(unzip_this, exdir = "C:\\Users\\tsuim\\Documents\\R\\JHU Data Course\\Module 3\\Project")

setwd("C:\\Users\\tsuim\\Documents\\R\\JHU Data Course\\Module 3\\Project\\UCI HAR Dataset")

# Read features/variables 
variable_names<- read.delim("features.txt", header = FALSE)
variable_names <- str_split_fixed(variable_names$V1, " ", 2)
variable_names <- variable_names[,2]

# Read activity label 
activity_names<- read.delim("activity_labels.txt", header = FALSE)

# Read activity labels for train and test (Y_)
train_label <- lapply("train\\y_train.txt", read.table, sep="", header=FALSE)
train_label = train_label[[1]] # Brackets help convert list above to df

test_label <- lapply("test\\y_test.txt", read.table, sep="", header=FALSE)
test_label = test_label[[1]]

# Read subject files for train and test ()
train_subject <- lapply("train\\subject_train.txt", read.table, sep="", header=FALSE)
train_subject = train_subject[[1]]

test_subject <- lapply("test\\subject_test.txt", read.table, sep="", header=FALSE)
test_subject = test_subject[[1]]

# Read train and test measures (X_)
train_data <- lapply("train\\X_train.txt", read.table, sep="", header=FALSE)
train_data = train_data[[1]]

test_data <- lapply("test\\X_test.txt", read.table, sep="", header=FALSE)
test_data = test_data[[1]]

# Merge activity labels, subject, and data for training and test data
activity_labels <- rbind(train_label, test_label) # Used rbind because train and test data have the same number of cols
subject_id <- rbind(train_subject, test_subject)
data <- rbind(train_data, test_data)

# Add column names to subject, activity, and data 
colnames(subject_id) <- "Subject"
colnames(activity_labels) <- "Activity"
colnames(data) <- variable_names

# Extract columns from data df containing mean and standard deviation
data <- data[grepl("mean|std", colnames(data))]

# Merge subject id, activity label, and data 
final_df <- cbind(subject_id, activity_labels, data)

# Provide descriptive info for activity labels 
final_df$Activity <- gsub('1', 'WALKING',
                          gsub('2', 'WALKING_UPSTAIRS',
                                gsub('3', 'WALKING_DOWNSTAIRS',
                                      gsub('4', 'SITTING',
                                            gsub('5', 'STANDING',
                                                 gsub('6', 'LAYING', final_df$Subject))))))

# Provide descriptive info for feature labels 
names(final_df) <- gsub('Acc', 'Accelerometer',
                        gsub('Gyro', 'Gyroscope',
                             gsub('^t', 'time',
                                  gsub('^f', 'frequency',
                                       gsub('mag', 'magnitude', names(final_df))))))

# Average of each variable for each activity and each subject. Use dplyr to summarize and group all variables.
averages <- final_df %>% 
  group_by(Subject, Activity) %>% 
  summarise_all(list(mean))

# Export tidy datasets as csv
write.csv(final_df, "FinalData.csv", row.names = FALSE)
write.csv(averages, "Averages.csv", row.names = FALSE)
