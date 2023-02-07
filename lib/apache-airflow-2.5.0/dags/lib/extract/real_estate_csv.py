
import pendulum
from io import StringIO
import pandas as pd
import requests
from subprocess import PIPE, Popen

def real_estate_csv_to_hdfs(deal_ymd, **context):

    data_url = "https://datafile.seoul.go.kr/bigfile/iot/sheet/csv/download.do"
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

    string_data = r.content.decode('euc-kr')
    data = StringIO(string_data)
    df = pd.read_csv(data, sep=",", header=None)

    file_name = "DEAL_YMD-" + deal_ymd + "-" + \
                str(pendulum.now().date()).replace('-', '') + "-" + \
                str(pendulum.now().time()) + '.csv'
    hdfs_path = "/data/" + "DEAL_YMD-" + deal_ymd

    df.to_csv(file_name, encoding='utf-8')

    put = Popen(["hadoop", "fs", "-mkdir", hdfs_path], stdin=PIPE, bufsize=-1)
    put.communicate()

    put = Popen(["hadoop", "fs", "-put", file_name, hdfs_path], stdin=PIPE, bufsize=-1)
    put.communicate()