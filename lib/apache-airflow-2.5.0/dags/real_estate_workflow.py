import pendulum

from airflow import DAG
from airflow.decorators import dag, task
from airflow.providers.apache.hive.hooks.hive import *
from airflow.providers.apache.hive.operators.hive import HiveOperator
from lib.extract.real_estate_csv import real_estate_csv_to_hdfs

with DAG(
    dag_id="real_estate_workflow_dag",
    schedule=None,
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
    catchup=False,
    tags=["extract"],
) as dag:
    @task(task_id="extract_csv_file")
    def extract(deal_ymd: str) -> str:
        return real_estate_csv_to_hdfs(deal_ymd)

    @task(task_id="extract_filepath_print")
    def extract_filepath_print(src: str) -> str:
        print(src)

    create_table = HiveOperator(
        task_id="create_table_trade",
        hql="""
            CREATE TABLE IF NOT EXISTS real_estate.trade(
                reg_year INT,
                gu_code INT,
                gu_name STRING,
                dong_code INT,
                dong_name STRING,
                jibun_type INT,
                jibun_name STRING,
                jibun_primary INT,
                jibun_secondary INT,
                building_name STRING,
                deal_date INT,
                deal_price INT,
                building_area DOUBLE,
                area DOUBLE,
                deal_floor INT,
                right_type STRING,
                deal_cancel INT,
                building_year INT,
                building_usage STRING,
                deal_type STRING,
                deal_relator STRING
            )STORED AS ORC
            LOCATION 'hdfs:///user/hive/warehouse'""",
        hive_cli_conn_id="hive_cli_real_estate",
        run_as_owner=True,
        dag=dag
    )


    load_on_table = HiveOperator(
        task_id="load_csv_on_table",
        hql="""
            DROP TABLE IF EXISTS real_estate.trade_external_db;
            CREATE EXTERNAL TABLE real_estate.trade_external_db (
                reg_year INT,
                gu_code INT,
                gu_name STRING,
                dong_code INT,
                dong_name STRING,
                jibun_type INT,
                jibun_name STRING,
                jibun_primary INT,
                jibun_secondary INT,
                building_name STRING,
                deal_date INT,
                deal_price INT,
                building_area DOUBLE,
                area DOUBLE,
                deal_floor INT,
                right_type STRING,
                deal_cancel INT,
                building_year INT,
                building_usage STRING,
                deal_type STRING,
                deal_relator STRING
            )
            ROW FORMAT DELIMITED
            FIELDS TERMINATED BY ','
            STORED AS TEXTFILE
            LOCATION 'hdfs:///user/airflow/data/DEAL_YMD-20220127'
            TBLPROPERTIES ('skip.header.line.count'='1');
            """,
        hive_cli_conn_id = "hive_cli_real_estate",
        run_as_owner = True,
        dag = dag
    )

    res1 = extract("20220127")
    res2 = extract("20220128")
    res3 = extract("20220129")
    res4 = extract("20220130")
    res5 = extract("20220131")

    res = [res1, res2, res3, res4, res5]

    print1 = extract_filepath_print(res1)
    print2 = extract_filepath_print(res2)
    print3 = extract_filepath_print(res3)
    print4 = extract_filepath_print(res4)
    print5 = extract_filepath_print(res5)


    [print1, print2, print3, print4, print5] >> create_table
    create_table >> load_on_table
