library(tidyverse)

### Update activity data

load("/home/shared/data/metabric_split/activity_data.RData")

# check format ------------------------------------------------------------

glimpse(activity_clinical_df)

# update fields -----------------------------------------------------------

activity_clinical_df <- activity_clinical_df %>% 
    mutate(survival_5y = (T / 365.25) >= 5,
           lymph_nodes_positive = as.integer(lymph_nodes_positive),
           lymph_nodes_removed = as.integer(lymph_nodes_removed),
           Site = as.character(Site))

# add fields --------------------------------------------------------------

activity_clinical_df <- activity_clinical_df %>% 
    mutate(censored = last_follow_up_status %in% c("a", "d-o.c."))


# filter samples ----------------------------------------------------------

activity_clinical_df <- activity_clinical_df %>% 
    filter(METABRIC_ID %in% names(activity_expression_df))


### Update challenge data

load("/home/shared/data/metabric_split/challenge_data.RData")
validation_clinical_df <- read_tsv("/home/shared/data/metabric_split/.archive/validation_clinical.txt")

# check format ------------------------------------------------------------

glimpse(challenge_clinical_df)


# update fields -----------------------------------------------------------

challenge_clinical_df <- challenge_clinical_df %>% 
    mutate(lymph_nodes_positive = as.integer(lymph_nodes_positive),
           lymph_nodes_removed = as.integer(lymph_nodes_removed),
           Site = as.character(Site))

# add fields --------------------------------------------------------------

validation_clinical_df <- validation_clinical_df %>%
    mutate(survival_5y = (T / 365.25) >= 5,
           censored = last_follow_up_status %in% c("a", "d-o.c."))

challenge_clinical_df <- challenge_clinical_df %>% 
    left_join(validation_clinical_df %>% 
                  select(METABRIC_ID, censored),
              by = "METABRIC_ID")


