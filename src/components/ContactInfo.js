import React, { useRef } from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { FiMail, FiMonitor, FiSmartphone, FiPlay, FiWifi } from 'react-icons/fi';

const ContactContainer = styled.div`
  max-width: 800px;
  margin: 0 auto;
  padding: 1rem;
  flex: 1;
  display: flex;
  flex-direction: column;
`;

const ContactHeader = styled.div`
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
`;

const Subtitle = styled.p`
  font-size: 1rem;
  opacity: 0.9;
  margin: 0;
`;

const ContactCard = styled(motion.div)`
  background: #f8f9fa;
  border-radius: 0.8rem;
  padding: 1.5rem;
  box-shadow: 0 3px 12px rgba(0, 0, 0, 0.05);
  margin-bottom: 1.5rem;
  flex: 1;
`;

const ContactSection = styled.div`
  background: white;
  padding: 1.5rem;
  border-radius: 0.6rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  border-left: 3px solid #3498db;
  margin-bottom: 1.5rem;

  &:last-child {
    margin-bottom: 0;
  }
`;

const SectionTitle = styled.h3`
  color: #2c3e50;
  margin-bottom: 1rem;
  font-size: 1.2rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.4rem;
`;

const ContactEmail = styled(motion.a)`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.4rem;
  background: #3498db;
  color: white;
  text-decoration: none;
  padding: 0.8rem 1.5rem;
  border-radius: 0.4rem;
  font-weight: 500;
  transition: all 0.2s ease;
  font-size: 1rem;
  width: 100%;
  text-align: center;

  &:hover {
    background: #2980b9;
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(52, 152, 219, 0.3);
  }

  &:active {
    transform: translateY(0);
  }
`;

const FerryLightInfo = styled.div`
  color: #7f8c8d;
  font-size: 0.9rem;
  line-height: 1.5;
`;

const FerryLightItem = styled.div`
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 0.4rem;
  border-left: 3px solid #e67e22;

  &:last-child {
    margin-bottom: 0;
  }
`;

const FerryLightTitle = styled.h4`
  color: #2c3e50;
  margin-bottom: 0.5rem;
  font-size: 1rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.3rem;
`;

const FerryLightDescription = styled.p`
  color: #7f8c8d;
  font-size: 0.85rem;
  margin: 0 0 1rem 0;
  line-height: 1.4;
`;

const MediaGrid = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-top: 1rem;

  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
`;

const MediaItem = styled.div`
  background: #f1f2f6;
  border-radius: 0.4rem;
  overflow: hidden;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
`;

const MediaImage = styled.img`
  width: 100%;
  height: 200px;
  object-fit: cover;
  display: block;
`;

const VideoContainer = styled.div`
  position: relative;
  width: 100%;
  height: 200px;
  background: #000;
  border-radius: 0.4rem;
  overflow: hidden;
  cursor: pointer;
`;

const Video = styled.video`
  width: 100%;
  height: 100%;
  object-fit: cover;
  transform: rotate(180deg);
`;

const VideoOverlay = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 2rem;
  transition: background 0.2s ease;

  &:hover {
    background: rgba(0, 0, 0, 0.5);
  }
`;

const MediaCaption = styled.p`
  padding: 0.5rem;
  margin: 0;
  font-size: 0.8rem;
  color: #7f8c8d;
  text-align: center;
  background: #f8f9fa;
`;

const ContactInfoComponent = () => {
  const videoRef = useRef(null);

  const handleVideoClick = () => {
    if (videoRef.current) {
      if (videoRef.current.paused) {
        videoRef.current.play().catch(error => {
          console.log('Video play failed:', error);
        });
      } else {
        videoRef.current.pause();
      }
    }
  };

  const handleVideoLoad = () => {
    if (videoRef.current) {
      videoRef.current.muted = true;
    }
  };

  return (
    <ContactContainer>
      <ContactHeader>
        <Title>📞 Contact & Information</Title>
        <Subtitle>Get in touch or learn more about FerryLight</Subtitle>
      </ContactHeader>

      <ContactCard
        whileHover={{ scale: 1.01 }}
        transition={{ duration: 0.2 }}
      >
        <ContactSection>
          <SectionTitle>
            <FiMail />
            Contact
          </SectionTitle>
          <ContactEmail
            href="mailto:markus.van.kempen@gmail.com?subject=FerryLight%20Inquiry"
            target="_blank"
            rel="noopener noreferrer"
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            <FiMail />
           email markus
          </ContactEmail>
        </ContactSection>

        <ContactSection>
          <SectionTitle>
            <FiMonitor />
            About FerryLight
          </SectionTitle>
          <FerryLightInfo>
            <FerryLightItem>
              <FerryLightTitle>
                <FiSmartphone />
                FerryLight App
              </FerryLightTitle>
              <FerryLightDescription>
                A mobile application that provides real-time ferry status, wait times, and weather information for the Englishtown ↔ Jersey Cove route. Features include live updates, notifications, and an intuitive interface for travelers.
              </FerryLightDescription>
            </FerryLightItem>

            <FerryLightItem>
              <FerryLightTitle>
                <FiMonitor />
                FerryLight Display
              </FerryLightTitle>
              <FerryLightDescription>
                A physical LED display system that scrolls real-time information including time, date, ferry wait times, weather conditions, and event information. The display provides instant visual updates for travelers at ferry terminals and public locations.
              </FerryLightDescription>
              
              <FerryLightDescription>
                <FiWifi style={{ marginRight: '0.3rem' }} />
                <strong>WiFi Enabled:</strong> The FerryLight display connects wirelessly to receive real-time updates and can be remotely managed and configured.
              </FerryLightDescription>
              
              <MediaGrid>
                <MediaItem>
                  <MediaImage 
                    src="/PXL_20250728_111917466.jpg" 
                    alt="FerryLight Display showing LED grid"
                  />
                  <MediaCaption>FerryLight Display - LED Grid</MediaCaption>
                </MediaItem>
                
                <MediaItem>
                  <VideoContainer onClick={handleVideoClick}>
                    <Video 
                      ref={videoRef}
                      src="/PXL_20250728_111824584.mp4" 
                      muted 
                      loop 
                      playsInline
                      onLoadedData={handleVideoLoad}
                    />
                    <VideoOverlay>
                      <FiPlay />
                    </VideoOverlay>
                  </VideoContainer>
                  <MediaCaption>FerryLight Display - Video Demo (Click to play, rotated 180°)</MediaCaption>
                </MediaItem>
              </MediaGrid>
            </FerryLightItem>
          </FerryLightInfo>
        </ContactSection>
      </ContactCard>
    </ContactContainer>
  );
};

export default ContactInfoComponent; 