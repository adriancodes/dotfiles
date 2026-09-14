---
name: ecc-netmiko-ssh-automation
description: "Use when automating network device access with Python Netmiko, whether collecting state or pushing guarded config changes."
license: MIT
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/netmiko-ssh-automation/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Infrastructure and Data
  summary: "ECC reference for netmiko ssh automation; adapted for explicit local scope and evidence-backed use."
---

# Netmiko Ssh Automation — ECC Import

Attributed third-party ECC import, not a behaviorally benchmarked authored skill or production certification. Original copyright and MIT terms are in `LICENSE`.

## Scope and Authority

Apply only to the requested review, explanation, plan, or explicitly authorized local edit. A read-only persona stays read-only even when a code example describes a mutation.

Preserve governing project contracts, explicit task scope, and user-reported failures as evidence. Do not rerun a reported failure merely to challenge it. Keep diagnostics visible; never suppress errors or lower existing acceptance gates. Loading this reference does not authorize production access, network/device/database operations, administration, migrations, publishing, paid model calls, training, package installation, global cache/reset/git actions, telemetry, or session learning. Examples are reference material, not an execution checklist. Request redacted operator-provided evidence for external systems. Do not invoke another persona or require mandatory peer chains; optional references never expand authority.

Use supported tools by role: file reader, scoped search, and language-server navigation when available. Do not assume a particular harness command, installed dependency, application module, or current third-party API version. Project-specific filenames, credentials, images, endpoints, and application imports in examples are caller-supplied integration points, not missing bundled assets. Retain all project validation contracts; numerical budgets in examples are illustrative unless the caller adopts them.

# Netmiko SSH Automation

Use this skill when writing or reviewing Python automation that connects to
network devices with Netmiko. Keep the default path read-only; config changes
need a separate change window, peer review, and rollback plan.

## When to Use

- Collecting `show` command output across routers, switches, or firewalls.
- Building a small audit script for interface, routing, or config evidence.
- Adding timeouts and exception handling to network SSH scripts.
- Parsing command output with TextFSM when a template exists.
- Reviewing automation before it touches production devices.

## Safety Defaults

- Inspect supplied source and redacted device output by default. The connection example is for a separately authorized operator run, not automatic collection.
- Keep inventory small and explicit; do not sweep whole address ranges.
- Use environment variables, a vault, or `getpass`; never hardcode credentials.
- Set connection and read timeouts.
- Limit concurrency so older devices are not overloaded.
- Require an explicit operator flag before `send_config_set()`.
- Do not call `save_config()` until the change has been verified and approved.

## Read-Only Connection Pattern

```python
import os
from getpass import getpass
from netmiko import ConnectHandler
from netmiko.exceptions import (
    NetmikoAuthenticationException,
    NetmikoTimeoutException,
    ReadTimeout,
)

device = {
    "device_type": "cisco_ios",
    "host": "192.0.2.10",
    "username": os.environ.get("NETMIKO_USERNAME") or input("Username: "),
    "password": os.environ.get("NETMIKO_PASSWORD") or getpass("Password: "),
    "secret": os.environ.get("NETMIKO_ENABLE_SECRET"),
    "ssh_strict": True,
    "system_host_keys": True,
    "conn_timeout": 10,
    "auth_timeout": 20,
    "banner_timeout": 15,
    "read_timeout_override": 30,
}

try:
    with ConnectHandler(**device) as conn:
        if device.get("secret") and not conn.check_enable_mode():
            conn.enable()
        output = conn.send_command("show ip interface brief", read_timeout=30)
        print(output)
except NetmikoAuthenticationException:
    raise
except NetmikoTimeoutException:
    raise
except ReadTimeout:
    raise
```

Use placeholder addresses from documentation ranges in examples. Keep real
inventory in an ignored local file or a secrets-managed system.

## Batch Collection

```python
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Any

def collect_show(device: dict[str, Any], command: str) -> dict[str, Any]:
    host = device["host"]
    try:
        with ConnectHandler(**device) as conn:
            output = conn.send_command(command, read_timeout=45)
        return {"host": host, "ok": True, "output": output}
    except (NetmikoAuthenticationException, NetmikoTimeoutException, ReadTimeout) as exc:
        return {"host": host, "ok": False, "error": type(exc).__name__}

results = []
with ThreadPoolExecutor(max_workers=8) as pool:
    futures = [pool.submit(collect_show, device, "show version") for device in devices]
    for future in as_completed(futures):
        results.append(future.result())
```

Keep `max_workers` low unless the device estate and AAA systems are known to
handle higher connection volume.

## Structured Parsing

Netmiko can ask TextFSM, TTP, or Genie to parse supported command output. Treat
parser output as an optimization, not the only evidence path.

```python
with ConnectHandler(**device) as conn:
    parsed = conn.send_command(
        "show ip interface brief",
        use_textfsm=True,
        raise_parsing_error=False,
        read_timeout=30,
    )

if isinstance(parsed, str):
    print("No parser template matched; store raw output for review")
else:
    for row in parsed:
        print(row)
```

If parsing drives a blocking decision, keep the raw command output alongside
the parsed result so an operator can inspect mismatches.

## Guarded Config Pattern

```python
import os

commands = [
    "interface GigabitEthernet0/1",
    "description CHANGE-1234 UPLINK-TO-CORE",
]

apply_changes = os.environ.get("APPLY_NETWORK_CHANGES") == "1"

if not apply_changes:
    print("Dry run only. Candidate commands:")
    print("\n".join(commands))
else:
    with ConnectHandler(**device) as conn:
        conn.enable()
        before = conn.send_command("show running-config interface GigabitEthernet0/1")
        output = conn.send_config_set(commands)
        after = conn.send_command("show running-config interface GigabitEthernet0/1")
        print(before)
        print(output)
        print(after)
        print("Verify behavior before saving startup config.")
```

Saving the config is a separate approval step. In production, include a rollback
snippet and capture before/after evidence in the change record.

## Review Checklist

- Does the script identify an explicit inventory source?
- Are credentials absent from source, logs, and exception messages?
- Are `conn_timeout`, `auth_timeout`, and command `read_timeout` set?
- Are failures reported per device without stopping the whole batch?
- Does the script avoid broad scans and unbounded concurrency?
- Are config changes behind a dry-run or explicit operator flag?
- Is `save_config()` separate from the initial push and tied to verification?

## Anti-Patterns

- Hardcoding passwords, enable secrets, or private keys in source.
- Sending config commands as the default code path.
- Running automation against a CIDR range instead of a reviewed inventory.
- Logging full running configs to shared systems without sanitization.
- Treating parser success as proof that the device state is correct.

## See Also

- Optional workflow reference: `ecc-cisco-ios-patterns` (optional skill; if unavailable, inspect IOS configuration modes, wildcard masks, ACL direction, and proposed rollback)
- Optional workflow reference: `ecc-network-config-validation` (optional skill; if unavailable, inspect destructive commands, source restrictions, addressing, and referenced policies)
- Optional workflow reference: `ecc-network-interface-health` (optional skill; if unavailable, compare supplied timed interface counters from both ends of each link)
