#!/usr/bin/env node

/**
 * Generate Favicons Script for FerryLight
 * This script generates all necessary favicon files from the SVG template
 */

const fs = require('fs');
const path = require('path');

// SVG template for favicon
const faviconSVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" width="32" height="32">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- Background circle -->
  <circle cx="16" cy="16" r="15" fill="url(#grad1)" stroke="#2c3e50" stroke-width="1"/>
  
  <!-- Ferry/boat icon -->
  <path d="M8 20 L24 20 L22 24 L10 24 Z" fill="#ffffff" opacity="0.9"/>
  <path d="M12 16 L20 16 L18 20 L14 20 Z" fill="#ffffff" opacity="0.7"/>
  <circle cx="16" cy="12" r="2" fill="#ffffff" opacity="0.8"/>
  
  <!-- Water waves -->
  <path d="M6 26 Q10 24 14 26 Q18 28 22 26 Q26 24 30 26" stroke="#ffffff" stroke-width="1" fill="none" opacity="0.6"/>
</svg>`;

// Safari pinned tab SVG
const safariPinnedSVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- Background circle -->
  <circle cx="8" cy="8" r="7" fill="url(#grad1)" stroke="#2c3e50" stroke-width="0.5"/>
  
  <!-- Ferry/boat icon -->
  <path d="M4 10 L12 10 L11 12 L5 12 Z" fill="#ffffff" opacity="0.9"/>
  <path d="M6 8 L10 8 L9 10 L7 10 Z" fill="#ffffff" opacity="0.7"/>
  <circle cx="8" cy="6" r="1" fill="#ffffff" opacity="0.8"/>
  
  <!-- Water waves -->
  <path d="M3 13 Q5 12 7 13 Q9 14 11 13 Q13 12 15 13" stroke="#ffffff" stroke-width="0.5" fill="none" opacity="0.6"/>
</svg>`;

// Browserconfig.xml content
const browserConfigXML = `<?xml version="1.0" encoding="utf-8"?>
<browserconfig>
    <msapplication>
        <tile>
            <square150x150logo src="%PUBLIC_URL%/logo192.png"/>
            <square310x310logo src="%PUBLIC_URL%/logo512.png"/>
            <TileColor>#667eea</TileColor>
        </tile>
    </msapplication>
</browserconfig>`;

// Function to write files
function writeFile(filePath, content) {
  try {
    fs.writeFileSync(filePath, content);
    console.log(`✅ Created: ${filePath}`);
  } catch (error) {
    console.error(`❌ Error creating ${filePath}:`, error.message);
  }
}

// Function to create directory if it doesn't exist
function ensureDirectoryExists(filePath) {
  const dir = path.dirname(filePath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

// Main function
function generateFavicons() {
  console.log('🚢 Generating FerryLight favicons...');
  
  const publicDir = path.join(__dirname, '..', 'public');
  
  // Create SVG favicon
  writeFile(path.join(publicDir, 'favicon.svg'), faviconSVG);
  
  // Create Safari pinned tab SVG
  writeFile(path.join(publicDir, 'safari-pinned-tab.svg'), safariPinnedSVG);
  
  // Create browserconfig.xml
  writeFile(path.join(publicDir, 'browserconfig.xml'), browserConfigXML);
  
  // Create placeholder files for PNG icons (these would be generated with a proper image processing library)
  const pngPlaceholders = [
    'favicon-16x16.png',
    'favicon-32x32.png', 
    'logo192.png',
    'logo512.png'
  ];
  
  pngPlaceholders.forEach(filename => {
    const filePath = path.join(publicDir, filename);
    const placeholderContent = `# This is a placeholder for ${filename}
# In a real implementation, this would be a PNG file
# Generated from the SVG favicon using an image processing library
# For now, this serves as a placeholder to prevent 404 errors`;
    
    writeFile(filePath, placeholderContent);
  });
  
  console.log('🎉 Favicon generation complete!');
  console.log('');
  console.log('📝 Note: PNG files are placeholders. To generate actual PNG files:');
  console.log('   1. Install a tool like sharp, jimp, or use an online SVG to PNG converter');
  console.log('   2. Convert the SVG favicon to the required PNG sizes');
  console.log('   3. Replace the placeholder files with actual PNG images');
  console.log('');
  console.log('🔗 Online tools you can use:');
  console.log('   - https://realfavicongenerator.net/');
  console.log('   - https://favicon.io/');
  console.log('   - https://www.favicon-generator.org/');
}

// Run the script
if (require.main === module) {
  generateFavicons();
}

module.exports = { generateFavicons }; 