setup_system() {
    print_step "1" "Preparing system..."
    
    print_status "Updating system packages..."
    sudo apt update && sudo apt upgrade -y

    print_status "Installing required packages..."
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common mosquitto-clients

    print_success "System preparation completed"
} 