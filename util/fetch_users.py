import sys
import synapseclient


def get_roster_df(syn, table_id):
    res = syn.tableQuery('select Name, RStudioUserName, Role from {}'
                         .format(table_id))
    return res.asDataFrame()


def role2group(role):
    group_map = {
        'Student': 'rstudio-user',
        'Admin': 'rstudio-user;rstudio-admin'
    }
    return group_map[role]


def format_user_df(roster_df):
    user_df = roster_df[['RStudioUserName', 'Role']]
    user_df['Role'] = user_df['Role'].map(role2group)
    return user_df


def main(argv):
    roster_table_id = argv[0]
    output_path = argv[1]

    syn = synapseclient.Synapse()
    syn.login()

    roster_df = get_roster_df(syn, roster_table_id)
    user_df = format_user_df(roster_df)

    user_df.to_csv(output_path, header=False, index=False)


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
