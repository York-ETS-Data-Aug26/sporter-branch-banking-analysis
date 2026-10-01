import argparse
from pathlib import Path

import psycopg

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "user": "analyst",
    "password": "analyst",
    "dbname": "fdic",
}

def create_staging_table(conn):
    with conn.cursor() as cur:
        cur.execute("DROP SCHEMA IF EXISTS banks_analysis CASCADE;")

        cur.execute("CREATE SCHEMA banks_analysis;")

        cur.execute("SET search_path TO banks_analysis, public;")

        cur.execute("""
            CREATE TABLE staging (
                index TEXT,
                FID TEXT,
                ADDRESBR TEXT,
                BRNUM TEXT,
                BRSERTYP TEXT,
                CBSABR TEXT,
                CBSANAMB TEXT,
                CITYBR TEXT,
                CNTRYNAB TEXT,
                CNTYNAMB TEXT,
                DEPSUMBR TEXT,
                GEOCODE_CE TEXT,
                GEOCODE__1 TEXT,
                NAMEBR TEXT,
                STALPBR TEXT,
                STCNTYBR TEXT,
                STNAMEBR TEXT,
                UNINUMBR TEXT,
                ZIPBR TEXT,
                CERT TEXT,
                ADDRESS TEXT,
                ASSET TEXT,
                BKCLASS TEXT,
                CITY TEXT,
                CNTRYNA TEXT,
                DENOVO TEXT,
                DEPDOM TEXT,
                NAMEFULL TEXT,
                NAMEHCR TEXT,
                REGAGNT TEXT,
                REPDTE TEXT,
                RSSDID TEXT,
                STALP TEXT,
                STCNTY TEXT,
                STNAME TEXT,
                ZIP TEXT,
                BKMO TEXT,
                LOC_NAME TEXT,
                STATUS TEXT,
                SCORE TEXT,
                x TEXT,
                y TEXT,
                GeocodeSou TEXT
            );
        """)
    conn.commit()

def load_csv(conn, csv_path):
    with open(csv_path, "r", encoding="utf-8",newline="") as csv_file:
        with conn.cursor() as cur:
            with cur.copy(
                """
                COPY staging
                FROM STDIN
                WITH (
                    FORMAT csv,
                    HEADER true
                );
                """
            ) as copy:
                while data := csv_file.read(8192):
                    copy.write(data)
    conn.commit()

def main():
    parser = argparse.ArgumentParser(description= "Will produce the staging table and load a CSV.")

    parser.add_argument("csv_path", type=Path, help="Path to the CSV file")

    args = parser.parse_args()

    if not args.csv_path.exists():
        raise FileNotFoundError(f"File not found at {args.csv_path}")

    print("Waiting on Postgresql Connection...")

    with psycopg.connect(**DB_CONFIG) as conn:
        print("Creating the staging table...")
        create_staging_table(conn)

        print(f"Loading the CSV from {args.csv_path}...")
        load_csv(conn, args.csv_path)

    print("Done!")
if __name__ == '__main__':
    main()