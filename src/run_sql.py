import sqlite3
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[1]
DB_PATH = BASE_DIR / "data" / "processed" / "maintenance.db"
SQL_DIR = BASE_DIR / "sql"
REPORT_PATH = BASE_DIR / "reports" / "sql_results.txt"


def split_sql_file(sql_text: str) -> list[str]:
    queries = []
    current_query = []

    for line in sql_text.splitlines():
        stripped = line.strip()

        if stripped.startswith("--") and current_query:
            query = "\n".join(current_query).strip()
            if query:
                queries.append(query)
            current_query = []

        current_query.append(line)

    query = "\n".join(current_query).strip()
    if query:
        queries.append(query)

    return queries


def clean_query(query: str) -> str:
    lines = []
    for line in query.splitlines():
        if not line.strip().startswith("--"):
            lines.append(line)
    return "\n".join(lines).strip()


def run_query(query: str, conn: sqlite3.Connection) -> str:
    clean = clean_query(query)

    if not clean:
        return ""

    try:
        cursor = conn.execute(clean)
        rows = cursor.fetchall()
        columns = [description[0] for description in cursor.description]

        output = []
        output.append("COLUMNS: " + str(columns))

        for row in rows[:30]:
            output.append(str(row))

        if len(rows) > 30:
            output.append(f"... {len(rows) - 30} more rows")

        return "\n".join(output)

    except Exception as e:
        return f"QUERY FAILED:\n{clean}\nERROR: {e}"


def main():
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)

    sql_files = [
        SQL_DIR / "02_basic_analysis.sql",
        SQL_DIR / "03_failure_analysis.sql",
        SQL_DIR / "04_risk_segments.sql",
    ]

    conn = sqlite3.connect(DB_PATH)

    report_sections = []

    for sql_file in sql_files:
        sql_text = sql_file.read_text(encoding="utf-8")
        queries = split_sql_file(sql_text)

        report_sections.append("=" * 100)
        report_sections.append(f"FILE: {sql_file.name}")
        report_sections.append("=" * 100)

        for i, query in enumerate(queries, start=1):
            report_sections.append("\n" + "-" * 80)
            report_sections.append(f"QUERY {i}")
            report_sections.append("-" * 80)
            report_sections.append(query)
            report_sections.append("\nRESULT:")
            report_sections.append(run_query(query, conn))

    conn.close()

    REPORT_PATH.write_text("\n".join(report_sections), encoding="utf-8")
    print(f"SQL report saved to: {REPORT_PATH}")


if __name__ == "__main__":
    main()