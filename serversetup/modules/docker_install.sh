install_docker() {
    print_step "2" "Installing Docker..."
    
    if ! command -v docker &> /dev/null; then
        print_status "Installing Docker..."
        
        # Add Docker's official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        # Add Docker repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

        # Add user to docker group
        sudo usermod -aG docker $USER
        print_success "Docker installed successfully"
        print_warning "You need to log out and log back in for Docker permissions to take effect"
        print_warning "Or run: newgrp docker"
    else
        print_status "Docker is already installed"
    fi

    # Check if user is in docker group
    if ! groups $USER | grep -q docker; then
        print_warning "User is not in docker group. Adding user to docker group..."
        sudo usermod -aG docker $USER
        print_warning "Please run: newgrp docker"
        print_warning "Or log out and log back in"
    fi

    # Install Docker Compose if not present
    if ! command -v docker-compose &> /dev/null; then
        print_status "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        print_success "Docker Compose installed"
    fi

    print_success "Docker installation completed"
} 