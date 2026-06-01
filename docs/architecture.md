# Architecture and Flow

Diagrams of how VCERT works with the CyberArk Certificate Manager. (Rendered by GitHub via Mermaid.)

## General renewal flow

```mermaid
flowchart TD
    A([cron / systemd timer]) --> B[vcert run -f playbook.yaml]
    B --> C{Within the<br/>renewBefore window?}
    C -- No --> Z([Exit: nothing to do])
    C -- Yes --> D[Generate CSR + local key<br/>O, OU, algorithm, keySize]
    D --> E[CyberArk Certificate Manager<br/>applies the policy/zone and issues]
    E --> G[Write files<br/>PEM / PKCS12 / JKS<br/>+ .bak backup]
    G --> H[afterInstallAction<br/>POST ACTION: reload/restart]
    H --> I([Service using the<br/>new certificate])
```

> The playbook has no native pre-install hook. Optional PRE steps run from a wrapper around `vcert run` (see [`../scripts/vcert-run.sh`](../scripts/vcert-run.sh)); only `afterInstallAction` (POST) is supported by the playbook.

## Components

```mermaid
flowchart LR
    subgraph Linux["Linux host"]
        VC[vcert binary]
        PB[playbook.yaml]
        SC[pre/post scripts]
        FS[(certificate files<br/>/etc/ssl ...)]
        SVC[HAProxy / Apache / Tomcat]
    end
    CM[CyberArk Certificate Manager<br/>TPP or SaaS]

    PB --> VC
    VC <-->|token / API key| CM
    VC --> FS
    VC --> SC
    FS --> SVC
    SC -->|reload / restart| SVC
```

## Per service

### HAProxy
Expects a **single PEM** = `cert + chain + key`. VCERT writes the three separately and `post-renew-haproxy.sh` concatenates them and runs `reload` (no downtime).

```mermaid
flowchart LR
    V[vcert: separate PEM<br/>lb.crt / lb.chain.crt / lb.key] --> S[post-renew-haproxy.sh<br/>cat &gt; lb.pem]
    S --> C{haproxy -c?}
    C -- ok --> R[systemctl reload haproxy]
    C -- error --> X[abort / keep previous]
```

### Apache (httpd)
Uses **separate PEM files** directly in the `SSLCertificate*` directives. `post-renew-apache.sh` validates (`-t`) and runs `graceful`.

```mermaid
flowchart LR
    V[vcert: www.crt / www-chain.crt / www.key] --> A{apachectl -t / httpd -t?}
    A -- ok --> R[graceful reload]
    A -- error --> X[abort / keep previous]
```

### Tomcat
Uses a **PKCS#12 keystore** (or JKS). `post-renew-tomcat.sh` fixes permissions and runs `restart` (Tomcat does not hot-reload the keystore).

```mermaid
flowchart LR
    V[vcert: app.p12] --> P[post-renew-tomcat.sh<br/>chown/chmod]
    P --> R[systemctl restart tomcat]
    R --> C{is-active?}
    C -- yes --> OK[ok]
    C -- no --> X[error / alert]
```

### Windows / IIS
Installs into the **Windows Certificate Store (CAPI)**; `post-renew-iis.ps1` (PowerShell) **binds** the new thumbprint to the IIS site — without restarting the service.

```mermaid
flowchart LR
    V[vcert: format CAPI<br/>LocalMachine\My] --> P[post-renew-iis.ps1]
    P --> T[Find cert by newest<br/>FriendlyName]
    T --> B{HTTPS binding<br/>exists?}
    B -- no --> N[New-WebBinding<br/>SNI if host header]
    B -- yes --> A[AddSslCertificate thumbprint]
    N --> A
    A --> OK([IIS site with<br/>new certificate])
```

### Nginx
Uses a **fullchain** (cert+chain) in one file and the key in another. `post-renew-nginx.sh` builds the fullchain, validates (`nginx -t`), and runs `reload`.

```mermaid
flowchart LR
    V[vcert: www.crt / www.chain.crt / www.key] --> S[post-renew-nginx.sh<br/>cat cert+chain &gt; fullchain]
    S --> C{nginx -t?}
    C -- ok --> R[systemctl reload nginx]
    C -- error --> X[abort / keep previous]
```

### Azure Application Gateway
The gateway does not read local files. VCERT issues a **.pfx** and `post-renew-azure-appgw.sh` uploads it via the **Azure CLI** (`az ... ssl-cert update`).

```mermaid
flowchart LR
    V[vcert: www.pfx] --> S[post-renew-azure-appgw.sh]
    S --> Q{ssl-cert exists?}
    Q -- yes --> U[az ... ssl-cert update]
    Q -- no --> C[az ... ssl-cert create]
    U --> GW([Application Gateway<br/>with new cert])
    C --> GW
```

### AWS ALB / NLB (ACM)
AWS LBs use **ACM** certificates by ARN. `post-renew-aws-acm.sh` runs `import-certificate` reusing the same **ARN** — the listener picks up the new one automatically.

```mermaid
flowchart LR
    V[vcert: www.crt / www.chain.crt / www.key] --> S[post-renew-aws-acm.sh]
    S --> Q{ACM_CERT_ARN<br/>set?}
    Q -- yes --> R[aws acm import-certificate<br/>--certificate-arn ARN]
    Q -- no --> N[import new + log ARN]
    R --> LB([ALB/NLB listener<br/>with new cert])
```

## Revocation

A one-off CLI action (not part of the playbook). Details in [`revocation.md`](revocation.md).

```mermaid
flowchart LR
    A[vcert revoke] --> B{Selector}
    B -->|"by --id (DN)"| C[CyberArk Certificate Manager]
    B -->|"by --thumbprint (SHA1)"| C
    C --> D{"--no-retire?"}
    D -->|yes| E([Revoked, object<br/>re-enrollable])
    D -->|no| F([Revoked + retired])
```
