start_services() {
    print_step "5" "Starting services..."
    
    cd $PROJECT_DIR
    
    print_status "Starting Docker services..."
    docker-compose up -d

    print_status "Waiting for services to start..."
    sleep 15

    print_status "Checking service status..."
    docker-compose ps

    print_success "Services started successfully"
} 