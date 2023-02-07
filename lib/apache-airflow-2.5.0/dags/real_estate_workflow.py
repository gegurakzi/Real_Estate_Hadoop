import sys


import pendulum

from airflow.decorators import dag
from airflow.operators.python import PythonOperator

from lib.extract.real_estate_csv import real_estate_csv_to_hdfs

@dag(
    dag_id="real_estate_workflow_dag",
    schedule=None,
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
    catchup=False,
    tags=["extract"],
)
def real_estate_workflow():

    t1 = PythonOperator(
        task_id="task1_id",
        python_callable=real_estate_csv_to_hdfs("20220130")
    )


real_estate_workflow_dag = real_estate_workflow()