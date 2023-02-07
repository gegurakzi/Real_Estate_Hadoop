import pendulum

from airflow.decorators import dag, task
from lib.extract.real_estate_csv import real_estate_csv_to_hdfs

@dag(
    dag_id="real_estate_workflow_dag",
    schedule=None,
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
    catchup=False,
    tags=["extract"],
)
def real_estate_workflow():

    @task()
    def extract():
        return real_estate_csv_to_hdfs("20220130")

    @task()
    def transform(foo):
        print(foo)
    res = extract()
    transform(res)
real_estate_workflow_dag = real_estate_workflow()