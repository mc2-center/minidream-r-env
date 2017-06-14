# Use rpy2 if you have R scoring functions
import rpy2.robjects as robjects
import os
filePath = os.path.join(os.path.dirname(os.path.abspath(__file__)),'getROC.R')
robjects.r("source('%s')" % filePath)
AUC_pAUC = robjects.r('GetScores')
##-----------------------------------------------------------------------------
##
## challenge specific code and configuration
import pandas as pd
import sklearn.metrics as skm
##-----------------------------------------------------------------------------


## A Synapse project will hold the assetts for your challenge. Put its
## synapse ID here, for example
## CHALLENGE_SYN_ID = "syn1234567"
CHALLENGE_SYN_ID = "syn8650663"

## Name of your challenge, defaults to the name of the challenge's project
CHALLENGE_NAME = "CSBC Summer Research Program miniDREAM Challenge"

## Synapse user IDs of the challenge admins who will be notified by email
## about errors in the scoring script
ADMIN_USER_IDS = ['2223305']


## Each question in your challenge should have an evaluation queue through
## which participants can submit their predictions or models. The queues
## should specify the challenge project as their content source. Queues
## can be created like so:
##   evaluation = syn.store(Evaluation(
##     name="My Challenge Q1",
##     description="Predict all the things!",
##     contentSource="syn1234567"))
## ...and found like this:
##   evaluations = list(syn.getEvaluationByContentSource('syn3375314'))
## Configuring them here as a list will save a round-trip to the server
## every time the script starts and you can link the challenge queues to
## the correct scoring/validation functions.  Predictions will be validated and 

def validate_func(submission, goldstandard_path):
    ##Read in submission (submission.filePath)
    submission_df = pd.read_csv(submission.filePath)
    col_names = list(submission_df)

    ##Validate submission
    ## MUST USE ASSERTION ERRORS!!! 
    ##eg.
    ## assert os.path.basename(submission.filePath) == "prediction.tsv", "Submission file must be named prediction.tsv"
    ## or raise AssertionError()...
    ## Only assertion errors will be returned to participants, all other errors will be returned to the admin
    assert 'METABRIC_ID' in col_names, "'METABRIC_ID' column not found in '{}'".format(os.path.basename(submission.filePath))
    assert submission_df['METABRIC_ID'].dtype == 'O', "'METABRIC_ID' column must contain string values"
    assert 'T' in col_names, "'T' column not found in '{}'".format(os.path.basename(submission.filePath))
    assert submission_df['T'].dtype == 'float64', "'T' column must contain numeric values"
    assert submission_df.shape[0] == 434, "submission should contain 434 rows"
    return (True, "Passed Validation")

def score_func(submission, goldstandard_path):
    ##Read in submission (submission.filePath)
    goldstandard_df = pd.read_csv(goldstandard_path, delimiter="\t")[['METABRIC_ID', 'T']]
    submission_df = pd.read_csv(submission.filePath)[['METABRIC_ID', 'T']]

    ##Score against goldstandard
    check_df = pd.merge(submission_df, goldstandard_df, how='left', on='METABRIC_ID')
    r2 = skm.r2_score(check_df['T_y'], check_df['T_x'])
    rmse = skm.mean_squared_error(check_df['T_y'], check_df['T_x'])**(0.5)
    return(r2, rmse)

evaluation_queues = [
#CSBC Summer Research DREAM submission (9603635)
    {
        'id':9604686,
        'scoring_func':score_func,
        'validation_func':validate_func,
        'goldstandard_path':'../data/validation/validation_clinical.txt'
    }
]
evaluation_queue_by_id = {q['id']:q for q in evaluation_queues}


## define the default set of columns that will make up the leaderboard
LEADERBOARD_COLUMNS = [
    dict(name='objectId',      display_name='ID',      columnType='STRING', maximumSize=20),
    dict(name='userId',        display_name='User',    columnType='STRING', maximumSize=20, renderer='userid'),
    dict(name='entityId',      display_name='Entity',  columnType='STRING', maximumSize=20, renderer='synapseid'),
    dict(name='versionNumber', display_name='Version', columnType='INTEGER'),
    dict(name='name',          display_name='Name',    columnType='STRING', maximumSize=240),
    dict(name='team',          display_name='Team',    columnType='STRING', maximumSize=240)]

## Here we're adding columns for the output of our scoring functions, score,
## rmse and auc to the basic leaderboard information. In general, different
## questions would typically have different scoring metrics.
leaderboard_columns = {}
for q in evaluation_queues:
    leaderboard_columns[q['id']] = LEADERBOARD_COLUMNS + [
        dict(name='score',         display_name='Score',   columnType='DOUBLE'),
        dict(name='rmse',          display_name='RMSE',    columnType='DOUBLE'),
        dict(name='auc',           display_name='AUC',     columnType='DOUBLE')]

## map each evaluation queues to the synapse ID of a table object
## where the table holds a leaderboard for that question
leaderboard_tables = {}


def validate_submission(evaluation, submission):
    """
    Find the right validation function and validate the submission.

    :returns: (True, message) if validated, (False, message) if
              validation fails or throws exception
    """
    config = evaluation_queue_by_id[int(evaluation.id)]
    validated, validation_message = config['validation_func'](submission, config['goldstandard_path'])
    
    return True, validation_message


def score_submission(evaluation, submission):
    """
    Find the right scoring function and score the submission

    :returns: (score, message) where score is a dict of stats and message
              is text for display to user
    """
    config = evaluation_queue_by_id[int(evaluation.id)]
    score = config['scoring_func'](submission, config['goldstandard_path'])
    #Make sure to round results to 3 or 4 digits
    return (dict(score=round(score[0],4), rmse=score[1]), "You did fine!")


