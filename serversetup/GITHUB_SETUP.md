# GitHub Setup Guide

This guide explains how to safely deploy FerryLightV2 to GitHub while keeping credentials secure.

## 🔒 Security First

### Files to NEVER Commit
- `CREDENTIALS.md` - Contains all real credentials
- `.env` - Your actual environment variables
- `traefik/acme/` - SSL certificates
- `postgres/data/` - Database files
- `pgadmin/` - pgAdmin data
- Any backup files

### Files Safe to Commit
- All scripts and modules
- Documentation (with placeholder values)
- `env.example` - Template for environment variables
- `.gitignore` - Git ignore rules

## 🚀 GitHub Deployment Steps

### 1. Initialize Git Repository

```bash
# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial FerryLightV2 setup"
```

### 2. Create GitHub Repository

1. Go to GitHub.com and create a new repository
2. **DO NOT** initialize with README, .gitignore, or license
3. Copy the repository URL

### 3. Push to GitHub

```bash
# Add remote origin
git remote add origin https://github.com/yourusername/FerryLightV2.git

# Push to GitHub
git push -u origin main
```

## 🔧 Environment Configuration

### 1. Create Environment File

```bash
# Copy the example environment file
cp env.example .env

# Edit with your real values
nano .env
```

### 2. Update .env with Real Values

```bash
# Domain Configuration
DOMAIN=your-actual-domain.com
SERVER_IP=your-actual-server-ip
EMAIL=your-actual-email@domain.com

# Authentication Credentials
TRAEFIK_USERNAME=admin
TRAEFIK_PASSWORD=your-secure-password
NODERED_USERNAME=admin
NODERED_PASSWORD=your-secure-password

# MQTT Configuration
MQTT_USERNAME=your-mqtt-username
MQTT_PASSWORD=your-secure-mqtt-password

# PostgreSQL Configuration
POSTGRES_DB=your-database-name
POSTGRES_USER=your-database-user
POSTGRES_PASSWORD=your-secure-database-password

# pgAdmin Configuration
PGADMIN_EMAIL=admin@your-domain.com
PGADMIN_PASSWORD=your-secure-pgadmin-password
```

## 📋 Deployment Checklist

### Before Pushing to GitHub
- [ ] `CREDENTIALS.md` is in `.gitignore`
- [ ] `.env` file is in `.gitignore`
- [ ] All hardcoded credentials removed from scripts
- [ ] All documentation uses placeholder values
- [ ] `env.example` contains template values
- [ ] `.gitignore` excludes sensitive directories

### After GitHub Push
- [ ] Repository is public/private as intended
- [ ] `env.example` is visible in repository
- [ ] No sensitive files are visible
- [ ] Documentation is clear for other users

## 🔐 Credential Management

### For Your Use
1. Keep `CREDENTIALS.md` locally (never commit)
2. Use `.env` file for environment variables
3. Store credentials securely (password manager)

### For Other Users
1. They copy `env.example` to `.env`
2. They update `.env` with their own values
3. They run the setup script

## 📖 Documentation Updates

### What's Been Updated
- ✅ All scripts use environment variables
- ✅ Documentation uses placeholder values
- ✅ Credentials moved to separate file
- ✅ `.gitignore` excludes sensitive files
- ✅ `env.example` provides template

### Placeholder Format
- `[your-domain]` - Replace with actual domain
- `[your-server-ip]` - Replace with actual IP
- `[your-email]` - Replace with actual email
- `[your-secure-password]` - Replace with secure password

## 🚨 Security Reminders

### Never Commit
- Real passwords or API keys
- SSL certificates
- Database files
- Personal information
- Server IPs (if private)

### Always Use
- Environment variables
- Placeholder values in docs
- Secure passwords
- HTTPS for all services

## 📞 Support

If you need help with GitHub deployment:
1. Check that `.gitignore` is working
2. Verify no sensitive files are committed
3. Test the setup with your `.env` file
4. Update documentation as needed

---

**Remember:** Security first! Always verify what you're committing to GitHub. 