
import pendulum

from airflow.decorators import dag, task

from io import StringIO
import pandas as pd
import requests

from subprocess import PIPE, Popen

@dag(
    schedule=None,
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
    catchup=False,
    tags=["extract"],
)
def real_estate_workflow():
    @task()
    def extract():
        now = pendulum.now().time()
        data_url = "https://datafile.seoul.go.kr/bigfile/iot/sheet/csv/download.do"
        deal_ymd = "20220130"
        form = {
            "srvType": 5,
            "infId": "OA-21275",
            "serviceKind": 1,
            "pageNo": 1,
            "strOrderby": "DEAL_YMD+DESC",
            "filterCol": "DEAL_YMD",
            "txtFilter": deal_ymd
        }

        r = requests.post(data_url, data=form)
        file_name = "DEAL_YMD-" + deal_ymd + "-" + \
                    pendulum.now().date().replace('-', '') + "-" + \
                    pendulum.now().time() + '.csv'
        hdfs_path = "/data/" + "DEAL_YMD-" + deal_ymd
        string_data = r.content.decode('euc-kr')
        data = StringIO(string_data)
        df = pd.read_csv(data, sep=",", header=None)
        df.to_csv(file_name, encoding='utf-8')

        put = Popen(["hadoop", "fs", "-mkdir", hdfs_path], stdin=PIPE, bufsize=-1)
        put.communicate()

        put = Popen(["hadoop", "fs", "-put", file_name, hdfs_path], stdin=PIPE, bufsize=-1)
        put.communicate()



