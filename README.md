# 🏗️ Elham Progress — Digital Operations & Security Master Guide

<div align="center">

![Elham Progress](https://elham-progress.base44.app)
![Website](https://elhamco.com)
![Location](https://img.shields.io/badge/Location-Riyadh%2C%20KSA-2ECC71?style=for-the-badge)
![Classification](https://img.shields.io/badge/Classification-CONFIDENTIAL-C0392B?style=for-the-badge)

**Complete operational guide covering Security · Pentest · SEO · Logging · Revenue · Vendor & Client Management**

</div>

---

## 📋 Table of Contents

| # | Section | Description |
|---|---------|-------------|
| 01 | [Security Hardening](#01-security-hardening) | WAF, SSL, Headers, Admin Lockdown |
| 02 | [Penetration Testing](#02-penetration-testing) | Full pentest lifecycle guide |
| 03 | [Log Collection & SIEM](#03-log-collection--siem) | ELK Stack, Cloudflare logs, Alerting |
| 04 | [SEO Strategy](#04-seo-strategy) | Technical, Local, Content, Keywords |
| 05 | [Revenue Generation](#05-revenue-generation) | WhatsApp, Lead Capture, Portfolio |
| 06 | [Vendor Management](#06-vendor-management) | Evaluation, NDA, Access Control |
| 07 | [Client Management](#07-client-management) | CRM, Onboarding, Retention |
| 08 | [Compliance & Legal](#08-compliance--legal) | PDPL, Privacy Policy, OSHA |
| 09 | [90-Day Roadmap](#09-90-day-roadmap) | Prioritized execution plan |

---

## 🚨 Current Status of elhamco.com

```
✅ Domain SSL        — Active
❌ WAF               — Not configured
❌ Security Headers  — Missing
❌ Logging/SIEM      — Not configured
❌ Google Analytics  — Not installed
❌ Search Console    — Not verified
❌ WhatsApp Button   — Missing
❌ Service Pages     — Single page (no dedicated pages)
❌ Google Business   — Not claimed
❌ Admin 2FA         — Unknown
```

---

## 01 Security Hardening

> 📁 Files: [`security/`](./security/)

### Step 1 — Cloudflare WAF

```bash
# Steps:
# 1. Go to cloudflare.com → Add Site → elhamco.com → Free Plan
# 2. Change nameservers at domain registrar to Cloudflare's NS
# 3. Security → WAF → Enable Managed Rules + OWASP Core
# 4. Security → Bots → Bot Fight Mode: ON
# 5. WAF → Rate Limiting → 5 req/min on contact form POST URL
```

### Step 2 — SSL/TLS Hardening

```bash
# Cloudflare → SSL/TLS → Full (Strict) mode
# Minimum TLS Version: 1.2
# TLS 1.3: ON
# HSTS: max-age=31536000; includeSubDomains
# Test: https://www.ssllabs.com/ssltest/ → Target: A+
```

### Step 3 — HTTP Security Headers

See [`security/headers.htaccess`](./security/headers.htaccess) for complete Apache config.

```apache
<IfModule mod_headers.c>
  Header always set X-Frame-Options "DENY"
  Header always set X-Content-Type-Options "nosniff"
  Header always set Referrer-Policy "strict-origin-when-cross-origin"
  Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
  Header always set Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:;"
  Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
</IfModule>
```

Verify at: [securityheaders.com](https://securityheaders.com) — Target: **A or A+**

### Step 4 — Admin Lockdown Checklist

See [`security/admin-hardening-checklist.md`](./security/admin-hardening-checklist.md)

- [ ] Cloudflare Access: restrict `/admin` to office IPs only
- [ ] Enable 2FA on ALL admin accounts (Google Authenticator / Authy)
- [ ] Change default `admin` username
- [ ] Set 16+ character passwords (use Bitwarden)
- [ ] Disable XML-RPC (WordPress): see [`security/disable-xmlrpc.htaccess`](./security/disable-xmlrpc.htaccess)

### Step 5 — Uptime Monitoring

```bash
# UptimeRobot (free): https://uptimerobot.com
# Monitor 1: https://elhamco.com       — every 5 min
# Monitor 2: https://elhamco.com/admin — every 5 min
# Alert: SMS + Email on any downtime
```

---

## 02 Penetration Testing

> 📁 Files: [`security/pentest/`](./security/pentest/)

> ⚠️ **Only test systems you own or have explicit written authorization to test.**

### Phase 1 — Passive Reconnaissance

```bash
# WHOIS & DNS
whois elhamco.com
dig elhamco.com ANY
nslookup elhamco.com

# Subdomain Discovery
amass enum -d elhamco.com
sublist3r -d elhamco.com

# Certificate Transparency
# https://crt.sh/?q=%25.elhamco.com

# Technology Fingerprinting
whatweb elhamco.com
# Also: https://builtwith.com/elhamco.com

# Google Dorking
# site:elhamco.com
# site:elhamco.com filetype:pdf
# site:elhamco.com inurl:admin
```

### Phase 2 — Active Scanning

```bash
# Port Scanning
nmap -sV -sC elhamco.com
nmap -p- -T4 elhamco.com
nmap -A -O elhamco.com

# Directory Discovery
gobuster dir \
  -u https://elhamco.com \
  -w /usr/share/wordlists/dirb/common.txt \
  -x php,html,txt,zip,bak

# Web Vulnerability Scan
nikto -h https://elhamco.com

# SSL Testing
sslyze --regular elhamco.com
# Also: https://www.ssllabs.com/ssltest/
```

### Phase 3 — Manual Testing

```bash
# SQL Injection (test in all form fields and URL params)
' OR '1'='1
' OR 1=1--
admin'--
1; DROP TABLE users--

# XSS (test in all input fields)
<script>alert('XSS')</script>
<img src=x onerror=alert(1)>
"><script>alert(document.cookie)</script>

# OWASP ZAP Automated Scan
# Download: https://www.zaproxy.org
# Automated Scan → Enter https://elhamco.com → Attack
# Export HTML report on completion
```

### Severity Rating Guide

| Severity | Fix Timeline | Example |
|----------|-------------|---------|
| 🔴 Critical | 24 hours | RCE, SQLi, admin takeover |
| 🟠 High | 72 hours | XSS, sensitive data exposure |
| 🟡 Medium | 1 week | CSRF, insecure redirects |
| 🟢 Low | 1 month | Information disclosure |
| ⚪ Info | Next cycle | Best practice violations |

See template: [`security/pentest/report-template.md`](./security/pentest/report-template.md)

---

## 03 Log Collection & SIEM

> 📁 Files: [`logs/`](./logs/)

### Step 1 — Apache Server Logs

```apache
# /etc/apache2/apache2.conf or httpd.conf
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
CustomLog /var/log/apache2/access.log combined
ErrorLog  /var/log/apache2/error.log
LogLevel  warn

# Verify live:
tail -f /var/log/apache2/access.log
```

Log rotation config: [`logs/logrotate-apache.conf`](./logs/logrotate-apache.conf)

### Step 2 — ELK Stack Setup

```bash
# Ubuntu 22.04 server (4GB RAM, 2 vCPU minimum)
sudo apt update && sudo apt install openjdk-11-jre -y

# Install Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | \
  sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo apt update && sudo apt install elasticsearch -y
sudo systemctl enable elasticsearch && sudo systemctl start elasticsearch

# Install Kibana
sudo apt install kibana -y
sudo systemctl enable kibana && sudo systemctl start kibana
# Access at: http://your-server:5601

# Install Logstash
sudo apt install logstash -y

# Install Filebeat on web server
sudo apt install filebeat -y
```

Full config files in [`logs/elk/`](./logs/elk/)

### Step 3 — Alert Rules

| Alert | Threshold | Action |
|-------|-----------|--------|
| Failed logins | 5+ in 5 min from same IP | Email + Block IP in Cloudflare |
| 404 spike | 50+ per minute | Email (directory scanning) |
| 5xx errors | 10+ per minute | Email + SMS (server issue) |
| New admin login | Any from new IP | Immediate email |
| SQL in URL params | Any match | Critical alert |
| Large response | >50MB | Email (data exfiltration) |

---

## 04 SEO Strategy

> 📁 Files: [`seo/`](./seo/)

### Step 1 — Technical Setup

```bash
# 1. Google Search Console
#    search.google.com/search-console
#    Verify via Cloudflare DNS TXT record

# 2. Google Analytics 4
#    analytics.google.com → Get G-XXXXXXXXXX Measurement ID
#    Add to every page <head>:
```

```html
<!-- Google Analytics 4 -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

```bash
# 3. Submit sitemap
#    Create sitemap.xml → upload to server root
#    Submit at Google Search Console → Sitemaps
#    Also submit at: https://www.bing.com/webmasters

# 4. Page Speed targets
#    Test: https://pagespeed.web.dev
#    Mobile: 70+   Desktop: 85+
```

See: [`seo/sitemap-template.xml`](./seo/sitemap-template.xml)

### Step 2 — Keyword Strategy

| Service Page | English Keyword | Arabic Keyword |
|---|---|---|
| Scaffold Rental | scaffold rental Riyadh | تأجير سقالات الرياض |
| Formwork | formwork supplier Saudi Arabia | قوالب خرسانية السعودية |
| Concrete Repair | concrete repair contractor Riyadh | اصلاح الخرسانة الرياض |
| Civil Construction | civil construction company KSA | شركة مقاولات مدنية السعودية |
| Facility Management | facility management Riyadh | إدارة المرافق الرياض |
| Pipeline Construction | pipeline contractor Saudi Arabia | مقاول خطوط الأنابيب |
| Site Preparation | site preparation company Riyadh | تجهيز مواقع البناء الرياض |

### Step 3 — Schema Markup

See full schema: [`seo/schema-localbusiness.json`](./seo/schema-localbusiness.json)

```json
{
  "@context": "https://schema.org",
  "@type": ["LocalBusiness", "ConstructionContractor"],
  "name": "Elham Progress Construction Co.",
  "url": "https://elhamco.com",
  "telephone": "+966508989323",
  "email": "info@elhamco.com",
  "address": {
    "@type": "PostalAddress",
    "addressLocality": "Riyadh",
    "addressCountry": "SA"
  }
}
```

### Step 4 — Google Business Profile Checklist

See: [`seo/google-business-checklist.md`](./seo/google-business-checklist.md)

- [ ] Create/claim at business.google.com
- [ ] Categories: "Construction Company", "Scaffolding Contractor", "Formwork Supplier"
- [ ] Upload 15+ project photos
- [ ] Complete business hours, phone, website
- [ ] Request 5 reviews from existing clients
- [ ] Post monthly updates (Google Posts)

### Step 5 — Blog Content Calendar

See: [`seo/blog-content-calendar.md`](./seo/blog-content-calendar.md)

---

## 05 Revenue Generation

> 📁 Files: [`templates/`](./templates/)

### WhatsApp Business Button

```html
<!-- Add before </body> on every page -->
<a href="https://wa.me/966508989323?text=Hello%2C%20I%20am%20interested%20in%20your%20services"
   style="position:fixed; bottom:20px; right:20px; z-index:9999;"
   target="_blank" rel="noopener">
  <img src="/assets/whatsapp-icon.png" width="60" alt="Chat on WhatsApp" />
</a>
```

### Lead Conversion Checklist

- [ ] Sticky header CTA: "Get a Free Quote" button visible at all times
- [ ] Contact form: max 5 fields (Name, Company, Service, Phone, Description)
- [ ] Clickable phone: `<a href="tel:+966508989323">+966 50 89 89 323</a>`
- [ ] Trust signals near form: OSHA badge, years active, response time promise
- [ ] Project portfolio page with 5+ documented projects
- [ ] Client testimonials (3–4 minimum)
- [ ] Email newsletter signup (Mailchimp — free up to 500 contacts)

See email templates: [`templates/email-templates.md`](./templates/email-templates.md)

---

## 06 Vendor Management

> 📁 Files: [`vendor/`](./vendor/)

### Current Vendor Register

| Vendor | Service | Action |
|--------|---------|--------|
| NOSCO IT TEAM (namliah.com) | Website dev & maintenance | Formal contract + NDA |
| Domain Registrar | elhamco.com registration | Identify via WHOIS |
| Hosting Provider | Web server | Get SLA documentation |
| Cloudflare | WAF, CDN, DNS | Setup (new) |
| Email Provider | info@elhamco.com | Verify backup access |

### Vendor Security Rules

```
✅ NDA signed before any system access is granted
✅ Limited-scope accounts only (never root/admin credentials)
✅ MFA required from all vendors accessing company systems
✅ Access audited and revoked every 90 days
✅ Source code backup kept in company-controlled storage
✅ Security breach notification clause in all contracts (24hr notification required)
```

See templates:
- [`vendor/nda-template.md`](./vendor/nda-template.md)
- [`vendor/vendor-evaluation-matrix.md`](./vendor/vendor-evaluation-matrix.md)
- [`vendor/vendor-register.csv`](./vendor/vendor-register.csv)

---

## 07 Client Management

> 📁 Files: [`clients/`](./clients/)

### CRM Recommendation

**HubSpot CRM** — Free forever plan  
→ [hubspot.com](https://www.hubspot.com/products/crm)

### Lead Intake SLA

| Stage | Action | Deadline |
|-------|--------|----------|
| Lead received | Add to CRM | Within 2 hours |
| Acknowledgement | WhatsApp/email | Within 2 hours |
| Quote sent | Formal PDF on letterhead | Within 24 hours |
| Follow-up 1 | If no response | Day 3 |
| Follow-up 2 | If still no response | Day 7 |
| CRM update | After every interaction | Same day |

See all templates: [`clients/communication-templates.md`](./clients/communication-templates.md)

---

## 08 Compliance & Legal

### Saudi PDPL Checklist

- [ ] Privacy Policy page published at `/privacy-policy`
- [ ] Terms of Service page published at `/terms`
- [ ] Cookie consent banner added to website
- [ ] Contact form has "I agree to the Privacy Policy" checkbox
- [ ] Data processing register documented
- [ ] Data deletion request process established
- [ ] All vendors have adequate data protection measures documented

See templates:
- [`docs/privacy-policy-template.md`](./docs/privacy-policy-template.md)
- [`docs/terms-of-service-template.md`](./docs/terms-of-service-template.md)

---


## 09 90-Day Roadmap

### Month 1 — Security & Foundation (Days 1–30)

| Priority | Task | Owner |
|----------|------|-------|
| 🔴 Critical | Cloudflare WAF setup | Security Manager + NOSCO |
| 🔴 Critical | HTTP security headers | NOSCO IT TEAM |
| 🔴 Critical | Enable server logging | NOSCO / Hosting |
| 🔴 High | Google Analytics 4 + Search Console | Security Manager |
| 🔴 High | UptimeRobot monitoring | Security Manager |
| 🟡 High | Admin 2FA + IP restriction | Security Manager + NOSCO |
| 🟢 High | Google Business Profile | Marketing |
| 🟢 High | WhatsApp button on website | NOSCO IT TEAM |

### Month 2 — SEO & Lead Generation (Days 31–60)

| Priority | Task | Owner |
|----------|------|-------|
| 🔴 High | 6 dedicated service pages | Content + NOSCO |
| 🔴 High | Submit sitemap | Security Manager |
| 🟡 Medium | Schema markup (LocalBusiness) | NOSCO IT TEAM |
| 🟡 Medium | ELK Stack SIEM setup | Security Manager |
| 🟡 Medium | Pentest Phase 1–3 | Security Manager |
| 🟢 Medium | HubSpot CRM setup | Sales/BD Team |
| 🟢 Medium | Project portfolio page | Marketing + NOSCO |

### Month 3 — Revenue & Scale (Days 61–90)

| Priority | Task | Owner |
|----------|------|-------|
| 🟡 High | 4 blog posts published | Content Writer |
| 🟢 High | LinkedIn company page | Marketing |
| 🟢 High | Mailchimp email setup | Marketing |
| 🔴 High | Pentest final report | Security Manager |
| 🟡 Medium | PDPL cookie consent | NOSCO IT TEAM |
| 🟡 Medium | SIEM alerting rules | Security Manager |
| 🟢 Quick Win | 5 Google Business reviews | Sales Team |

### Success KPIs (Month 3 Targets)

| KPI | Target |
|-----|--------|
| Security Headers Score | Grade A+ |
| SSL Labs Score | Grade A+ |
| Monthly Uptime | 99.9%+ |
| Organic Traffic Increase | +30% from baseline |
| Monthly Website Leads | 10+ qualified leads |
| Google Business Views | 200+ monthly |
| Blog Posts Published | 6 minimum |
| Pentest Criticals Resolved | 100% |
| Log Sources in SIEM | All active |

---

## 📁 Repository Structure

```
elham-progress-digital-ops/
│
├── README.md                          ← You are here
│
├── docs/
│   ├── job-description.md             ← Full JD for HR submission
│   ├── privacy-policy-template.md     ← PDPL-compliant Privacy Policy
│   ├── terms-of-service-template.md   ← Terms of Service template
│   └── seo-vendor-message.md          ← Message to send SEO agency
│
├── security/
│   ├── headers.htaccess               ← HTTP security headers (Apache)
│   ├── headers-nginx.conf             ← HTTP security headers (Nginx)
│   ├── disable-xmlrpc.htaccess        ← Disable WordPress XML-RPC
│   ├── admin-hardening-checklist.md   ← Admin panel security checklist
│   └── pentest/
│       ├── recon-commands.sh          ← All recon commands in one script
│       ├── scanning-commands.sh       ← Active scanning commands
│       ├── report-template.md         ← Pentest report template
│       └── finding-template.md        ← Individual finding template
│
├── logs/
│   ├── logrotate-apache.conf          ← Log rotation config
│   ├── filebeat.yml                   ← Filebeat config for ELK
│   ├── logstash-apache.conf           ← Logstash Apache pipeline
│   └── elk/
│       ├── elasticsearch.yml          ← Elasticsearch config
│       ├── kibana.yml                 ← Kibana config
│       └── alert-rules.md             ← SIEM alerting rules
│
├── seo/
│   ├── sitemap-template.xml           ← Sitemap template
│   ├── schema-localbusiness.json      ← Schema markup for homepage
│   ├── robots-template.txt            ← robots.txt template
│   ├── meta-tags-template.html        ← Meta tags for each page
│   ├── google-business-checklist.md   ← GBP optimization checklist
│   └── blog-content-calendar.md       ← 6-month blog calendar
│
├── scripts/
│   ├── security-audit.sh              ← Quick security check script
│   ├── ssl-check.sh                   ← SSL certificate checker
│   └── seo-check.sh                   ← Basic SEO audit script
│
├── templates/
│   ├── whatsapp-button.html           ← WhatsApp float button code
│   ├── contact-form.html              ← Optimized contact form
│   ├── quote-form.html                ← Multi-step quote form
│   ├── ga4-snippet.html               ← Google Analytics 4 code
│   └── email-templates.md             ← All client email templates
│
├── vendor/
│   ├── vendor-register.csv            ← Vendor tracking spreadsheet
│   ├── nda-template.md                ← NDA for vendors
│   └── vendor-evaluation-matrix.md    ← Scoring matrix template
│
└── clients/
    ├── crm-setup-guide.md             ← HubSpot setup walkthrough
    ├── communication-templates.md     ← All client message templates
    └── onboarding-checklist.md        ← Client onboarding steps
```

---

## ⚠️ Important Notices

> 🔒 **This repository contains sensitive security information about elhamco.com systems.**
> - Keep this repository **PRIVATE**
> - Never commit real credentials, API keys, or passwords
> - Use `.gitignore` to exclude any sensitive files
> - Restrict access to authorized personnel only

---

## 🔧 Quick Start Checklist

```bash
# Day 1 actions — do these immediately:
[ ] Set up Cloudflare WAF at cloudflare.com
[ ] Add security headers (security/headers.htaccess)
[ ] Set up UptimeRobot at uptimerobot.com
[ ] Verify Google Search Console
[ ] Add WhatsApp button (templates/whatsapp-button.html)
```

---

<div align="center">

**Elham Progress Construction Co.**  
Riyadh, Kingdom of Saudi Arabia  
📞 +966 50 89 89 323 · 📧 info@elhamco.com · 🌐 elhamco.com

*Digital Security & Growth Manager — Internal Repository*

</div>
