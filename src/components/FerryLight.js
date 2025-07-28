import React, { useEffect, useRef, useState, useCallback } from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { logDebug } from '../utils/debug';

// Responsive matrix dimensions - simplified to prevent constant re-renders
const getMatrixDimensions = () => {
  if (typeof window !== 'undefined') {
    const width = window.innerWidth;
    if (width <= 768) {
      return { width: 96, height: 16, scale: 1.5 };
    } else if (width <= 1200) {
      return { width: 128, height: 16, scale: 2 };
    } else {
      return { width: 128, height: 16, scale: 2.5 };
    }
  }
  return { width: 128, height: 16, scale: 2.5 }; // Default for SSR
};

// Constants for matrix display
const DOT_SIZE = 3;
const DOT_SPACING = 1;

// Simple 5x7 Dot Matrix Font
const DOT_FONT = {
  'A': [0x0E, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11],
  'B': [0x1E, 0x11, 0x11, 0x1E, 0x11, 0x11, 0x1E],
  'C': [0x0E, 0x11, 0x10, 0x10, 0x10, 0x11, 0x0E],
  'D': [0x1E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x1E],
  'E': [0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x1F],
  'F': [0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x10],
  'G': [0x0E, 0x11, 0x10, 0x17, 0x11, 0x11, 0x0E],
  'H': [0x11, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11],
  'I': [0x0E, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0E],
  'J': [0x07, 0x02, 0x02, 0x02, 0x02, 0x12, 0x0C],
  'K': [0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11],
  'L': [0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1F],
  'M': [0x11, 0x1B, 0x15, 0x15, 0x11, 0x11, 0x11],
  'N': [0x11, 0x11, 0x19, 0x15, 0x13, 0x11, 0x11],
  'O': [0x0E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E],
  'P': [0x1E, 0x11, 0x11, 0x1E, 0x10, 0x10, 0x10],
  'Q': [0x0E, 0x11, 0x11, 0x11, 0x15, 0x12, 0x0D],
  'R': [0x1E, 0x11, 0x11, 0x1E, 0x14, 0x12, 0x11],
  'S': [0x0E, 0x11, 0x10, 0x0E, 0x01, 0x11, 0x0E],
  'T': [0x1F, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04],
  'U': [0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E],
  'V': [0x11, 0x11, 0x11, 0x11, 0x11, 0x0A, 0x04],
  'W': [0x11, 0x11, 0x11, 0x15, 0x15, 0x1B, 0x11],
  'X': [0x11, 0x11, 0x0A, 0x04, 0x0A, 0x11, 0x11],
  'Y': [0x11, 0x11, 0x0A, 0x04, 0x04, 0x04, 0x04],
  'Z': [0x1F, 0x01, 0x02, 0x04, 0x08, 0x10, 0x1F],
  '0': [0x0E, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0E],
  '1': [0x04, 0x0C, 0x04, 0x04, 0x04, 0x04, 0x0E],
  '2': [0x0E, 0x11, 0x01, 0x02, 0x04, 0x08, 0x1F],
  '3': [0x0E, 0x11, 0x01, 0x0E, 0x01, 0x11, 0x0E],
  '4': [0x02, 0x06, 0x0A, 0x12, 0x1F, 0x02, 0x02],
  '5': [0x1F, 0x10, 0x1E, 0x01, 0x01, 0x11, 0x0E],
  '6': [0x0E, 0x11, 0x10, 0x1E, 0x11, 0x11, 0x0E],
  '7': [0x1F, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08],
  '8': [0x0E, 0x11, 0x11, 0x0E, 0x11, 0x11, 0x0E],
  '9': [0x0E, 0x11, 0x11, 0x0F, 0x01, 0x11, 0x0E],
  ' ': [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
  '-': [0x00, 0x00, 0x00, 0x1F, 0x00, 0x00, 0x00],
  ':': [0x00, 0x04, 0x00, 0x00, 0x04, 0x00, 0x00],
  '→': [0x00, 0x04, 0x02, 0x1F, 0x02, 0x04, 0x00],
  '↔': [0x04, 0x02, 0x1F, 0x02, 0x04, 0x08, 0x1F, 0x08, 0x04]
};

const FONT_CHAR_WIDTH = 5;
const FONT_CHAR_HEIGHT = 7;
const CHARACTER_SPACING_X = 1;
const CHARACTER_START_Y = (FONT_CHAR_HEIGHT - 1) / 2;

// Debug logging function for FerryLight component
const logFerryLightDebug = (message, data = null) => {
  logDebug(`[FerryLight] ${message}`, data);
};

// Helper function to generate matrix text from ferry data
const generateMatrixText = (ferryData) => {
  if (!ferryData) return 'FerryLight - No Data';

  try {
    const status = ferryData.ferryStatus?.status || 'Unknown';
    const directions = ferryData.directions;

    if (!directions) {
      return `Ferry: ${status}`;
    }

    // Helper function to format wait time for display
    const formatWaitTime = (waitTime) => {
      const time = parseInt(waitTime) || 0;
      return time <= 18 ? 'No Wait' : `${time}min`;
    };

    const jersey = formatWaitTime(directions.jerseyToEnglishtown?.waitTime?.waitTime || 0);
    const englishtown = formatWaitTime(directions.englishtownToJersey?.waitTime?.waitTime || 0);

    // Create scrolling text with wait times
    return `Ferry Status: ${status} | Jersey→Englishtown: ${jersey} | Englishtown→Jersey: ${englishtown} | `;
  } catch (error) {
    logFerryLightDebug('❌ Error generating matrix text:', error);
    return 'FerryLight - Data Error';
  }
};

const FerryLightComponent = ({ data, isLoading, error }) => {
  const canvasRef = useRef(null);
  const animationRef = useRef(null);
  const lastTimestamp = useRef(0);
  const [currentMatrixText, setCurrentMatrixText] = useState('');
  const [matrixDimensions, setMatrixDimensions] = useState(() => getMatrixDimensions());
  const animationActive = useRef(false);

  // Update matrix dimensions on window resize - with debouncing
  useEffect(() => {
    let resizeTimeout;
    const handleResize = () => {
      clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(() => {
        const newDimensions = getMatrixDimensions();
        setMatrixDimensions(newDimensions);
      }, 250); // Debounce resize events
    };

    window.addEventListener('resize', handleResize);
    return () => {
      window.removeEventListener('resize', handleResize);
      clearTimeout(resizeTimeout);
    };
  }, []);

  const drawPixel = useCallback((ctx, x, y, color = '#FFC107') => {
    if (x >= 0 && x < matrixDimensions.width && y >= 0 && y < matrixDimensions.height) {
      ctx.fillStyle = color;
      ctx.fillRect(x * DOT_SIZE + x * DOT_SPACING, y * DOT_SIZE + y * DOT_SPACING, DOT_SIZE, DOT_SIZE);
    }
  }, [matrixDimensions.width, matrixDimensions.height]);

  const drawCharacter = useCallback((ctx, char, offsetX = 0, offsetY = 0, color = '#FFC107') => {
    const charData = DOT_FONT[char.toUpperCase()] || DOT_FONT[' '];
    
    for (let y = 0; y < FONT_CHAR_HEIGHT; y++) {
      for (let x = 0; x < FONT_CHAR_WIDTH; x++) {
        if (charData[y] & (0x10 >> x)) {
          drawPixel(ctx, offsetX + x, offsetY + y, color);
        }
      }
    }
  }, [drawPixel]);

  // Stabilized animation function that doesn't depend on changing scrollOffset
  const animateMatrixText = useCallback((ctx, text, currentScrollOffset) => {
    if (!text || text.length === 0) {
      return;
    }

    const totalTextWidth = (text.length + 10) * (FONT_CHAR_WIDTH + CHARACTER_SPACING_X);
    const scrollLimit = totalTextWidth - matrixDimensions.width + CHARACTER_SPACING_X;

    // Clear the canvas
    ctx.clearRect(0, 0, matrixDimensions.width * (DOT_SIZE + DOT_SPACING), matrixDimensions.height * (DOT_SIZE + DOT_SPACING));

    // Draw current text
    let currentX = 0;
    for (let i = 0; i < text.length; i++) {
      const char = text[i];
      const charLogicalX = currentX - currentScrollOffset;

      if (charLogicalX + FONT_CHAR_WIDTH > 0 && charLogicalX < matrixDimensions.width) {
        drawCharacter(ctx, char, charLogicalX, CHARACTER_START_Y);
      }
      currentX += FONT_CHAR_WIDTH + CHARACTER_SPACING_X;
    }

    // Return new scroll offset
    if (totalTextWidth > matrixDimensions.width) {
      const newScrollOffset = currentScrollOffset + 0.5; // Slower scroll speed
      if (newScrollOffset >= scrollLimit) {
        return 0; // Reset scroll
      } else {
        return newScrollOffset;
      }
    } else {
      return (matrixDimensions.width - totalTextWidth) / 2;
    }
  }, [matrixDimensions.width, matrixDimensions.height, drawCharacter]);

  // Update text when data changes
  useEffect(() => {
    if (data) {
      const ferryData = data;
      const matrixText = generateMatrixText(ferryData);

      logFerryLightDebug('📝 Setting matrix text:', {
        matrixText,
        ferryData: {
          hasStatus: !!ferryData.ferryStatus,
          hasDirections: !!ferryData.directions,
          status: ferryData.ferryStatus?.status
        }
      });

      setCurrentMatrixText(matrixText.toUpperCase());
    }
  }, [data]);

  // Set up canvas and start animation - stable version
  useEffect(() => {
    if (currentMatrixText && canvasRef.current && !animationActive.current) {
      const canvas = canvasRef.current;
      const ctx = canvas.getContext('2d');
      
      // Set canvas dimensions based on responsive size
      canvas.width = matrixDimensions.width * (DOT_SIZE + DOT_SPACING);
      canvas.height = matrixDimensions.height * (DOT_SIZE + DOT_SPACING);
      
      // Clear canvas
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      
      // Mark animation as active
      animationActive.current = true;
      let currentScrollOffset = 0;
      
      const animate = (timestamp) => {
        if (timestamp - lastTimestamp.current > 100) { // 10 FPS for smoother animation
          currentScrollOffset = animateMatrixText(ctx, currentMatrixText, currentScrollOffset);
          lastTimestamp.current = timestamp;
        }
        if (animationActive.current) {
          animationRef.current = requestAnimationFrame(animate);
        }
      };
      
      animationRef.current = requestAnimationFrame(animate);
      
      return () => {
        if (animationRef.current) {
          cancelAnimationFrame(animationRef.current);
        }
        animationActive.current = false;
      };
    }
  }, [currentMatrixText, matrixDimensions, animateMatrixText]);

  if (isLoading) {
    logFerryLightDebug('⏳ Showing loading state');
    return (
      <FerryLightContainer>
        <LoadingMessage>Loading FerryLight data...</LoadingMessage>
      </FerryLightContainer>
    );
  }

  if (error) {
    logFerryLightDebug('❌ Showing error state:', error);
    return (
      <FerryLightContainer>
        <ApiStatusBanner type="error" message={error} />
      </FerryLightContainer>
    );
  }

  if (!data && !isLoading && !error) {
    logFerryLightDebug('📊 No data available');
    return (
      <FerryLightContainer>
        <NoDataMessage>No FerryLight data available.</NoDataMessage>
      </FerryLightContainer>
    );
  }

  const displayText = currentMatrixText || generateMatrixText(data) || 'FerryLight - Ready';

  return (
    <FerryLightContainer
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
    >
      <FerryLightHeader>
        <Title>💡 FerryLight Display</Title>
        <Subtitle>LED Matrix Display Simulation</Subtitle>
      </FerryLightHeader>

      {error && <ApiStatusBanner type="error" message={error} />}
      {isLoading && <LoadingMessage>Loading FerryLight data...</LoadingMessage>}
      {!data && !isLoading && !error && <NoDataMessage>No FerryLight data available.</NoDataMessage>}

      <FerryLightCard
        whileHover={{ scale: 1.01 }}
        transition={{ duration: 0.2 }}
      >
        <TextPreview>
          Text for this display: <strong>{displayText}</strong>
        </TextPreview>
        
        <DisplaySection>
          <DisplayContainer>
            <MatrixCanvas 
              ref={canvasRef} 
              width={matrixDimensions.width * (DOT_SIZE + DOT_SPACING)} 
              height={matrixDimensions.height * (DOT_SIZE + DOT_SPACING)}
              style={{ 
                transform: `scale(${matrixDimensions.scale})`,
                transformOrigin: 'center'
              }}
            />
            <MatrixInfo>
              {matrixDimensions.width}×{matrixDimensions.height} LED Matrix Display | Auto-scrolling text with ferry wait times
            </MatrixInfo>
          </DisplayContainer>

          <PhysicalDisplayContainer>
            <PhysicalDisplayImage 
              src="/PXL_20250728_114847934.jpg"
              alt="Physical FerryLight Display showing 'English' text"
            />
          </PhysicalDisplayContainer>
        </DisplaySection>
      </FerryLightCard>
    </FerryLightContainer>
  );
};

const FerryLightContainer = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
  flex: 1;
  display: flex;
  flex-direction: column;
`;

const FerryLightHeader = styled.div`
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  color: white;
  padding: 1.5rem;
  text-align: center;
  border-radius: 0.8rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
`;

const Title = styled.h1`
  font-size: 2rem;
  margin-bottom: 0.3rem;
  font-weight: 700;

  @media (max-width: 768px) {
    font-size: 1.5rem;
  }

  @media (min-width: 1200px) {
    font-size: 2.5rem;
  }
`;

const Subtitle = styled.p`
  font-size: 1rem;
  opacity: 0.9;
  margin: 0;

  @media (max-width: 768px) {
    font-size: 0.9rem;
  }

  @media (min-width: 1200px) {
    font-size: 1.1rem;
  }
`;

const FerryLightCard = styled(motion.div)`
  background: white;
  padding: 1.5rem;
  border-radius: 0.8rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  flex: 1;
`;

const TextPreview = styled.div`
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 0.4rem;
  margin-bottom: 1.5rem;
  font-size: 0.9rem;
  color: #2c3e50;
  border-left: 3px solid #3498db;

  @media (max-width: 768px) {
    font-size: 0.8rem;
    padding: 0.8rem;
  }

  @media (min-width: 1200px) {
    font-size: 1rem;
    padding: 1.2rem;
  }
`;

const DisplaySection = styled.div`
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
`;

const DisplayContainer = styled.div`
  text-align: center;
  padding: 1.2rem;
  background: #222;
  border-radius: 0.6rem;
  box-shadow: inset 0 0 8px rgba(0, 0, 0, 0.5);
  overflow: hidden;
  width: 100%;
  height: fit-content;
  display: flex;
  flex-direction: column;
  align-items: center;
`;

const MatrixCanvas = styled.canvas`
  border: 1px solid #444;
  border-radius: 0.3rem;
  background: #000;
  margin-bottom: 1rem;
`;

const MatrixInfo = styled.div`
  color: #ccc;
  font-size: 0.8rem;
  text-align: center;

  @media (max-width: 768px) {
    font-size: 0.7rem;
  }

  @media (min-width: 1200px) {
    font-size: 0.9rem;
  }
`;

const PhysicalDisplayContainer = styled.div`
  text-align: center;
`;

const PhysicalDisplayImage = styled.img`
  width: 100%;
  max-width: 600px;
  height: auto;
  border-radius: 0.4rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);

  @media (max-width: 768px) {
    max-width: 100%;
  }

  @media (min-width: 1200px) {
    max-width: 800px;
  }
`;

const LoadingMessage = styled.div`
  text-align: center;
  padding: 2rem;
  color: #7f8c8d;
  font-size: 1.1rem;
`;

const NoDataMessage = styled.div`
  text-align: center;
  padding: 2rem;
  color: #e74c3c;
  font-size: 1.1rem;
`;

const ApiStatusBanner = styled.div`
  background: ${props => props.type === 'error' ? '#e74c3c' : '#f39c12'};
  color: white;
  padding: 0.8rem;
  text-align: center;
  border-radius: 0.4rem;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  font-weight: 500;
  font-size: 0.9rem;
`;

export default FerryLightComponent; 