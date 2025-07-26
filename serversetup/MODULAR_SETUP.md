# FerryLightV2 Modular Setup

This project now uses a modular approach to make the setup script more manageable and easier to copy/paste.

## 📁 File Structure

```
FerryLightV2/
├── setup.sh                           # Quick setup launcher
├── setup_ferrylightv2_complete.sh     # Main orchestrator script
├── modules/                           # Modular functions (auto-created)
│   ├── system_setup.sh               # System preparation
│   ├── docker_install.sh             # Docker installation
│   ├── project_setup.sh              # Project structure
│   ├── docker_compose.sh             # Docker Compose configuration
│   ├── services.sh                   # Service management
│   ├── mqtt_auth.sh                  # MQTT authentication
│   ├── final_config.sh               # Final configuration
│   └── results.sh                    # Results display
├── README.md                         # Main documentation
├── DEPLOYMENT_GUIDE.md               # Deployment guide
└── old_scripts_backup/               # Backup of old scripts
```

## 🚀 Quick Setup

### Option 1: Simple Setup (Recommended)
```bash
./setup.sh
```

### Option 2: Direct Setup
```bash
./setup_ferrylightv2_complete.sh
```

## 🔧 How It Works

### 1. Main Orchestrator (`setup_ferrylightv2_complete.sh`)
- **Small, manageable script** (~200 lines)
- **Easy to copy/paste**
- **Orchestrates the entire setup process**
- **Auto-creates modules on first run**

### 2. Modular Functions (`modules/`)
- **Auto-generated** on first run
- **Each module handles one specific task**
- **Easy to modify individual components**
- **Better error isolation**

### 3. Module Breakdown

| Module | Purpose | Size |
|--------|---------|------|
| `system_setup.sh` | System preparation | 11 lines |
| `docker_install.sh` | Docker installation | 43 lines |
| `project_setup.sh` | Project structure | 25 lines |
| `docker_compose.sh` | Docker Compose config | 409 lines |
| `services.sh` | Service management | 16 lines |
| `mqtt_auth.sh` | MQTT authentication | 118 lines |
| `final_config.sh` | Final configuration | 110 lines |
| `results.sh` | Results display | 47 lines |

## 📋 Setup Process

1. **System Preparation** - Updates and installs packages
2. **Docker Installation** - Installs Docker and Docker Compose
3. **Project Setup** - Creates directories and networks
4. **Docker Compose** - Creates all configuration files
5. **Services** - Starts all containers
6. **MQTT Authentication** - Configures MQTT with authentication
7. **Final Configuration** - Sets up auto-start and management scripts
8. **Results** - Shows setup summary and credentials

## 🛠️ Customization

### Modify Individual Modules
```bash
# Edit a specific module
nano modules/mqtt_auth.sh

# Re-run setup (modules are auto-created)
./setup_ferrylightv2_complete.sh
```

### Add New Modules
1. Create new module file in `modules/`
2. Add function to main script
3. Call function in main() sequence

## 🔄 Benefits

### ✅ Advantages
- **Easy to copy/paste** - Small main script
- **Modular design** - Easy to modify individual parts
- **Better organization** - Clear separation of concerns
- **Auto-generation** - No manual module management
- **Error isolation** - Issues in one module don't affect others

### 📦 File Sizes
- **Main script**: 147 lines (easy to copy)
- **Total modules**: 779 lines (separate files)
- **Total functionality**: Same as before

## 🚨 Troubleshooting

### Module Issues
```bash
# Recreate modules
rm -rf modules/
./setup_ferrylightv2_complete.sh
```

### Individual Module Debug
```bash
# Test specific module
source modules/mqtt_auth.sh
configure_mqtt_auth
```

## 📞 Support

The modular setup maintains all the same functionality as the original script but with better organization and easier maintenance.

**Main Script**: Easy to copy/paste and understand
**Modules**: Auto-generated and maintainable
**Functionality**: Complete FerryLightV2 setup with MQTT authentication

---

**Created by:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com  
**Project:** FerryLightV2 