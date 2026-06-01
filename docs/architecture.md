# Arquitetura e Fluxo

Diagramas do funcionamento do VCERT com o CyberArk Certificate Manager. (Renderizados pelo GitHub via Mermaid.)

## Fluxo geral de renovação

```mermaid
flowchart TD
    A([cron / systemd timer]) --> B[vcert run -f playbook.yaml]
    B --> C{Dentro da janela<br/>renewBefore?}
    C -- Nao --> Z([Encerra: nada a fazer])
    C -- Sim --> D[Gera CSR + chave local<br/>O, OU, algoritmo, keySize]
    D --> E[CyberArk Certificate Manager<br/>aplica a policy/zone e emite]
    E --> F[beforeInstallAction<br/>ACAO PRE]
    F --> G[Grava arquivos<br/>PEM / PKCS12 / JKS<br/>+ backup .bak]
    G --> H[afterInstallAction<br/>ACAO POS: reload/restart]
    H --> I([Servico usando o<br/>certificado novo])
```

## Componentes

```mermaid
flowchart LR
    subgraph Linux["Host Linux"]
        VC[vcert binario]
        PB[playbook.yaml]
        SC[scripts pre/pos]
        FS[(arquivos do cert<br/>/etc/ssl ...)]
        SVC[HAProxy / Apache / Tomcat]
    end
    CM[CyberArk Certificate Manager<br/>TPP ou SaaS]

    PB --> VC
    VC <-->|token / API key| CM
    VC --> FS
    VC --> SC
    FS --> SVC
    SC -->|reload / restart| SVC
```

## Por serviço

### HAProxy
Espera **um único PEM** = `cert + chain + key`. O `vcert` grava os três separados e o `post-renew-haproxy.sh` concatena e faz `reload` (sem downtime).

```mermaid
flowchart LR
    V[vcert: PEM separados<br/>lb.crt / lb.chain.crt / lb.key] --> S[post-renew-haproxy.sh<br/>cat &gt; lb.pem]
    S --> C{haproxy -c?}
    C -- ok --> R[systemctl reload haproxy]
    C -- erro --> X[aborta / mantem anterior]
```

### Apache (httpd)
Usa **PEM separados** direto nas diretivas `SSLCertificate*`. O `post-renew-apache.sh` valida (`-t`) e faz `graceful`.

```mermaid
flowchart LR
    V[vcert: www.crt / www-chain.crt / www.key] --> A{apachectl -t / httpd -t?}
    A -- ok --> R[graceful reload]
    A -- erro --> X[aborta / mantem anterior]
```

### Tomcat
Usa **keystore PKCS#12** (ou JKS). O `post-renew-tomcat.sh` ajusta permissões e faz `restart` (Tomcat não recarrega keystore a quente).

```mermaid
flowchart LR
    V[vcert: app.p12] --> P[post-renew-tomcat.sh<br/>chown/chmod]
    P --> R[systemctl restart tomcat]
    R --> C{is-active?}
    C -- sim --> OK[ok]
    C -- nao --> X[erro / alerta]
```

### Windows / IIS
Instala no **Windows Certificate Store (CAPI)**; o `post-renew-iis.ps1` (PowerShell) faz o **bind** do novo thumbprint no site do IIS — sem reiniciar o serviço.

```mermaid
flowchart LR
    V[vcert: format CAPI<br/>LocalMachine\My] --> P[post-renew-iis.ps1]
    P --> T[Acha cert pelo<br/>FriendlyName mais novo]
    T --> B{Binding HTTPS<br/>existe?}
    B -- nao --> N[New-WebBinding<br/>SNI se host header]
    B -- sim --> A[AddSslCertificate thumbprint]
    N --> A
    A --> OK([Site IIS com<br/>certificado novo])
```

### Nginx
Usa **fullchain** (cert+chain) em um arquivo e a chave em outro. O `post-renew-nginx.sh` monta o fullchain, valida (`nginx -t`) e faz `reload`.

```mermaid
flowchart LR
    V[vcert: www.crt / www.chain.crt / www.key] --> S[post-renew-nginx.sh<br/>cat cert+chain &gt; fullchain]
    S --> C{nginx -t?}
    C -- ok --> R[systemctl reload nginx]
    C -- erro --> X[aborta / mantem anterior]
```

### Azure Application Gateway
O gateway não lê arquivos locais. O `vcert` emite um **.pfx** e o `post-renew-azure-appgw.sh` envia via **Azure CLI** (`az ... ssl-cert update`).

```mermaid
flowchart LR
    V[vcert: www.pfx] --> S[post-renew-azure-appgw.sh]
    S --> Q{ssl-cert existe?}
    Q -- sim --> U[az ... ssl-cert update]
    Q -- nao --> C[az ... ssl-cert create]
    U --> GW([Application Gateway<br/>com cert novo])
    C --> GW
```

### AWS ALB / NLB (ACM)
Os LBs da AWS usam certificados do **ACM** por ARN. O `post-renew-aws-acm.sh` faz `import-certificate` reusando o mesmo **ARN** — o listener pega o novo automaticamente.

```mermaid
flowchart LR
    V[vcert: www.crt / www.chain.crt / www.key] --> S[post-renew-aws-acm.sh]
    S --> Q{ACM_CERT_ARN<br/>definido?}
    Q -- sim --> R[aws acm import-certificate<br/>--certificate-arn ARN]
    Q -- nao --> N[import novo + loga ARN]
    R --> LB([ALB/NLB listener<br/>com cert novo])
```

## Revogação

Ação pontual via CLI (não é parte do playbook). Detalhes em [`revocation.md`](revocation.md).

```mermaid
flowchart LR
    A[vcert revoke] --> B{Seletor}
    B -- --id DN --> C[CyberArk Certificate Manager]
    B -- --thumbprint SHA1 --> C
    C --> D{--no-retire?}
    D -- sim --> E([Revogado, objeto<br/>reemitivel])
    D -- nao --> F([Revogado + desabilitado])
```
