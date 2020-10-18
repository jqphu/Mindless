import requests
import json
import argparse

from typing import List
from datetime import datetime

class User:
    def __init__(self, username, name):
        self.id = 0
        self.username = username
        self.name = name

class Task:
    def __init__(self, user_id, name):
        self.id = 0
        self.user_id = user_id
        self.name = name

class Instance:
    def __init__(self, task_id, start, end):
        self.id = 0
        self.task_id = task_id
        self.start = start.strftime("%Y-%m-%dT%H:%M:%S.%f")
        self.end = end.strftime("%Y-%m-%dT%H:%M:%S.%f")

USERS = [
    User("jqphu", "Justin"),
    User("evil_justin", "Evil Justin"),
    User("cool_justin", "Cool Justin")
]

TASK_INFO = [
        (
            "Exercise",
            [
                Instance(1, datetime(2020, 8, 22, 12, 30, 22), datetime(2020, 8, 22, 14, 2, 2)),
                Instance(1, datetime(2020, 8, 22, 5, 30, 22),  datetime(2020, 8, 22, 7, 2, 2)),
                Instance(1, datetime(2020, 8, 21, 1, 30, 22),  datetime(2020, 8, 22, 14, 2, 2)),
                Instance(1, datetime(2020, 8, 12, 12, 30, 22), datetime(2020, 8, 13, 14, 2, 2)),
                ]
            ),
        (
            "Sleep",
            [
                Instance(2, datetime(2020, 8, 22, 11, 30, 22), datetime(2020, 8, 22, 14, 2, 2)),
                Instance(2, datetime(2020, 8, 22, 7, 30, 22),  datetime(2020, 8, 22, 8, 2, 2)),
                Instance(2, datetime(2020, 8, 21, 1, 30, 22),  datetime(2020, 8, 21, 14, 2, 2)),
                ]
            ),
        (
            "Project",
            [
                Instance(3, datetime(2020, 8, 16, 12, 30, 22), datetime(2020, 8, 17, 14, 2, 2))
                ]
            ),
        (
            "Work",
            [
                Instance(4, datetime(2020, 8, 20, 10, 30, 22), datetime(2020, 8, 21, 14, 2, 2))
                ]
            ),
        (
            "Misc",
            []
            ),
        ]

USER_ID = 1

def create_users(endpoint: str):
    for user in USERS:
        body = {
            'Create': user.__dict__
        }

        print(f"Request {body}")
        r = requests.post(f'{endpoint}/user', data = json.dumps(body))
        if r.status_code != 200:
            exit(1)

        result = r.json()
        print(f"Result {result}")

def create_tasks(endpoint: str):
    print("Creating tasks.")
    body = {
        'InsertAll': {
            'tasks': [
                [
                    Task(USER_ID, task_info[0]).__dict__,
                    [
                        instance.__dict__
                        for instance in task_info[1]
                    ]
                ]
                for task_info in TASK_INFO
            ]
        }
    }

    print(f"Request: {json.dumps(body, default=str)}")
    r = requests.post(f'{endpoint}/task', data = json.dumps(body, default=str))
    if r.status_code != 200:
        print(f"Failed with: {r.text}")
        exit(1)

    result = r.json()
    #if not 'error' in result:
    #    user.id = result['Create']['user']['id']
    print(f"Result: {result}")

    print("Done creating tasks.")


def main(args):
    if args.remote:
        endpoint = 'https://jqphu.dev/mindless/api'
    else:
        endpoint = 'http://127.0.0.1/mindless/api'

    create_users(endpoint)
    create_tasks(endpoint)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
            description='''
Fills the database with dummy data.
            '''
    )

    parser.add_argument('--remote', action='store_true', help='Send the data to the remote server (default: false)')

    args = parser.parse_args()

    # execute only if run as a script
    main(args)
