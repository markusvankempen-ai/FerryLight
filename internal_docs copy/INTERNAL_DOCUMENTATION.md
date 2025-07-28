# FerryLight App - Internal Documentation

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [API Integration](#api-integration)
4. [Component Structure](#component-structure)
5. [State Management](#state-management)
6. [Styling & UI](#styling--ui)
7. [Authentication](#authentication)
8. [Error Handling](#error-handling)
9. [Development Setup](#development-setup)
10. [Deployment](#deployment)
11. [Testing](#testing)
12. [Troubleshooting](#troubleshooting)
13. [Change History](#change-history)

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

### Tech Stack
- **Frontend**: React 18.2.0
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
│   ├── services/          # API services
│   ├── utils/            # Utility functions
│   ├── App.js            # Main app component
│   └── index.js          # Entry point
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

## 🔌 API Integration

### Endpoints
- **Ferry Data**: `https://nodered.ferrylight.online/rbferry`
- **Weather Data**: `https://nodered.ferrylight.online/rbweather`

### Authentication
- **Method**: Basic Authentication
- **Credentials**: ferrylight:ferrylight
- **Headers**: Authorization: Basic base64(username:password)

### Data Flow
1. **API Service** (`src/services/api.js`)
   - Axios instance with authentication
   - Retry logic with exponential backoff
   - Mock data fallbacks
   - Error handling and logging

2. **Component Integration**
   - Data fetched in `App.js`
   - Passed down as props to components
   - Real-time updates every 5 minutes

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
  - Data fetching with retry logic
  - Admin session management
  - Page routing
  - Auto-refresh functionality

#### Header.js
- **Purpose**: Navigation and app controls
- **Features**:
  - Responsive navigation menu
  - Refresh button with loading state
  - Admin login button
  - Mobile hamburger menu

#### FerryStatus.js
- **Purpose**: Display ferry wait times and status
- **Features**:
  - Real-time wait time display
  - "No Wait Time" logic (≤18 minutes)
  - Google Maps integration
  - Status indicators (online/offline)

#### WeatherInfo.js
- **Purpose**: Display weather information
- **Features**:
  - Temperature conversion (F to C)
  - Wind direction interpretation
  - UV index display
  - Rain data visualization
  - Weather condition detection

#### FerryLight.js
- **Purpose**: LED matrix simulation
- **Features**:
  - HTML Canvas-based LED display
  - Scrolling text animation
  - Dynamic text generation from ferry data
  - Physical display image integration

#### ContactInfo.js
- **Purpose**: Contact information and app details
- **Features**:
  - Email contact link
  - FerryLight app/display descriptions
  - Media gallery (images/video)
  - WiFi connectivity information

#### Login.js
- **Purpose**: Admin authentication
- **Features**:
  - Username/password authentication
  - Session management (24-hour validity)
  - Password visibility toggle
  - Loading states and error handling

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
  - API connectivity testing
  - Browser information display
  - Manual data fetching
  - Network request monitoring

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

### Data Flow
1. **Initial Load**: Fetch data on component mount
2. **Auto-refresh**: Every 5 minutes
3. **Manual Refresh**: User-triggered via header button
4. **Error Recovery**: Retry logic with exponential backoff

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
- **Credentials**: admin/ferrylight2024
- **Session Storage**: localStorage with timestamp
- **Session Duration**: 24 hours
- **Auto-logout**: Session expiration handling

### Security Features
- **No Credential Display**: Removed from login screen
- **Session Validation**: Check on app start
- **Secure Logout**: Clear all session data
- **Protected Routes**: Admin panel access control

## ⚠️ Error Handling

### API Error Handling
- **Network Errors**: Retry with exponential backoff
- **Timeout Handling**: 15-second timeout
- **Mock Data Fallback**: When API unavailable
- **User Feedback**: Error banners and messages

### Component Error Boundaries
- **Graceful Degradation**: Fallback UI for errors
- **Error Logging**: Debug information for developers
- **User Recovery**: Clear error messages and retry options

### Debug Features
- **Console Logging**: Detailed debug information
- **API Testing**: Manual connectivity checks
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

# Start development server
npm start

# Build for production
npm run build

# Run tests
npm test
```

### Environment Variables
```bash
# .env.local (create if needed)
REACT_APP_API_TIMEOUT=15000
REACT_APP_RETRY_ATTEMPTS=3
REACT_APP_AUTO_REFRESH_INTERVAL=300000
```

### Development Scripts
- `npm start`: Development server
- `npm run build`: Production build
- `npm test`: Run tests
- `npm run eject`: Eject from CRA (not recommended)

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
- **Gzip Compression**: Enabled for all text assets
- **Caching**: Static assets cached for 1 year
- **Security Headers**: Comprehensive security configuration
- **Health Check**: `/health` endpoint for monitoring

### Environment Setup
- **Port**: 80 (HTTP), 443 (HTTPS)
- **SSL**: Optional SSL termination
- **Logging**: Nginx access and error logs
- **Monitoring**: Health check endpoint

## 🧪 Testing

### Testing Strategy
- **Unit Tests**: Component testing with React Testing Library
- **Integration Tests**: API integration testing
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

#### API Connection Issues
- **Symptom**: "Service Temporarily Unavailable" messages
- **Solution**: Check API endpoints and network connectivity
- **Debug**: Use DebugPanel to test API connectivity

#### Video Playback Issues
- **Symptom**: Video doesn't play on contact page
- **Solution**: Ensure video files are in public directory
- **Debug**: Check browser console for errors

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

### Log Files
- **Nginx Logs**: `/var/log/nginx/access.log`
- **Error Logs**: `/var/log/nginx/error.log`
- **Application Logs**: Browser console and debug panel

## 📚 Additional Resources

### Documentation
- [React Documentation](https://reactjs.org/docs/)
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
- ✅ **API Integration**: Axios with retry logic and mock data
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
- ✅ **Nginx Configuration**: Optimized for React SPA
- ✅ **Security Headers**: Comprehensive security configuration
- ✅ **Health Checks**: Monitoring endpoints
- ✅ **Documentation**: Internal and external documentation

#### Media Integration
- ✅ **FerryLight Display Images**: Physical display documentation
- ✅ **Video Demo**: Rotated 180° video with click-to-play
- ✅ **Responsive Media**: Optimized for all screen sizes

#### Security & Performance
- ✅ **Authentication**: Basic auth for APIs, admin session management
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