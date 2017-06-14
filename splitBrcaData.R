library(data.table)
test = read.csv("/home/shared/data/metabric_split/test_clinical.txt",sep="\t",stringsAsFactors = F)
training = read.csv("/home/shared/data/metabric_split/training_clinical.txt",sep="\t",stringsAsFactors = F)
validation = read.csv("/home/shared/data/metabric_split/validation_clinical.txt",sep="\t",stringsAsFactors = F)

splitByCol <- function(dataset, CNA) {
    samples = dataset$METABRIC_ID
    samples = c("Hugo_Symbol","Entrez_Gene_Id",samples)
    overlap = colnames(CNA)[colnames(CNA) %in% samples]
    newCNA = CNA[,overlap,with=F]
}
splitByRow <- function(dataset, unsplitData, column) {
    samples = dataset$METABRIC_ID
    unsplitSamples = unsplitData[,column,with=F]
    keepRows = unlist(unsplitSamples) %in% samples
    newData = unsplitData[keepRows,]
}

CNA = fread("/home/shared/data/brca_metabric/data_CNA.txt",stringsAsFactors = F)

testCNA = splitByCol(test, CNA)
trainingCNA = splitByCol(training, CNA)
validationCNA = splitByCol(validation, CNA)

write.table(testCNA, "/home/shared/data/metabric_split/test_CNA.txt", sep="\t", quote = F,row.names = F)
write.table(trainingCNA, "/home/shared/data/metabric_split/training_CNA.txt", sep="\t", quote = F,row.names = F)
write.table(validationCNA, "/home/shared/data/metabric_split/validation_CNA.txt", sep="\t", quote = F,row.names = F)

mutation = fread("/home/shared/data/brca_metabric/data_mutations_extended.txt",stringsAsFactors = F)

testMAF = splitByRow(test, mutation, "Tumor_Sample_Barcode")
trainingMAF = splitByRow(training, mutation, "Tumor_Sample_Barcode")
validationMAF = splitByRow(validation, mutation, "Tumor_Sample_Barcode")

write.table(testMAF, "/home/shared/data/metabric_split/test_MAF.txt", sep="\t", quote = F,row.names = F)
write.table(trainingMAF, "/home/shared/data/metabric_split/training_MAF.txt", sep="\t", quote = F,row.names = F)
write.table(validationMAF, "/home/shared/data/metabric_split/validation_MAF.txt", sep="\t", quote = F,row.names = F)

expression = fread("/home/shared/data/brca_metabric/data_expression.txt",stringsAsFactors = F)

testEXP = splitByCol(test, expression)
trainingEXP = splitByCol(training, expression)
validationEXP = splitByCol(validation, expression)

write.table(testEXP, "/home/shared/data/metabric_split/test_expression.txt", sep="\t", quote = F,row.names = F)
write.table(trainingEXP, "/home/shared/data/metabric_split/training_expression.txt", sep="\t", quote = F,row.names = F)
write.table(validationEXP, "/home/shared/data/metabric_split/validation_expression.txt", sep="\t", quote = F,row.names = F)



#### COMEBINE

train_clin = read.csv("/home/shared/data/metabric_split/training_clinical.txt",sep="\t")
test_clin = read.csv("/home/shared/data/metabric_split/test_clinical.txt",sep="\t")
train_clin$split_group = "training"
test_clin$split_group = "test"

activity_clinical = rbind(train_clin, test_clin)
write.table(activity_clinical,"/home/shared/data/metabric_split/activity_clinical.txt", sep="\t", row.names=F, quote=F)


training_exp = fread("/home/shared/data/metabric_split/training_expression.txt")
test_exp = fread("/home/shared/data/metabric_split/test_expression.txt")
test_exp$Entrez_Gene_Id <- NULL
activity_expression = merge(training_exp, test_exp,by = "Hugo_Symbol",all = T)
write.table(activity_expression,"/home/shared/data/metabric_split/activity_expression.txt", sep="\t", row.names=F, quote=F)

validation_clinical = read.csv("/home/shared/data/metabric_split/validation_clinical.txt",sep="\t")
validation_clinical$last_follow_up_status <- NULL
validation_clinical$T <- NULL
validation_clinical$survival_5y <- NULL
write.table(validation_clinical,"/home/shared/data/metabric_split/challenge_clinical.txt", sep="\t", row.names=F, quote=F)

