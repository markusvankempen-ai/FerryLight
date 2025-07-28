# FerryLight App - Internal Documentation

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Server-Side API Proxy](#server-side-api-proxy)
4. [API Integration](#api-integration)
5. [Component Structure](#component-structure)
6. [State Management](#state-management)
7. [Styling & UI](#styling--ui)
8. [Authentication](#authentication)
9. [Error Handling](#error-handling)
10. [Development Setup](#development-setup)
11. [Deployment](#deployment)
12. [Testing](#testing)
13. [Troubleshooting](#troubleshooting)
14. [Change History](#change-history)

## 👨‍💻 Author Information

**Author**: Markus van Kempen  
**Email**: markus.van.kempen@gmail.com  
**Project**: FerryLight V2  
**Created**: July 2025  
**Last Updated**: July 28, 2025  
**Version**: 1.0.0

## 🚢 Project Overview

### Purpose
FerryLight is a modern React web application that provides real-time ferry status, wait times, and weather information for the Englishtown ↔ Jersey Cove route. The app includes both a web interface and simulates a physical LED display system.

### Key Features
- Real-time ferry status and wait times
- Live weather information
- LED matrix simulation
- Admin panel with debugging tools
- Progressive Web App (PWA) capabilities
- Mobile-responsive design
- **Server-side API proxy** for security and performance

### Tech Stack
- **Frontend**: React 18.2.0
- **Backend**: Express.js (API proxy)
- **Styling**: Styled Components
- **Animations**: Framer Motion
- **Icons**: React Icons
- **HTTP Client**: Axios
- **Routing**: React Router DOM
- **Build Tool**: Create React App
- **Container**: Docker + Nginx

## 🏗️ Architecture

### Project Structure
```
FerryLightV2/
├── public/                 # Static assets
│   ├── index.html         # Main HTML file
│   ├── manifest.json      # PWA manifest
│   ├── favicon.*          # Favicon files
│   └── PXL_*.jpg/mp4     # Media files
├── src/
│   ├── components/        # React components
│   ├── services/          # Client-side API services
│   ├── utils/            # Utility functions
│   ├── App.js            # Main app component
│   └── index.js          # Entry point
├── server.js             # Express.js API proxy server
├── start-dev.sh          # Development startup script
├── Dockerfile            # Docker configuration
├── nginx.conf           # Nginx configuration
├── docker-compose.yml   # Docker Compose
└── deploy.sh           # Deployment script
```

### Component Hierarchy
```
App.js
├── Header.js
├── FerryStatus.js
├── WeatherInfo.js
├── FerryLight.js
├── ContactInfo.js
├── Login.js
├── Admin.js
└── DebugPanel.js
```

### Server Architecture
```
Express.js Server (port 3001)
├── /api/ferry          # Ferry data endpoint
├── /api/weather        # Weather data endpoint
├── /api/all            # Combined data endpoint
├── /api/health         # Health check endpoint
└── /*                  # Serve React app
```

## 🔧 Server-Side API Proxy

### Overview
The application now uses a **server-side API proxy** to handle all external API calls. This provides:
- **Security**: API credentials are server-side only
- **Performance**: Reduced multiple API calls
- **Reliability**: Centralized error handling and retry logic
- **Caching**: Potential for future server-side caching

### Server Implementation (`server.js`)

#### Key Features
- **Express.js Server**: Handles all external API calls
- **Authentication**: Server manages API credentials securely
- **Retry Logic**: Exponential backoff for failed requests
- **Mock Data**: Fallback when external APIs are unavailable
- **Health Check**: `/api/health` endpoint for monitoring
- **CORS Support**: Cross-origin request handling
- **Static File Serving**: Serves React build files

#### Environment Variables
```bash
# Server-side API credentials (not exposed to client)
REACT_APP_API_USERNAME=your_actual_username
REACT_APP_API_PASSWORD=your_actual_password
REACT_APP_FERRY_API_URL=https://nodered.ferrylight.online/rbferry
REACT_APP_WEATHER_API_URL=https://nodered.ferrylight.online/rbweather
```

#### API Endpoints
```javascript
// Server endpoints (client calls these)
GET /api/ferry          // Returns ferry data
GET /api/weather        // Returns weather data  
GET /api/all            // Returns combined ferry + weather data
GET /api/health         // Returns server health status
```

#### Error Handling
- **Network Errors**: Retry with exponential backoff
- **Authentication Errors**: Return mock data
- **Timeout Handling**: 15-second timeout
- **Graceful Degradation**: Mock data fallbacks

### Client-Side Changes (`src/services/api.js`)

#### Simplified Client API
```javascript
// Old: Direct API calls with credentials
const FERRY_API = 'https://nodered.ferrylight.online/rbferry';
const credentials = btoa(`${username}:${password}`);

// New: Server-side endpoints (no credentials needed)
const FERRY_API = '/api/ferry';
const WEATHER_API = '/api/weather';
const ALL_DATA_API = '/api/all';
```

#### Benefits
- **No Credentials**: Client doesn't need API credentials
- **Simplified Code**: Removed authentication logic from client
- **Better Security**: Credentials only exist server-side
- **Reduced Calls**: Single `/api/all` call instead of multiple

## 🔌 API Integration

### External APIs
- **Ferry Data**: `https://nodered.ferrylight.online/rbferry`
- **Weather Data**: `https://nodered.ferrylight.online/rbweather`

### Server-Side Authentication
- **Method**: Basic Authentication
- **Credentials**: Stored in server environment variables
- **Headers**: Authorization: Basic base64(username:password)

### Data Flow (Updated)
1. **Client Request** → Server endpoint (`/api/all`)
2. **Server** → External APIs with credentials
3. **Server** → Process and combine data
4. **Server** → Return JSON to client
5. **Client** → Update React components

### Mock Data Structure
```javascript
// Ferry Data Structure
{
  timestamp: "July 27, 2025 at 09:45:04 PM",
  ferryStatus: {
    status: "Service Temporarily Unavailable",
    lastUpdated: "2025-07-27",
    region: "Cape Breton",
    terminalName: "Englishtown"
  },
  directions: {
    jerseyToEnglishtown: {
      direction: "Jersey Cove → Englishtown",
      travelTimeMinutes: "0",
      waitTime: {
        queueTime: "0",
        estimatedVehicles: 0,
        ferryTripsNeeded: 0,
        waitTime: 0,
        status: "Unavailable"
      },
      status: "Offline"
    },
    englishtownToJersey: { /* similar structure */ }
  }
}

// Weather Data Structure
{
  dateutc: "2025-07-27 21:45:04",
  tempf: 68.0,
  tempc: 20.0,
  humidity: 65,
  winddir: 180,
  windspeedmph: 5.0,
  windspeedkmh: 8.0,
  conditions: "Data Unavailable"
}
```

## 🧩 Component Structure

### Core Components

#### App.js
- **Purpose**: Main application component
- **State**: Global data, loading states, error handling
- **Features**: 
  - Data fetching from server endpoints
  - Admin session management
  - Page routing
  - Auto-refresh functionality
  - **Updated**: Removed redundant API connectivity tests

#### Header.js
- **Purpose**: Navigation and app controls
- **Features**:
  - Responsive navigation menu
  - Refresh button with loading state
  - Admin login button (icon-only on mobile)
  - Mobile hamburger menu
  - **Updated**: Icon-only buttons with tooltips

#### FerryStatus.js
- **Purpose**: Display ferry wait times and status
- **Features**:
  - Real-time wait time display
  - "No Wait Time" logic (≤18 minutes)
  - Google Maps integration using API-provided links
  - Status indicators (online/offline)
  - **Updated**: Uses API-provided Google Maps coordinates

#### WeatherInfo.js
- **Purpose**: Display weather information
- **Features**:
  - Temperature conversion (F to C)
  - Wind direction interpretation
  - UV index display
  - Rain data visualization
  - Weather condition detection
  - **Updated**: Improved "Dark" condition logic using solar radiation

#### FerryLight.js
- **Purpose**: LED matrix simulation
- **Features**:
  - HTML Canvas-based LED display
  - Scrolling text animation
  - Dynamic text generation from ferry data
  - Physical display image integration
  - **Updated**: Fixed flickering issues, improved animation stability

#### ContactInfo.js
- **Purpose**: Contact information and app details
- **Features**:
  - Email contact link with proper mailto: protocol
  - FerryLight app/display descriptions
  - Media gallery (images/video with 180° rotation)
  - WiFi connectivity information
  - **Updated**: Fixed video playback, improved email button

#### Login.js
- **Purpose**: Admin authentication
- **Features**:
  - Username/password authentication
  - Session management (24-hour validity)
  - Password visibility toggle
  - Loading states and error handling
  - **Updated**: Removed username/password display

#### Admin.js
- **Purpose**: Admin panel interface
- **Features**:
  - Session validation
  - System status display
  - Debug panel integration
  - Logout functionality

#### DebugPanel.js
- **Purpose**: Development debugging tools
- **Features**:
  - Server connectivity testing
  - Browser information display
  - Manual data fetching
  - Network request monitoring
  - **Updated**: Now tests server endpoints instead of direct APIs

## 🔄 State Management

### Global State (App.js)
```javascript
const [data, setData] = useState(null);
const [isLoading, setIsLoading] = useState(false);
const [error, setError] = useState(null);
const [activePage, setActivePage] = useState('ferry');
const [isLoggedIn, setIsLoggedIn] = useState(false);
const [showDebugPanel, setShowDebugPanel] = useState(false);
```

### Local Storage
- **Admin Session**: `ferrylight_admin` and `ferrylight_admin_time`
- **Session Duration**: 24 hours
- **Auto-cleanup**: Invalid sessions removed on app start

### Data Flow (Updated)
1. **Initial Load**: Fetch data from `/api/all` endpoint
2. **Auto-refresh**: Every 5 minutes via server endpoint
3. **Manual Refresh**: User-triggered via header button
4. **Error Recovery**: Server-side retry logic with exponential backoff

## 🎨 Styling & UI

### Design System
- **Color Palette**: Blues, grays, with accent colors
- **Typography**: System fonts with fallbacks
- **Spacing**: Consistent 0.8rem base unit
- **Border Radius**: 0.4rem for cards, 0.8rem for containers

### Styled Components
- **Container Components**: Page wrappers with consistent spacing
- **Card Components**: Elevated containers with shadows
- **Interactive Elements**: Hover effects and transitions
- **Responsive Design**: Mobile-first approach

### Animation System
- **Framer Motion**: Page transitions and micro-interactions
- **Loading States**: Spinners and skeleton screens
- **Hover Effects**: Scale and color transitions
- **Page Transitions**: Fade and slide animations

## 🔐 Authentication

### Admin Login
- **Credentials**: admin/ferrylight2025
- **Session Storage**: localStorage with timestamp
- **Session Duration**: 24 hours
- **Auto-logout**: Session expiration handling

### Security Features
- **No Credential Display**: Removed from login screen
- **Session Validation**: Check on app start
- **Secure Logout**: Clear all session data
- **Protected Routes**: Admin panel access control
- **Server-Side Credentials**: API credentials only on server

## ⚠️ Error Handling

### Server-Side Error Handling
- **Network Errors**: Retry with exponential backoff
- **Authentication Errors**: Return mock data
- **Timeout Handling**: 15-second timeout
- **Graceful Degradation**: Mock data fallbacks

### Client-Side Error Handling
- **API Errors**: Display user-friendly error messages
- **Network Issues**: Retry logic with backoff
- **Component Errors**: Error boundaries for graceful degradation
- **Debug Information**: Comprehensive error logging

### Debug Features
- **Console Logging**: Detailed debug information
- **Server Testing**: Manual connectivity checks
- **Error Tracking**: Comprehensive error reporting
- **Performance Monitoring**: Web vitals tracking

## 🛠️ Development Setup

### Prerequisites
- Node.js 18+
- npm or yarn
- Docker (for deployment)
- Git

### Local Development
```bash
# Clone repository
git clone <repository-url>
cd FerryLightV2

# Install dependencies
npm install

# Option 1: Use startup script (recommended)
./start-dev.sh

# Option 2: Start both server and React app
npm run dev

# Option 3: Start separately
npm run server    # Server on port 3001
npm start         # React app on port 3000
```

### Environment Variables
```bash
# .env file (copy from env.example)
REACT_APP_API_USERNAME=your_actual_username
REACT_APP_API_PASSWORD=your_actual_password
REACT_APP_FERRY_API_URL=https://nodered.ferrylight.online/rbferry
REACT_APP_WEATHER_API_URL=https://nodered.ferrylight.online/rbweather
REACT_APP_ADMIN_USERNAME=admin
REACT_APP_ADMIN_PASSWORD=ferrylight2025
```

### Development Scripts
- `npm start`: React development server
- `npm run server`: Express.js API server
- `npm run dev`: Both server and React app concurrently
- `./start-dev.sh`: Automated startup script
- `npm run build`: Production build
- `npm test`: Run tests

## 🚀 Deployment

### Docker Deployment
```bash
# Build and deploy
./deploy.sh

# Manual deployment
docker build -t ferrylight-app .
docker-compose up -d
```

### Production Configuration
- **Nginx**: Optimized for React SPA
- **Express Server**: API proxy on port 3001
- **Gzip Compression**: Enabled for all text assets
- **Caching**: Static assets cached for 1 year
- **Security Headers**: Comprehensive security configuration
- **Health Check**: `/api/health` endpoint for monitoring

### Environment Setup
- **Port**: 80 (HTTP), 443 (HTTPS)
- **SSL**: Optional SSL termination
- **Logging**: Nginx access and error logs
- **Monitoring**: Health check endpoint

## 🧪 Testing

### Testing Strategy
- **Unit Tests**: Component testing with React Testing Library
- **Integration Tests**: Server API integration testing
- **E2E Tests**: Full user journey testing
- **Performance Tests**: Lighthouse audits

### Test Commands
```bash
# Run all tests
npm test

# Run tests with coverage
npm test -- --coverage

# Run tests in watch mode
npm test -- --watch
```

## 🔧 Troubleshooting

### Common Issues

#### Server Connection Issues
- **Symptom**: "Proxy error: Could not proxy request"
- **Solution**: Ensure server is running on port 3001
- **Debug**: Check `npm run server` and `curl http://localhost:3001/api/health`

#### API Authentication Issues
- **Symptom**: 401 Unauthorized errors
- **Solution**: Check `.env` file has correct API credentials
- **Debug**: Test server endpoints directly

#### Development Setup Issues
- **Symptom**: Multiple API calls or proxy errors
- **Solution**: Use `./start-dev.sh` script for proper setup
- **Debug**: Check both server and React app are running

#### Docker Build Issues
- **Symptom**: Docker build fails
- **Solution**: Check Dockerfile and .dockerignore
- **Debug**: Run `docker build --no-cache .`

#### Performance Issues
- **Symptom**: Slow loading or poor performance
- **Solution**: Check bundle size and optimize images
- **Debug**: Use Lighthouse for performance audit

### Debug Tools
- **DebugPanel**: Built-in debugging interface
- **Browser DevTools**: Network and console monitoring
- **Lighthouse**: Performance and accessibility audit
- **React DevTools**: Component state inspection
- **Server Logs**: Express.js server console output

### Log Files
- **Nginx Logs**: `/var/log/nginx/access.log`
- **Error Logs**: `/var/log/nginx/error.log`
- **Application Logs**: Browser console and debug panel
- **Server Logs**: Express.js server console output

## 📚 Additional Resources

### Documentation
- [React Documentation](https://reactjs.org/docs/)
- [Express.js Documentation](https://expressjs.com/)
- [Styled Components](https://styled-components.com/docs)
- [Framer Motion](https://www.framer.com/motion/)
- [Docker Documentation](https://docs.docker.com/)

### Development Tools
- **VS Code Extensions**: React Developer Tools, ESLint
- **Browser Extensions**: React DevTools, Lighthouse
- **API Testing**: Postman or Insomnia

### Monitoring
- **Performance**: Lighthouse CI
- **Error Tracking**: Sentry (optional)
- **Analytics**: Google Analytics (optional)

## 📝 Change History

### Version 1.0.0 - July 28, 2025
**Author**: Markus van Kempen (markus.van.kempen@gmail.com)

#### Major Architecture Changes
- ✅ **Server-Side API Proxy**: Express.js server for secure API handling
- ✅ **Security Improvements**: API credentials moved server-side
- ✅ **Performance Optimization**: Reduced multiple API calls to single server call
- ✅ **Development Scripts**: Automated startup script (`start-dev.sh`)
- ✅ **Error Handling**: Comprehensive server-side and client-side error handling

#### Initial Release Features
- ✅ **Core Application**: React-based ferry status and weather app
- ✅ **Real-time Data**: Integration with ferry and weather APIs
- ✅ **LED Matrix Simulation**: HTML Canvas-based display simulation
- ✅ **Admin Panel**: Secure authentication and debugging tools
- ✅ **Progressive Web App**: PWA capabilities with offline support
- ✅ **Mobile Responsive**: Optimized for all device sizes
- ✅ **Docker Deployment**: Complete containerization setup

#### Technical Implementation
- ✅ **Component Architecture**: Modular React components
- ✅ **State Management**: Global state with React hooks
- ✅ **API Integration**: Server-side proxy with Axios and retry logic
- ✅ **Styling**: Styled Components with consistent design system
- ✅ **Animations**: Framer Motion for smooth interactions
- ✅ **Error Handling**: Comprehensive error boundaries and fallbacks

#### UI/UX Features
- ✅ **Ferry Status Page**: Real-time wait times with "No Wait Time" logic
- ✅ **Weather Information**: Temperature, wind, UV, and rain data
- ✅ **FerryLight Display**: LED matrix simulation with scrolling text
- ✅ **Contact Page**: Media gallery with images and video
- ✅ **Admin Login**: Secure authentication with session management
- ✅ **Debug Panel**: Development tools for API testing

#### Deployment & Infrastructure
- ✅ **Docker Setup**: Multi-stage build with Nginx
- ✅ **Express.js Server**: API proxy with authentication
- ✅ **Nginx Configuration**: Optimized for React SPA
- ✅ **Security Headers**: Comprehensive security configuration
- ✅ **Health Checks**: Monitoring endpoints
- ✅ **Documentation**: Internal and external documentation

#### Media Integration
- ✅ **FerryLight Display Images**: Physical display documentation
- ✅ **Video Demo**: Rotated 180° video with click-to-play
- ✅ **Responsive Media**: Optimized for all screen sizes

#### Security & Performance
- ✅ **Server-Side Authentication**: API credentials only on server
- ✅ **Error Recovery**: Retry logic with exponential backoff
- ✅ **Mock Data**: Fallback when APIs unavailable
- ✅ **Performance**: Optimized bundle size and caching
- ✅ **Accessibility**: WCAG compliant design

#### Documentation
- ✅ **Internal Documentation**: Comprehensive technical guide
- ✅ **External README**: Public-facing documentation
- ✅ **Contributing Guidelines**: Clear contribution process
- ✅ **Security Protection**: .gitignore for sensitive files
- ✅ **License**: MIT license for open source

---

**Last Updated**: July 28, 2025  
**Version**: 1.0.0  
**Maintainer**: Markus van Kempen (markus.van.kempen@gmail.com) 