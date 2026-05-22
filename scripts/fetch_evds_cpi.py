#!/usr/bin/env python3
"""Fetch monthly CPI data from TCMB EVDS and write a dbt seed CSV.

The script uses the official EVDS HTTP interface. It reads the API key from EVDS_API_KEY first,
then TCMB_API_KEY, then a local .env file if present.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import sys
import time
from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal, InvalidOperation
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = REPO_ROOT / "superstore" / "seeds" / "evds_cpi_monthly.csv"

EVDS_BASE_URL = "https://evds3.tcmb.gov.tr/igmevdsms-dis"
SERIES_CODE = "TP.FG.J0"
SERIES_OUTPUT_COLUMN = SERIES_CODE.replace(".", "_")

DEFAULT_START_DATE = "01-01-2020"
DEFAULT_END_DATE = "31-08-2023"
REQUIRED_START_MONTH = date(2021, 1, 1)
REQUIRED_END_MONTH = date(2023, 8, 1)
REAL_REVENUE_BASE_MONTH = date(2023, 7, 1)


@dataclass(frozen=True)
class CpiRow:
    """Normalized CPI row shape that will be written to the dbt seed CSV."""

    cpi_month: date
    cpi_index_2003_100: Decimal
    source_series_code: str = SERIES_CODE


def load_dotenv(path: Path) -> None:
    """Load local .env secrets so the user does not need to export the key.

    This is a intentionally small parser: it supports plain KEY=VALUE lines and
    ignores comments/blank lines. Existing shell environment values win over
    .env values so CI or explicit shell exports can override local defaults.
    """
    if not path.exists():
        return

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def get_api_key() -> str:
    """Return the EVDS API key from env or fail before making any HTTP request."""
    load_dotenv(REPO_ROOT / ".env")
    api_key = os.getenv("EVDS_API_KEY") or os.getenv("TCMB_API_KEY")
    if not api_key:
        raise SystemExit(
            "Missing EVDS API key. Set EVDS_API_KEY in your shell or in a local .env file."
        )
    return api_key


def evds_url(start_date: str, end_date: str) -> str:
    """Build the EVDS URL for monthly JSON output for the configured CPI series."""
    return (
        f"{EVDS_BASE_URL}/series={SERIES_CODE}"
        f"&startDate={start_date}"
        f"&endDate={end_date}"
        "&type=json"
        "&frequency=5"
    )


def fetch_json(url: str, api_key: str, retries: int = 3, timeout: int = 30) -> dict[str, Any]:
    """Request EVDS JSON with basic retry handling for temporary failures.

    Auth failures stop immediately because retrying will not fix an invalid key.
    Rate limits and server/network failures retry a few times with exponential
    backoff so a transient EVDS issue does not fail the script unnecessarily.
    """
    last_error: Exception | None = None

    for attempt in range(1, retries + 1):
        request = Request(url, headers={"key": api_key, "User-Agent": "3a-superstore-analysis/1.0"})
        try:
            with urlopen(request, timeout=timeout) as response:
                body = response.read().decode("utf-8")
            return json.loads(body)
        except HTTPError as exc:
            if exc.code in {401, 403}:
                raise SystemExit("EVDS authentication failed. Check EVDS_API_KEY.") from exc
            last_error = exc
            if exc.code not in {429, 500, 502, 503, 504} or attempt == retries:
                break
        except (URLError, TimeoutError, json.JSONDecodeError) as exc:
            last_error = exc
            if attempt == retries:
                break

        time.sleep(2**attempt)

    raise SystemExit(f"EVDS request failed after {retries} attempts: {last_error}")


def parse_month(value: Any) -> date:
    """Parse EVDS date strings and normalize them to the first day of the month."""
    text = str(value).strip()
    formats = ("%Y-%m-%d", "%d-%m-%Y", "%d.%m.%Y", "%Y-%m", "%Y-%m-%dT%H:%M:%S")
    for fmt in formats:
        try:
            parsed = datetime.strptime(text, fmt)
            return date(parsed.year, parsed.month, 1)
        except ValueError:
            pass

    parts = text.split("-")
    if len(parts) == 2 and all(part.isdigit() for part in parts):
        year = int(parts[0])
        month = int(parts[1])
        return date(year, month, 1)

    raise ValueError(f"Could not parse EVDS date value: {text!r}")


def parse_decimal(value: Any) -> Decimal:
    """Parse CPI values as Decimal to avoid floating-point drift in the seed."""
    if value is None:
        raise ValueError("CPI value is null")

    text = str(value).strip()
    if not text:
        raise ValueError("CPI value is empty")

    text = text.replace(",", ".")
    try:
        return Decimal(text)
    except InvalidOperation as exc:
        raise ValueError(f"Could not parse CPI value: {value!r}") from exc


def find_value(row: dict[str, Any], candidates: set[str]) -> Any:
    """Find a value even if EVDS changes dot notation to underscore notation.

    EVDS may return the series column as TP_FG_J0 even though the requested
    series is TP.FG.J0, so this lookup normalizes both styles.
    """
    normalized = {key.lower().replace(".", "_"): key for key in row}
    for candidate in candidates:
        key = normalized.get(candidate.lower().replace(".", "_"))
        if key is not None:
            return row[key]
    raise KeyError(f"None of {sorted(candidates)} found in EVDS row keys: {sorted(row)}")


def parse_evds_items(payload: dict[str, Any]) -> list[CpiRow]:
    """Convert the raw EVDS response payload into sorted normalized CPI rows."""
    items = payload.get("items")
    if not isinstance(items, list) or not items:
        raise SystemExit(f"EVDS response did not contain non-empty 'items': {payload}")

    parsed_rows: list[CpiRow] = []
    for item in items:
        if not isinstance(item, dict):
            raise SystemExit(f"Unexpected EVDS item shape: {item!r}")

        month_value = find_value(item, {"Tarih", "Date"})
        cpi_value = find_value(item, {SERIES_CODE, SERIES_OUTPUT_COLUMN})
        parsed_rows.append(CpiRow(parse_month(month_value), parse_decimal(cpi_value)))

    return sorted(parsed_rows, key=lambda row: row.cpi_month)


def month_range(start: date, end: date) -> list[date]:
    """Return first-of-month dates from start through end, inclusive."""
    months: list[date] = []
    current = start
    while current <= end:
        months.append(current)
        year = current.year + int(current.month == 12)
        month = 1 if current.month == 12 else current.month + 1
        current = date(year, month, 1)
    return months


def validate_rows(rows: list[CpiRow]) -> None:
    """Validate that fetched CPI data is complete enough for this analysis.

    The sales dataset spans 2021-01 through 2023-08. We require CPI coverage for
    that full period and the selected real-revenue base month, July 2023. August
    remains required because the source sales data includes a partial August.
    """
    if not rows:
        raise SystemExit("No CPI rows parsed from EVDS response.")

    months = [row.cpi_month for row in rows]
    duplicate_months = sorted({month for month in months if months.count(month) > 1})
    if duplicate_months:
        raise SystemExit(f"Duplicate CPI months found: {duplicate_months}")

    observed = set(months)
    required = set(month_range(REQUIRED_START_MONTH, REQUIRED_END_MONTH))
    missing = sorted(required - observed)
    if missing:
        formatted = ", ".join(month.isoformat() for month in missing)
        raise SystemExit(f"Missing required CPI months: {formatted}")

    if REAL_REVENUE_BASE_MONTH not in observed:
        raise SystemExit(f"Missing base CPI month: {REAL_REVENUE_BASE_MONTH.isoformat()}")


def write_csv(rows: list[CpiRow], output_path: Path) -> None:
    """Write normalized CPI rows to the dbt seed CSV path."""
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", newline="", encoding="utf-8") as csv_file:
        writer = csv.DictWriter(
            csv_file,
            fieldnames=["cpi_month", "cpi_index_2003_100", "source_series_code"],
        )
        writer.writeheader()
        for row in rows:
            writer.writerow(
                {
                    "cpi_month": row.cpi_month.isoformat(),
                    "cpi_index_2003_100": str(row.cpi_index_2003_100),
                    "source_series_code": row.source_series_code,
                }
            )


def parse_args() -> argparse.Namespace:
    """Parse CLI options for date range and output path overrides."""
    parser = argparse.ArgumentParser(description="Fetch monthly CPI data from TCMB EVDS.")
    parser.add_argument("--start-date", default=DEFAULT_START_DATE, help="EVDS startDate, DD-MM-YYYY.")
    parser.add_argument("--end-date", default=DEFAULT_END_DATE, help="EVDS endDate, DD-MM-YYYY.")
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help="Output CSV path. Defaults to superstore/seeds/evds_cpi_monthly.csv.",
    )
    return parser.parse_args()


def main() -> int:
    """Run the end-to-end fetch, validation, and CSV write flow."""
    args = parse_args()
    api_key = get_api_key()
    url = evds_url(args.start_date, args.end_date)
    payload = fetch_json(url, api_key)
    rows = parse_evds_items(payload)
    validate_rows(rows)
    write_csv(rows, args.output)

    base_row = next(row for row in rows if row.cpi_month == REAL_REVENUE_BASE_MONTH)
    print(f"Wrote {len(rows)} CPI rows to {args.output}")
    print(f"Month range: {rows[0].cpi_month.isoformat()} to {rows[-1].cpi_month.isoformat()}")
    print(
        "Real revenue base month CPI "
        f"({REAL_REVENUE_BASE_MONTH.isoformat()}): {base_row.cpi_index_2003_100}"
    )
    print(f"Source series: {SERIES_CODE}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
