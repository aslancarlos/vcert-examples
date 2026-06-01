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
