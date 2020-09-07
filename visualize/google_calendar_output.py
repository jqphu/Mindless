#!/usr/bin/python3
import git
import os
import sqlite3
from datetime import datetime
import pprint as pp
import csv


DATABASE_FILE_RELATIVE_PATH = 'visualize/weekly_data.db'

def get_git_root():
    git_repo = git.Repo('.', search_parent_directories=True)
    git_root = git_repo.git.rev_parse('--show-toplevel')
    return git_root

def to_date_and_time(datetime_string):
    datetime_object = datetime.fromisoformat(datetime_string)
    return (datetime_object.date().isoformat(), datetime_object.time().isoformat())

def write_to_csv(data_dict):
    field_names = ["Subject", "Start Date", "Start Time", "End Date", "End Time"]
    with open('calendar.csv', 'w') as csvfile:
        writer = csv.DictWriter(csvfile, field_names)
        writer.writeheader()
        writer.writerows(data_dict)

def main():
    repo_root = get_git_root()
    print(f'Running build script with git root at {repo_root}')

    database_path = os.path.join(repo_root, DATABASE_FILE_RELATIVE_PATH)

    connection = sqlite3.connect(database_path)
    val = connection.execute('SELECT * FROM instances INNER JOIN tasks ON instances.task_id=tasks.id')

    data = []
    for row in val:
        start_datetime_obj = to_date_and_time(row[2])
        end_datetime_obj = to_date_and_time(row[3])
        instance = {
                "Subject": row[7],
                "Start Date": start_datetime_obj[0],
                "Start Time": start_datetime_obj[1],
                "End Date": end_datetime_obj[0],
                "End Time": end_datetime_obj[1],
                }
        data.append(instance)

    write_to_csv(data)



if __name__ == '__main__':
    main()
