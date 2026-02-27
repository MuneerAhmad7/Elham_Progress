# Admin Panel Hardening Checklist
# File: security/admin-hardening-checklist.md
# Elham Progress — elhamco.com

## Pre-Hardening: Gather Information

- [ ] Identify CMS platform (WordPress / custom / other) — ask NOSCO IT TEAM
- [ ] Identify admin panel URL (e.g., /admin, /wp-admin, /dashboard)
- [ ] List all admin user accounts and their email addresses
- [ ] Identify hosting provider and server OS
- [ ] Get SSH or cPanel access credentials

---

## Step 1: IP Restriction via Cloudflare Access

```
Cloudflare Dashboard:
→ Zero Trust
→ Access
→ Applications
→ Add Application
→ Self-hosted
→ Application name: "Elham Progress Admin"
→ Application domain: elhamco.com/admin (or your admin path)
→ Policy: Allow — Email ends with @elhamco.com OR IP = [your office IP]
```

**To find your office IP:** Visit https://whatismyip.com from the office network.

---

## Step 2: Two-Factor Authentication (2FA)

- [ ] Enable 2FA on ALL admin accounts — no exceptions
- [ ] Recommended app: **Google Authenticator** or **Authy** (both free)
- [ ] For WordPress: install plugin "WP 2FA" by Melapress (free)
- [ ] Test 2FA login works before logging out of current session
- [ ] Store backup codes in Bitwarden password manager

---

## Step 3: Admin Username & Password

- [ ] Change default username from "admin" to something non-obvious
- [ ] Set password: minimum 16 characters, mixed case + numbers + symbols
- [ ] Use Bitwarden (bitwarden.com — free) to generate and store passwords
- [ ] Never use the same password on multiple accounts
- [ ] Change passwords every 6 months

**Example strong password format:** `Xk9#mP2@qLwZ5nRj`

---

## Step 4: Login Attempt Limiting

For WordPress, add to wp-config.php or install "Limit Login Attempts Reloaded" plugin:

```php
// Limit login attempts via Cloudflare WAF Rule:
// Field: URI Path contains /wp-admin
// AND Request Rate > 5 per minute per IP
// Action: Block
```

---

## Step 5: WordPress-Specific (if applicable)

### Disable XML-RPC
See file: `security/disable-xmlrpc.htaccess`

```htaccess
<Files xmlrpc.php>
    Order Deny,Allow
    Deny from all
</Files>
```

### Disable File Editing in Dashboard
Add to wp-config.php:
```php
define('DISALLOW_FILE_EDIT', true);
define('DISALLOW_FILE_MODS', true);
```

### Database Prefix
- Change default `wp_` table prefix to random string (e.g., `ep7x_`)
- Must be done during installation or via migration plugin

---

## Step 6: File Permissions Audit

```bash
# Correct permissions (run on server):
find /var/www/elhamco.com -type d -exec chmod 755 {} \;
find /var/www/elhamco.com -type f -exec chmod 644 {} \;

# Protect config files:
chmod 600 /var/www/elhamco.com/wp-config.php
chmod 600 /var/www/elhamco.com/.env
```

---

## Step 7: Regular Audit Schedule

| Task | Frequency |
|------|-----------|
| Review admin user list | Monthly |
| Rotate passwords | Every 6 months |
| Audit vendor access | Every 90 days |
| Check failed login logs | Weekly |
| Update CMS + plugins | Weekly |

---

## Verification Commands

```bash
# Check who has admin access in WordPress database:
mysql -u root -p -e "SELECT user_login, user_email FROM wp_users u 
JOIN wp_usermeta m ON u.ID = m.user_id 
WHERE m.meta_key = 'wp_capabilities' 
AND m.meta_value LIKE '%administrator%';"

# Check for suspicious files modified in last 7 days:
find /var/www/elhamco.com -type f -newer /var/www/elhamco.com/wp-config.php

# Check open ports:
netstat -tulnp | grep LISTEN
```
