import pandas as pd 
import synapseclient
from synapseclient import File
import os

def _addFiveYearSurvivalFlag(row):
	if row['T']/365.25 >= 5 and row['last_follow_up_status'] == "a":
		return(True)
	else:
		return(False)

def _keepSample(row):
	if row['last_follow_up_status'] != "a" or row['survival_5y'] == True:
		return(True)
	else:
		return(False)

def filterClinicalData(clinicalDf):
	#(OS_MONTHS / 12) >= 5 & OS_STATUS == "LIVING"`. then keep samples where `OS_STATUS == "DECEASED" | survival_5y == TRUE`
	clinicalDf = clinicalDf[~clinicalDf['last_follow_up_status'].isnull()]
	clinicalDf['survival_5y'] = clinicalDf.apply(_addFiveYearSurvivalFlag,axis=1)
	keepRows = clinicalDf.apply(_keepSample, axis=1)
	return(clinicalDf[keepRows])


if __name__ == '__main__':
	syn = synapseclient.login()
	dirpath = os.path.dirname(os.path.realpath(__file__))
	#Alive is 0
	#Dead is 1
	trainingClinicalEnt = syn.get("syn9815652")
	testValidClinicalEnt = syn.get("syn9815672")

	trainingClinical = pd.read_csv(trainingClinicalEnt.path,sep="\t")
	filteredTrainClinical = filterClinicalData(trainingClinical)
	filteredTrainClinical.to_csv(os.path.join(dirpath,"training_clinical.txt"),sep="\t",index=False)

	testValidClinical = pd.read_csv(testValidClinicalEnt.path,sep="\t")
	filteredtestValidClinical = filterClinicalData(testValidClinical)
	filteredtestValidClinical.to_csv(os.path.join(dirpath,"testvalidation_clinical.txt"),sep="\t",index=False)
	#Initial creation
	#validationClinical = filteredtestValidClinical.sample(455)
	#Future creations
	validationClinicalEnt = syn.get("syn9816453")
	validationClinical = pd.read_csv(validationClinicalEnt.path, sep="\t")
	testClinical = filteredtestValidClinical[~filteredtestValidClinical['METABRIC_ID'].isin(validationClinical['METABRIC_ID'])]

	validationClinical.to_csv(os.path.join(dirpath,"validation_clinical.txt"),sep="\t",index=False)
	testClinical.to_csv(os.path.join(dirpath,"test_clinical.txt"),sep="\t",index=False)

	syn.store(File(os.path.join(dirpath,"training_clinical.txt"), parent="syn8650974"))
	syn.store(File(os.path.join(dirpath,"validation_clinical.txt"), parent="syn8650974"))
	syn.store(File(os.path.join(dirpath,"test_clinical.txt"), parent="syn8650974"))

