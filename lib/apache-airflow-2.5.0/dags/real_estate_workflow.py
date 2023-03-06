import pendulum

from airflow import DAG
from airflow.decorators import task
from airflow.providers.apache.hive.operators.hive import HiveOperator
from lib.extract.real_estate_csv import real_estate_csv_to_hdfs

with DAG(
        dag_id="real_estate_workflow_dag",
        schedule=None,
        start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
        catchup=False,
        tags=["extract"],
) as dag:
    dealymd_initial = pendulum.date(2013, 1, 1)
    iteration = 5

    dealymd = str(dealymd_initial.add(days=0)).replace('-', '')

    INTERNAL_TABLE_ID = "trade"
    EXTERNAL_TABLE_ID = "trade_external_db"


    def hive_cli_connection_id() -> str:
        return "hive_cli_real_estate"


    def create_internal_real_estate_table_operation_hql() -> str:
        return f"""
        CREATE TABLE IF NOT EXISTS real_estate.{INTERNAL_TABLE_ID}(
            seq INT,
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
        PARTITIONED BY ( deal_date INT )
        STORED AS ORC
        LOCATION 'hdfs:///user/hive/warehouse';
        """


    def load_external_real_estate_table_operation_hql(filepath: str) -> str:
        return f"""
        DROP TABLE IF EXISTS real_estate.{EXTERNAL_TABLE_ID};
        CREATE EXTERNAL TABLE real_estate.{EXTERNAL_TABLE_ID} (
            seq INT,
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
        LOCATION 'hdfs://{filepath}'
        TBLPROPERTIES ('skip.header.line.count'='1');
        """


    def load_on_real_estate_table_operation_hql() -> str:
        return f"""
        INSERT OVERWRITE TABLE real_estate.{INTERNAL_TABLE_ID} PARTITION ( deal_date={dealymd} )
        SELECT seq,
            reg_year,
            gu_code,
            gu_name,
            dong_code,
            dong_name,
            jibun_type,
            jibun_name,
            jibun_primary,
            jibun_secondary,
            building_name,
            deal_price,
            building_area,
            area,
            deal_floor,
            right_type,
            deal_cancel,
            building_year,
            building_usage,
            deal_type,
            deal_relator FROM real_estate.{EXTERNAL_TABLE_ID};
        """


    @task(task_id="extract_csv_file")
    def extract(deal_ymd: str) -> str:
        return real_estate_csv_to_hdfs(deal_ymd)


    @task(task_id="extract_filepath_print")
    def extract_filepath_print(src: str):
        print(src)


    prev_load_on_internal_table = None

    for i in range(iteration):
        dealymd = str(dealymd_initial.add(days=i)).replace('-', '')

        create_table = HiveOperator(
            task_id=f"create_table_trade_{dealymd}",
            hql=create_internal_real_estate_table_operation_hql(),
            hive_cli_conn_id=hive_cli_connection_id(),
            run_as_owner=True,
            dag=dag
        )

        res = extract(dealymd)

        print_res = extract_filepath_print(res)

        load_external_table = HiveOperator(
            task_id=f"load_csv_on_table_{dealymd}",
            hql=load_external_real_estate_table_operation_hql(str(res)),
            hive_cli_conn_id=hive_cli_connection_id(),
            run_as_owner=True,
            dag=dag
        )

        load_on_internal_table = HiveOperator(
            task_id=f"load_external_data_on_internal_table_{dealymd}",
            hql=load_on_real_estate_table_operation_hql(),
            hive_cli_conn_id=hive_cli_connection_id(),
            run_as_owner=True,
            dag=dag
        )

        print_res >> create_table >> load_external_table >> load_on_internal_table

        if prev_load_on_internal_table is not None:
            prev_load_on_internal_table >> load_external_table

        prev_load_on_internal_table = load_on_internal_table
