
library(data.table)
test = read.csv("/home/shared/data/metabric_split/test_clinical.txt",sep="\t",stringsAsFactors = F)
training = read.csv("/home/shared/data/metabric_split/training_clinical.txt",sep="\t",stringsAsFactors = F)
validation = read.csv("/home/shared/data/metabric_split/validation_clinical.txt",sep="\t",stringsAsFactors = F)

CNA = fread("/home/shared/data/brca_metabric/data_CNA.txt",stringsAsFactors = F)

splitCNA <- function(dataset, CNA) {
    samples = dataset$METABRIC_ID
    samples = c("Hugo_Symbol","Entrez_Gene_Id",samples)
    overlap = colnames(CNA)[colnames(CNA) %in% samples]
    newCNA = CNA[,overlap,with=F]
}

testCNA = splitCNA(test, CNA)
trainingCNA = splitCNA(training, CNA)
validationCNA = splitCNA(validation, CNA)

write.table(testCNA, "/home/shared/data/metabric_split/test_CNA.txt", sep="\t", quote = F,row.names = F)
write.table(trainingCNA, "/home/shared/data/metabric_split/training_CNA.txt", sep="\t", quote = F,row.names = F)
write.table(validationCNA, "/home/shared/data/metabric_split/validation_CNA.txt", sep="\t", quote = F,row.names = F)

splitData <- function(dataset, unsplitData, column) {
    samples = dataset$METABRIC_ID
    unsplitSamples = unsplitData[,column,with=F]
    keepRows = unlist(unsplitSamples) %in% samples
    newData = unsplitData[keepRows,]
}

mutation = fread("/home/shared/data/brca_metabric/data_mutations_extended.txt",stringsAsFactors = F)

testMAF = splitData(test, mutation, "Tumor_Sample_Barcode")
trainingMAF = splitData(training, mutation, "Tumor_Sample_Barcode")
validationMAF = splitData(validation, mutation, "Tumor_Sample_Barcode")

write.table(testMAF, "/home/shared/data/metabric_split/test_MAF.txt", sep="\t", quote = F,row.names = F)
write.table(trainingMAF, "/home/shared/data/metabric_split/training_MAF.txt", sep="\t", quote = F,row.names = F)
write.table(validationMAF, "/home/shared/data/metabric_split/validation_MAF.txt", sep="\t", quote = F,row.names = F)



expression = fread("/home/shared/data/brca_metabric/data_expression.txt",stringsAsFactors = F)

testEXP = splitCNA(test, expression)
trainingEXP = splitCNA(training, expression)
validationEXP = splitCNA(validation, expression)

write.table(testEXP, "/home/shared/data/metabric_split/test_expression.txt", sep="\t", quote = F,row.names = F)
write.table(trainingEXP, "/home/shared/data/metabric_split/training_expression.txt", sep="\t", quote = F,row.names = F)
write.table(validationEXP, "/home/shared/data/metabric_split/validation_expression.txt", sep="\t", quote = F,row.names = F)

