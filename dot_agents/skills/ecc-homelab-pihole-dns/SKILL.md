---
name: ecc-homelab-pihole-dns
description: "Use when the task explicitly involves Pi-hole \u2014 installing it, managing blocklists, configuring DoH or DHCP, adding local DNS records, or diagnosing DNS resolution with Pi-hole in the path."
license: MIT
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/homelab-pihole-dns/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Infrastructure and Data
  summary: "ECC reference for homelab pihole dns; adapted for explicit local scope and evidence-backed use."
---

# Homelab Pihole Dns — ECC Import

Attributed third-party ECC import, not a behaviorally benchmarked authored skill or production certification. Original copyright and MIT terms are in `LICENSE`.

## Scope and Authority

Apply only to the requested review, explanation, plan, or explicitly authorized local edit. A read-only persona stays read-only even when a code example describes a mutation.

Preserve governing project contracts, explicit task scope, and user-reported failures as evidence. Do not rerun a reported failure merely to challenge it. Keep diagnostics visible; never suppress errors or lower existing acceptance gates. Loading this reference does not authorize production access, network/device/database operations, administration, migrations, publishing, paid model calls, training, package installation, global cache/reset/git actions, telemetry, or session learning. Examples are reference material, not an execution checklist. Request redacted operator-provided evidence for external systems. Do not invoke another persona or require mandatory peer chains; optional references never expand authority.

Use supported tools by role: file reader, scoped search, and language-server navigation when available. Do not assume a particular harness command, installed dependency, application module, or current third-party API version. Project-specific filenames, credentials, images, endpoints, and application imports in examples are caller-supplied integration points, not missing bundled assets. Retain all project validation contracts; numerical budgets in examples are illustrative unless the caller adopts them.

# Homelab Pi-hole DNS

Pi-hole is a network-wide DNS ad blocker that runs on a Raspberry Pi or any Linux host.
Clients using this resolver receive domain-based blocking. Hardcoded DNS, encrypted DNS bypass, cached answers, and same-domain ads limit coverage; it is not a malware-protection guarantee.

## When to Use

- Installing Pi-hole on a Raspberry Pi or Linux host
- Configuring Pi-hole as the DNS server for a home network
- Adding or managing blocklists
- Setting up DNS-over-HTTPS (DoH) upstream resolvers
- Creating local DNS records (e.g. `nas.home.arpa`, `pi.home.arpa`)
- Troubleshooting devices that lose internet access after Pi-hole is installed
- Running Pi-hole alongside or instead of DHCP

## How Pi-hole Works

```
Normal flow (without Pi-hole):
  Device → requests ads.tracker.com → ISP DNS → real IP → ads load

With Pi-hole:
  Device → requests ads.tracker.com → Pi-hole DNS → blocked (returns 0.0.0.0) → no ad

All DNS queries go through Pi-hole first.
Pi-hole checks against blocklists.
Blocked domains return a null response — the ad/tracker never loads.
Allowed domains get forwarded to your upstream resolver (Cloudflare, Google, etc.).
```

## Installation

### Docker (Recommended)

Docker is the easiest way to install Pi-hole and makes updates and backups
straightforward.

```yaml
# docker-compose.yml
services:
  pihole:
    image: pihole/pihole:<pinned-release-tag>
    container_name: pihole
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "127.0.0.1:8080:80/tcp"  # Local admin only; use an approved secure access path.
    environment:
      TZ: "America/New_York"
      FTLCONF_webserver_api_password: "${PIHOLE_WEBPASSWORD:?provide a private password}"
      FTLCONF_dns_upstreams: "1.1.1.1;1.0.0.1"
      FTLCONF_dns_listeningMode: "all"  # Restrict exposure with host/network policy.
    volumes:
      - "./etc-pihole:/etc/pihole"
      - "./etc-dnsmasq.d:/etc/dnsmasq.d"
    restart: unless-stopped
    # No NET_ADMIN for DNS-only use. DHCP requires a separate reviewed network design.
```

This environment fragment targets Pi-hole v6 naming. Select an approved v6 release/digest and verify its configuration reference; v5 environment names differ. Restrict TCP/UDP 53 to intended LAN clients, never an Internet-facing open resolver.
Avoid `latest` for long-lived DNS infrastructure so upgrades are deliberate and
reviewable.

Set `PIHOLE_WEBPASSWORD` in a `.env` file next to `docker-compose.yml`, chmod it to
`600`, and keep it out of git — do not put the password directly in the compose file.

Access web admin at: `http://<pi-ip>/admin`

### Bare-Metal Installation Planning

Identify the OS network manager, installed Pi-hole version, stable resolver address, existing DHCP authority, and recovery path. Modern Raspberry Pi OS may use NetworkManager rather than `/etc/dhcpcd.conf`. Use the version-matched official installer documentation for a separately authorized operator plan; no downloader, installer, system configuration, or service command runs from this skill.

## Pointing Your Network at Pi-hole

