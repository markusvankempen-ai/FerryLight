setup_project() {
    print_step "3" "Setting up project structure..."
    
    print_status "Creating project directory at $PROJECT_DIR..."
    sudo mkdir -p $PROJECT_DIR
    sudo chown $USER:$USER $PROJECT_DIR

    # Create Docker networks
    print_status "Creating Docker networks..."
    docker network create traefik-public 2>/dev/null || print_status "Traefik network already exists"
    docker network create web 2>/dev/null || print_status "Web network already exists"

    # Create directories for persistent data
    print_status "Creating directories for persistent data..."
    mkdir -p $PROJECT_DIR/traefik/acme
    mkdir -p $PROJECT_DIR/traefik/config
    mkdir -p $PROJECT_DIR/portainer
    mkdir -p $PROJECT_DIR/nodered
    mkdir -p $PROJECT_DIR/postgres/data
    mkdir -p $PROJECT_DIR/postgres/init
    mkdir -p $PROJECT_DIR/pgadmin
    mkdir -p $PROJECT_DIR/mailserver/mail-data    # Added for Mail Server
    mkdir -p $PROJECT_DIR/mailserver/mail-state   # Added for Mail Server
    mkdir -p $PROJECT_DIR/mailserver/mail-logs    # Added for Mail Server
    mkdir -p $PROJECT_DIR/mailserver/config       # Added for Mail Server
    mkdir -p $PROJECT_DIR/mailserver/dms/config   # Added for Mail Server
    mkdir -p $PROJECT_DIR/mosquitto/config
    mkdir -p $PROJECT_DIR/mosquitto/data
    mkdir -p $PROJECT_DIR/mosquitto/logs
    mkdir -p $PROJECT_DIR/website

    print_success "Project structure created"
} 