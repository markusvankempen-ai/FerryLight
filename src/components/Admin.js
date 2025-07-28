import React, { useState } from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { FiLogOut, FiShield, FiActivity, FiDatabase } from 'react-icons/fi';
import DebugPanel from './DebugPanel';

const AdminContainer = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
  flex: 1;
  display: flex;
  flex-direction: column;
`;

const AdminHeader = styled.div`
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

const AdminCard = styled(motion.div)`
  background: #f8f9fa;
  border-radius: 0.8rem;
  padding: 1.5rem;
  box-shadow: 0 3px 12px rgba(0, 0, 0, 0.05);
  margin-bottom: 1.5rem;
  flex: 1;
`;

const AdminToolbar = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: white;
  border-radius: 0.6rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
`;

const AdminInfo = styled.div`
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #2c3e50;
  font-weight: 500;
`;

const LogoutButton = styled(motion.button)`
  background: #e74c3c;
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 0.4rem;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.9rem;
  transition: all 0.2s ease;

  &:hover {
    background: #c0392b;
  }
`;

const AdminGrid = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
  margin-bottom: 1.5rem;

  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
`;

const AdminSection = styled.div`
  background: white;
  padding: 1.2rem;
  border-radius: 0.6rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  border-left: 3px solid #3498db;
`;

const SectionTitle = styled.h3`
  color: #2c3e50;
  margin-bottom: 1rem;
  font-size: 1.1rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.4rem;
`;

const SectionContent = styled.div`
  color: #7f8c8d;
  font-size: 0.9rem;
  line-height: 1.5;
`;

const StatusIndicator = styled.div`
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: ${props => props.status === 'online' ? '#27ae60' : '#e74c3c'};
  margin-right: 0.5rem;
`;

const Admin = ({ onLogout }) => {
  const [adminSession] = useState(() => {
    const admin = localStorage.getItem('ferrylight_admin');
    const adminTime = localStorage.getItem('ferrylight_admin_time');
    
    if (admin && adminTime) {
      const sessionAge = Date.now() - parseInt(adminTime);
      const sessionValid = sessionAge < 24 * 60 * 60 * 1000; // 24 hours
      
      if (!sessionValid) {
        localStorage.removeItem('ferrylight_admin');
        localStorage.removeItem('ferrylight_admin_time');
        return false;
      }
      
      return true;
    }
    
    return false;
  });

  const handleLogout = () => {
    localStorage.removeItem('ferrylight_admin');
    localStorage.removeItem('ferrylight_admin_time');
    onLogout();
  };

  if (!adminSession) {
    return (
      <AdminContainer>
        <AdminHeader>
          <Title>🔒 Access Denied</Title>
          <Subtitle>Please log in to access the admin panel</Subtitle>
        </AdminHeader>
      </AdminContainer>
    );
  }

  return (
    <AdminContainer>
      <AdminHeader>
        <Title>⚙️ Admin Panel</Title>
        <Subtitle>FerryLight System Administration</Subtitle>
      </AdminHeader>

      <AdminCard
        whileHover={{ scale: 1.01 }}
        transition={{ duration: 0.2 }}
      >
        <AdminToolbar>
          <AdminInfo>
            <FiShield />
            Admin Session Active
          </AdminInfo>
          <LogoutButton
            onClick={handleLogout}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            <FiLogOut />
            Logout
          </LogoutButton>
        </AdminToolbar>

        <AdminGrid>
          <AdminSection>
            <SectionTitle>
              <FiActivity />
              System Status
            </SectionTitle>
            <SectionContent>
              <p>
                <StatusIndicator status="online" />
                API Server: Online
              </p>
              <p>
                <StatusIndicator status="online" />
                Database: Connected
              </p>
              <p>
                <StatusIndicator status="online" />
                Weather Station: Active
              </p>
              <p>
                <StatusIndicator status="online" />
                Ferry Data: Live
              </p>
            </SectionContent>
          </AdminSection>

          <AdminSection>
            <SectionTitle>
              <FiDatabase />
              Data Management
            </SectionTitle>
            <SectionContent>
              <p>• Real-time ferry status monitoring</p>
              <p>• Weather data collection</p>
              <p>• API endpoint management</p>
              <p>• System diagnostics</p>
            </SectionContent>
          </AdminSection>
        </AdminGrid>

        <DebugPanel />
      </AdminCard>
    </AdminContainer>
  );
};

export default Admin; 