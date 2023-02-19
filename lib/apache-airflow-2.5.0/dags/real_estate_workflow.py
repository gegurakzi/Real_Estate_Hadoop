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
    def extract(deal_ymd):
        return real_estate_csv_to_hdfs(deal_ymd)

    @task()
    def transform(foo):
        print(foo)
    res1 = extract("20220127")
    res2 = extract("20220128")
    res3 = extract("20220129")
    res4 = extract("20220130")
    res5 = extract("20220131")
    transform(res5)
real_estate_workflow_dag = real_estate_workflow()