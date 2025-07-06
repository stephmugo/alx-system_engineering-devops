## Background Context

In this project, we configure the firewall on `web-01` to enhance security and perform port forwarding. This involves:
- Blocking all incoming traffic except specific ports (22, 80, 443)
- Forwarding traffic from port 8080 to port 80

---

## Tasks

### Task 0. Block all incoming traffic but

**File:** `0-block_all_incoming_traffic_but`  
**Description:** UFW commands that block all incoming traffic except ports:
- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS)

#### Example Commands:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

---

### Task 1. Port forwarding

**File:** `100-port_forwarding`  
**Description:** UFW configuration that redirects incoming traffic on port 8080 to port 80.

#### Example Configuration in `/etc/ufw/before.rules`:

```bash
*nat
:PREROUTING ACCEPT [0:0]
-A PREROUTING -p tcp --dport 8080 -j REDIRECT --to-port 80
COMMIT
```

Add this above the `*filter` section. After editing the file, reload UFW:

```bash
sudo ufw disable
sudo ufw enable
```

### Verification

```bash
curl -sI web-01.holberton.online:8080
# Should return same response as port 80 if forwarding is working.
```

---