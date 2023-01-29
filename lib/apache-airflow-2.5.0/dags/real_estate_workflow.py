import sys


import pendulum

from airflow.decorators import dag
from airflow.operators.python import PythonOperator

from lib.extract.real_estate_csv import csv_to_hdfs

@dag(
    schedule=None,
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
    catchup=False,
    tags=["extract"],
)
def real_estate_workflow(deal_ymd):

    t1 = PythonOperator(
        task_id="task1_id",
        python_callable=csv_to_hdfs(deal_ymd)
    )


real_estate_workflow_dag = real_estate_workflow("20220130")