#!/usr/bin/env python3

"""Collect air-conditioner meter readings from the public state API."""

import argparse
import csv
import json
import sys
import time
from datetime import datetime
from decimal import ROUND_CEILING, Decimal, InvalidOperation
from pathlib import Path
from typing import Callable, Sequence, TextIO
from urllib.parse import urlencode
from urllib.request import Request, urlopen


RAW_UNITS_PER_KWH = Decimal("100")
STATE_ENDPOINT = "https://gxkt.juhaolian.cn/api/device/direct/state"
CSV_HEADER = ("时间", "读数信息", "与上一个读数信息的差距")


class ResponseError(ValueError):
    """Raised when an API response does not contain a valid meter reading."""


def parse_reading(payload: object) -> Decimal:
    """Return the API's raw electric amount converted to kWh."""
    if not isinstance(payload, dict):
        raise ResponseError("响应不是 JSON 对象")
    if payload.get("success") is not True:
        raise ResponseError(str(payload.get("message") or "接口返回失败"))

    result = payload.get("result")
    if not isinstance(result, dict) or "electricAmount" not in result:
        raise ResponseError("响应缺少 result.electricAmount")

    try:
        raw_reading = Decimal(str(result["electricAmount"]))
    except (InvalidOperation, TypeError, ValueError) as error:
        raise ResponseError("electricAmount 不是有效数值") from error
    return raw_reading / RAW_UNITS_PER_KWH


def format_decimal(value: Decimal) -> str:
    """Format a kWh value with exactly two decimal places."""
    return f"{value:.2f}"


def reading_delta(current: Decimal, previous: Decimal | None) -> Decimal:
    """Return zero for the first reading, otherwise the reading difference."""
    if previous is None:
        return Decimal("0")
    return current - previous


def fetch_reading(
    imei: str,
    timeout_seconds: float,
    opener: Callable = urlopen,
) -> Decimal:
    """Fetch one public state snapshot and return its meter reading in kWh."""
    query = urlencode({"imei": imei})
    request = Request(
        f"{STATE_ENDPOINT}?{query}",
        headers={"Accept": "application/json", "User-Agent": "aircon-meter-logger/1"},
        method="GET",
    )
    with opener(request, timeout=timeout_seconds) as response:
        try:
            payload = json.loads(response.read().decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as error:
            raise ResponseError("接口没有返回有效 JSON") from error
    return parse_reading(payload)


def sample_count(duration_hours: Decimal, interval_seconds: Decimal) -> int:
    """Return the number of sample slots whose deadlines fall in the duration."""
    if duration_hours <= 0:
        raise ValueError("采集时长必须大于 0")
    if interval_seconds <= 0:
        raise ValueError("采集间隔必须大于 0")
    total_seconds = duration_hours * Decimal("3600")
    return int((total_seconds / interval_seconds).to_integral_value(rounding=ROUND_CEILING))


def run_collection(
    csv_file: TextIO,
    *,
    sample_slots: int,
    interval_seconds: float,
    fetcher: Callable[[], Decimal],
    monotonic: Callable[[], float] = time.monotonic,
    sleeper: Callable[[float], None] = time.sleep,
    now: Callable[[], datetime] = datetime.now,
    error_stream: TextIO = sys.stderr,
) -> int:
    """Run scheduled samples and return the number of successful CSV rows."""
    writer = csv.writer(csv_file)
    writer.writerow(CSV_HEADER)
    csv_file.flush()

    previous: Decimal | None = None
    successful_rows = 0
    started_at = monotonic()

    for slot in range(sample_slots):
        deadline = started_at + slot * interval_seconds
        sleeper(max(0.0, deadline - monotonic()))
        try:
            current = fetcher()
        except Exception as error:  # Continue collecting after transient failures.
            print(
                f"{now():%Y-%m-%d %H:%M:%S} 采集失败: {error}",
                file=error_stream,
            )
            continue

        delta = reading_delta(current, previous)
        delta_text = "0" if previous is None else format_decimal(delta)
        writer.writerow(
            [
                now().strftime("%Y-%m-%d %H:%M:%S"),
                format_decimal(current),
                delta_text,
            ]
        )
        csv_file.flush()
        previous = current
        successful_rows += 1

    return successful_rows


def positive_decimal(value: str) -> Decimal:
    """Parse a positive decimal command-line value."""
    try:
        parsed = Decimal(value)
    except InvalidOperation as error:
        raise argparse.ArgumentTypeError(f"不是有效数值: {value}") from error
    if not parsed.is_finite() or parsed <= 0:
        raise argparse.ArgumentTypeError("数值必须大于 0")
    return parsed


def valid_imei(value: str) -> str:
    """Validate a 15-digit device IMEI."""
    if len(value) != 15 or not value.isdecimal():
        raise argparse.ArgumentTypeError("IMEI 必须恰好为 15 位数字")
    return value


def default_output_path(started_at: datetime) -> Path:
    """Return the default timestamped CSV path in the current directory."""
    timestamp = started_at.strftime("%Y%m%d_%H%M%S")
    return Path.cwd() / f"aircon_meter_readings_{timestamp}.csv"


def build_parser() -> argparse.ArgumentParser:
    """Build the command-line parser."""
    parser = argparse.ArgumentParser(
        description=(
            "每分钟读取一次聚好联公开空调电表数据，并将原始 electricAmount "
            "除以 100 后保存为 kWh CSV。"
        )
    )
    parser.add_argument("imei", type=valid_imei, help="设备的 15 位 IMEI")
    parser.add_argument(
        "--output",
        type=Path,
        help="输出 CSV 路径；默认在当前目录生成带时间戳的文件",
    )
    parser.add_argument(
        "--duration-hours",
        type=positive_decimal,
        default=Decimal("4"),
        help="采集时长（小时），默认 4",
    )
    parser.add_argument(
        "--interval-seconds",
        type=positive_decimal,
        default=Decimal("60"),
        help="采集间隔（秒），默认 60",
    )
    parser.add_argument(
        "--timeout-seconds",
        type=positive_decimal,
        default=Decimal("10"),
        help="单次请求超时（秒），默认 10",
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    """Run the command-line collector."""
    args = build_parser().parse_args(argv)
    started_at = datetime.now()
    output_path = args.output or default_output_path(started_at)
    output_path = output_path.expanduser().resolve()
    output_path.parent.mkdir(parents=True, exist_ok=True)

    slots = sample_count(args.duration_hours, args.interval_seconds)
    print(f"输出文件: {output_path}")
    print(
        f"计划采集 {slots} 次，间隔 {args.interval_seconds} 秒，"
        f"总时长 {args.duration_hours} 小时。"
    )

    interrupted = False
    successful_rows = 0
    with output_path.open("w", encoding="utf-8-sig", newline="") as csv_file:
        try:
            successful_rows = run_collection(
                csv_file,
                sample_slots=slots,
                interval_seconds=float(args.interval_seconds),
                fetcher=lambda: fetch_reading(
                    args.imei,
                    timeout_seconds=float(args.timeout_seconds),
                ),
            )
        except KeyboardInterrupt:
            interrupted = True

    print(f"已保存 {successful_rows} 条有效读数: {output_path}")
    if interrupted:
        print("采集已由用户中止。", file=sys.stderr)
        return 130
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
