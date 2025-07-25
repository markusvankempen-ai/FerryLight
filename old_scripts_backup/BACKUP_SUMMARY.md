# Old Scripts Backup Summary

This directory contains scripts that were moved from the main FerryLightV2 project directory as part of the consolidation effort.

## 📅 Backup Date
24-July-2025

## 🔄 Consolidation Reason
The project was consolidated to use a single comprehensive script (`fix_mqtt_auth.sh`) instead of multiple smaller scripts for better maintainability and user experience.

## 📁 Scripts Moved

### MQTT Related Scripts
- `configure_mqtt_auth.sh` - Old MQTT authentication setup
- `test_mqtt.sh` - Old MQTT testing script
- `configure_mqtt.sh` - Old MQTT configuration script

### Setup Scripts
- `setup_master.sh` - Master setup script (replaced by consolidated approach)
- `setup_part1_docker.sh` - Docker setup part 1
- `setup_part2_config.sh` - Configuration setup part 2
- `setup_part3_services.sh` - Services setup part 3
- `setup_part3_fixed.sh` - Fixed services setup
- `setup_ferrylight.sh` - FerryLight setup script
- `setup_server.sh` - Server setup script

### Fix Scripts
- `fix_traefik_middlewares.sh` - Traefik middleware fixes
- `fix_permissions.sh` - Permission fixes
- `fix_https_routing.sh` - HTTPS routing fixes
- `fix_containers.sh` - Container fixes
- `fix_domain_config.sh` - Domain configuration fixes
- `fix_namecheap_dns.sh` - Namecheap DNS fixes
- `fix_networks.sh` - Network fixes
- `fix_docker_permissions.sh` - Docker permission fixes

### Troubleshooting Scripts
- `restart_services.sh` - Service restart script
- `troubleshoot_404.sh` - 404 error troubleshooting
- `troubleshoot.sh` - General troubleshooting
- `quick_fix_404.sh` - Quick 404 fixes
- `diagnose_ssl.sh` - SSL diagnosis
- `manual_fix.sh` - Manual fixes

### Configuration Scripts
- `configure_domains.sh` - Domain configuration
- `enable_ip_access.sh` - IP access configuration

### Other
- `ferrylightv2_complete_setup.sh` - Complete setup script
- `README.md` - Old README file

## ✅ Current Active Files

The main project directory now contains only the essential files:

- `README.md` - Updated comprehensive documentation
- `fix_mqtt_auth.sh` - Consolidated MQTT authentication script
- `DEPLOYMENT_GUIDE.md` - Deployment guide

## 🔧 How to Use Backup Scripts

If you need to reference any of these old scripts:

1. **Copy the script back to main directory:**
   ```bash
   cp old_scripts_backup/script_name.sh ./
   ```

2. **Make it executable:**
   ```bash
   chmod +x script_name.sh
   ```

3. **Run the script:**
   ```bash
   ./script_name.sh
   ```

## ⚠️ Important Notes

- These scripts are **backup copies** and may not work with current system configuration
- The **consolidated approach** using `fix_mqtt_auth.sh` is recommended
- Always test backup scripts in a safe environment before using in production
- Some scripts may contain outdated configurations or paths

## 📞 Support

If you need to restore functionality from any of these backup scripts, refer to the main `README.md` for current documentation and the `fix_mqtt_auth.sh` script for current functionality.

---

**Backup created by:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com  
**Project:** FerryLightV2 