import sqlite3
from pathlib import Path

import pandas as pd


BASE_DIR = Path(__file__).resolve().parents[1]
RAW_DATA_PATH = BASE_DIR / "data" / "raw" / "ai4i2020.csv"
DB_PATH = BASE_DIR / "data" / "processed" / "maintenance.db"


def clean_column_names(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df.columns = (
        df.columns
        .str.strip()
        .str.lower()
        .str.replace(" ", "_")
        .str.replace("[", "", regex=False)
        .str.replace("]", "", regex=False)
        .str.replace("(", "", regex=False)
        .str.replace(")", "", regex=False)
    )
    return df


def main():
    if not RAW_DATA_PATH.exists():
        raise FileNotFoundError(f"CSV file not found: {RAW_DATA_PATH}")

    df = pd.read_csv(RAW_DATA_PATH)
    df = clean_column_names(df)

    print("Columns:")
    print(df.columns.tolist())
    print(f"Rows: {len(df)}")

    DB_PATH.parent.mkdir(parents=True, exist_ok=True)

    conn = sqlite3.connect(DB_PATH)
    df.to_sql("machine_readings", conn, if_exists="replace", index=False)
    conn.close()

    print(f"Database created: {DB_PATH}")


if __name__ == "__main__":
    main()