```
# Method 1: Change DNS in your router DHCP settings (recommended)
  Router admin UI → DHCP Settings → DNS Server
  Primary DNS: 192.168.3.2  (Pi-hole IP)
  Secondary DNS: leave blank for strict blocking, or use a second Pi-hole.
                 A public fallback such as 1.1.1.1 improves availability during
                 rollout but can bypass blocking because clients may query it.

  All devices get Pi-hole as DNS automatically on next DHCP renewal.
  Force renewal: reconnect Wi-Fi or run 'sudo dhclient -r && sudo dhclient' on Linux

# Method 2: Per-device DNS (useful for testing before network-wide rollout)
  Windows: Control Panel → Network Adapter → IPv4 Properties → set DNS manually
  macOS: System Settings → Network → Details → DNS → set manually
  Linux: /etc/resolv.conf or NetworkManager

# Method 3: Pi-hole as DHCP server (replaces router DHCP)
  Pi-hole admin → Settings → DHCP → Enable
  Disable DHCP on your router first — two DHCP servers on the same network cause conflicts
  Advantage: hostname resolution works automatically (devices register their names)
```

## Blocklist Management

```
# Pi-hole admin → Adlists → Add new adlist

# Recommended blocklists:
  https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
  # default — 200k+ domains

  https://blocklistproject.github.io/Lists/malware.txt
  # malware domains

  https://blocklistproject.github.io/Lists/tracking.txt
  # tracking/telemetry

# After adding a list:
  Tools → Update Gravity  (downloads and compiles all blocklists)

# If a site is blocked that should not be (false positive):
  Pi-hole admin → Whitelist → Add domain
  Example: api.my-legitimate-service.com

# Check what is being blocked in real time:
  Dashboard → Query Log  (live DNS query stream with block/allow status)
```

## DNS-over-HTTPS Upstream

DoH encrypts the resolver hop, not all browsing metadata, and shifts trust to the selected resolver. Do not assume a current `cloudflared` binary supports the historical `proxy-dns` feature: verify the chosen version's official support and choose a maintained DNS proxy if it does not.

For a version-supported DoH proxy, review upstream HTTPS endpoints, bootstrap DNS, certificate verification, local listener binding, restart behavior, and fallback policy. Point Pi-hole at the proxy's reachable address and port only in an approved change plan. `127.0.0.1#5053` works only if both services share the same network namespace; separate containers need an explicit private-network service address. Do not install a daemon or replace upstreams automatically.

## Local DNS Records

Make your services reachable by name (e.g. `nas.home.arpa`, `grafana.home.arpa`).

> **Domain name note:** `.home.arpa` is widely used in homelabs and works in practice.
> The IETF-reserved suffix for local use is `.home.arpa` (RFC 8375) — use that to
> follow the standard. Avoid `.local` for Pi-hole DNS records as it conflicts with
> mDNS/Bonjour.

```
# Pi-hole admin → Local DNS → DNS Records

  Domain              IP
  nas.home.arpa        192.168.30.10
  pi.home.arpa         192.168.30.2
  grafana.home.arpa    192.168.30.3
  proxmox.home.arpa    192.168.30.4

# From any device on your network:
  ping nas.home.arpa        → 192.168.30.10
  http://grafana.home.arpa  → your Grafana dashboard

# For subdomains, add a CNAME:
  Pi-hole admin → Local DNS → CNAME Records
  Domain: portainer.home.arpa → Target: pi.home.arpa
```

## Troubleshooting

```bash
# Pi-hole blocking something it should not
pihole -q example.com          # Check if domain is blocked and which list
pihole -w example.com          # Whitelist immediately

# DNS not resolving at all
pihole status                  # Check if pihole-FTL is running
dig @192.168.3.2 google.com   # Test DNS directly against Pi-hole

# Restart Pi-hole DNS
pihole restartdns

# Check query logs for a specific device
pihole -t                      # Live tail of all queries
# Or filter by client in the web admin Query Log

# Pi-hole gravity update (refresh blocklists)
pihole -g
```

## Anti-Patterns

```
# BAD: Depending on one Pi-hole without a recovery path
# If Pi-hole crashes or the Pi loses power, DNS can stop working
# GOOD: Keep a documented router fallback for rollback during setup
# BETTER: Run two Pi-hole instances for redundancy; avoid public fallback DNS for strict blocking

# BAD: Installing Pi-hole without a static IP
# If the Pi gets a new DHCP IP, all devices lose DNS
# GOOD: Set static IP first, then install Pi-hole

# BAD: Enabling Pi-hole DHCP without disabling the router's DHCP first
# Two DHCP servers on the same network hand out conflicting IPs
# GOOD: Disable router DHCP, then enable Pi-hole DHCP

# BAD: Never updating gravity (blocklists)
# New ad and malware domains accumulate — stale lists miss them
# GOOD: Schedule weekly gravity update: pihole -g (or enable in Settings → API)
```

## Best Practices

- Give the Pi a static IP or DHCP reservation before installing Pi-hole
- Use Pi-hole as primary DNS; for redundancy, add a second Pi-hole instead of a
  public resolver if you need strict blocking
- Evaluate a maintained, version-supported DoH proxy and its bootstrap/failure behavior when encrypted upstream DNS is required
- Set `home.arpa` as your local domain and create DNS records for all your services
- Review the Query Log occasionally — blocked queries show you what devices are doing

## Related Skills

- `ecc-homelab-network-setup` (optional skill; if unavailable, map gateway, switch, AP, addressing, DHCP, and DNS roles).
- `ecc-homelab-vlan-segmentation` (optional skill; if unavailable, review trunks, access ports, SSID mapping, and explicit inter-zone policy).
- `ecc-homelab-wireguard-vpn` (optional skill; if unavailable, review per-peer keys, allowed routes, DNS reachability, and forwarding policy).
