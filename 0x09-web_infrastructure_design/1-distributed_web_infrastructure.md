# Distributed Web Infrastructure for www.foobar.com

This document describes a three-server web infrastructure hosting the website `www.foobar.com`. It uses a distributed setup with a load balancer (HAProxy), web server (Nginx), application server, application files, and a MySQL database in a Primary-Replica cluster. The infrastructure is explained with a diagram, component details, and identified issues.

## Process

```
Flow:
1. User enters www.foobar.com in browser.
2. DNS resolves www.foobar.com to the Load Balancer’s IP (A record).
3. HAProxy distributes the HTTP request to Server 2 or Server 3 (Nginx).
4. Nginx serves static content or forwards dynamic requests to the Application Server (PHP-FPM).
5. Application Server processes code, queries MySQL Primary (Server 2) for writes or either Primary/Replica for reads.
6. Response sent back via Nginx and HAProxy to User's Browser.
```

## Component Explanations and Additions

### Additional Elements and Their Purpose
1. **2 Servers (Server 2 and Server 3)**:
   - **Why**: Two servers are added to provide redundancy and distribute workload. Each hosts Nginx, the application server (PHP-FPM), and application files, allowing load balancing and fault tolerance. Server 2 also hosts the MySQL Primary, and Server 3 hosts the MySQL Replica for database redundancy.
   - The Primary (Server 2) handles writes, while the Replica (Server 3) handles reads, improving database performance and redundancy.

2. **1 Load Balancer (HAProxy)**:
   - **Why**: HAProxy distributes incoming HTTP requests across Server 2 and Server 3 to balance traffic, improve performance, and ensure availability if one server fails.

### Load Balancer Configuration
- **Distribution Algorithm**: The HAProxy load balancer is configured with a **Round-Robin** algorithm.
  - **How It Works**: Round-Robin distributes incoming requests sequentially across available servers (Server 2 and Server 3). For example, the first request goes to Server 2, the second to Server 3, the third to Server 2, and so on. This ensures an even distribution of traffic, assuming both servers have similar capacity.

- **Active-Active vs. Active-Passive**:
  - **Setup**: The load balancer is configured for an **Active-Active** setup.
    - **Active-Active**: Both Server 2 and Server 3 are actively handling requests simultaneously, as HAProxy distributes traffic to both. This maximizes resource utilization and supports higher traffic loads.
    - **Active-Passive**: Only one server (e.g., Server 2) handles requests, while the other (Server 3) remains on standby, only receiving traffic if the active server fails. This prioritizes failover over performance.
  - **Why Active-Active**: Active-Active is chosen to utilize both servers Ascending-Descending: servers for load balancing and redundancy, improving throughput and availability.

### Database Primary-Replica (Master-Slave) Cluster
- **How It Works**:
  - In a MySQL Primary-Replica cluster, the **Primary node** (Server 2) accepts both read and write queries. All write operations (INSERT, UPDATE, DELETE) are performed on the Primary, which then replicates these changes to the **Replica node** (Server 3) asynchronously. The Replica handles read-only queries (SELECT), offloading read traffic from the Primary to improve performance.
  - Replication involves the Primary logging changes to a binary log, which the Replica reads and applies to its own database copy, ensuring data consistency (with potential slight delay).

- **Difference Between Primary and Replica**:
  - **Primary Node**: Handles both read and write operations. The application server sends all write requests (e.g., user registrations, content updates) to the Primary, which is the authoritative source of data.
  - **Replica Node**: Handles only read operations (e.g., fetching user data or content). The application server can query the Replica for read-heavy tasks to reduce load on the Primary, improving scalability. The Replica is a read-only copy and cannot accept writes directly.

## Issues with the Infrastructure

1. **Single Points of Failure (SPOF)**:
   - **Load Balancer (HAProxy)**: The single HAProxy server (Server 1) is a SPOF. If it fails, the website becomes inaccessible, as it’s the only entry point for traffic.
   - **MySQL Primary (Server 2)**: The Primary database is a SPOF for write operations. If it fails, no new data can be written, though the Replica can still serve read requests until the Primary is restored.

2. **Security Issues**:
   - **No Firewall**: The infrastructure lacks firewalls, leaving servers exposed to unauthorized access or attacks (e.g., DDoS, brute-force attempts).
   - **No HTTPS**: The setup uses HTTP instead of HTTPS, meaning data between the user’s browser and the load balancer (and servers) is unencrypted, risking data interception or tampering.

3. **No Monitoring**:
   - There are no monitoring tools to track server health, performance, or traffic patterns. Without monitoring, issues like high CPU usage, memory leaks, or traffic spikes go undetected until they cause outages or performance degradation.

## Conclusion
This three-server infrastructure improves redundancy and scalability over a single-server setup by distributing traffic across two web/application servers and using a MySQL Primary-Replica cluster. However, the load balancer and Primary database remain SPOFs, security is compromised without firewalls or HTTPS, and lack of monitoring limits proactive issue detection. Adding a second load balancer, enabling HTTPS, implementing firewalls, and deploying monitoring tools (e.g., Prometheus, Grafana) would enhance reliability and security.