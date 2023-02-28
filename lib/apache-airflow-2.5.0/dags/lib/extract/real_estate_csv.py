
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
    print("Request sent, waiting...")
    r = requests.post(data_url, data=form)
    print("Response recieved")

    string_data = r.content.decode('euc-kr')
    data = StringIO(string_data)
    df = pd.read_csv(data, sep=",", skiprows=1)

    file_path = "/home"
    file_name = "DEAL_YMD-" + deal_ymd + "-" + \
                str(pendulum.now().date()).replace('-', '') + "-" + \
                str(pendulum.now().time()).replace(':', '') + '.csv'
    file_full = file_path + '/' + file_name
    hdfs_path = "/user/airflow/data/" + "DEAL_YMD-" + deal_ymd

    df.to_csv(file_full, encoding='utf-8')

    mkdir = Popen(["hadoop", "fs", "-mkdir", "-p", hdfs_path+"/history"], stdin=PIPE, bufsize=-1)
    mkdir.communicate()

    mv = Popen(["hadoop", "fs", "-mv", hdfs_path+"/*.csv", hdfs_path+"/history"], stdin=PIPE, bufsize=-1)
    mv.communicate()

    put = Popen(["hadoop", "fs", "-put", file_full, hdfs_path], stdin=PIPE, bufsize=-1)
    put.communicate()

    rm = Popen(["rm", file_full], stdin=PIPE, bufsize=-1)
    rm.communicate()

    return hdfs_path