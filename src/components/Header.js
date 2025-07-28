import React, { useState } from 'react';
import styled from 'styled-components';
import { motion, AnimatePresence } from 'framer-motion';
import { FiRefreshCw, FiMenu, FiX, FiShield } from 'react-icons/fi';

const HeaderContainer = styled.header`
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  color: white;
  padding: 0.8rem 1.5rem;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  position: relative;
`;

const HeaderContent = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 1200px;
  margin: 0 auto;
`;

const Logo = styled.div`
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.5rem;
  font-weight: 700;
  cursor: pointer;
  transition: transform 0.2s ease;

  &:hover {
    transform: scale(1.05);
  }

  @media (max-width: 768px) {
    font-size: 1.2rem;
  }
`;

const Navigation = styled.nav`
  display: flex;
  align-items: center;
  gap: 1rem;

  @media (max-width: 768px) {
    display: none;
  }
`;

const NavLink = styled(motion.button)`
  background: none;
  border: none;
  color: ${props => props.$isActive ? '#3498db' : 'white'};
  padding: 0.5rem 1rem;
  border-radius: 0.4rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 0.9rem;

  &:hover {
    background: rgba(255, 255, 255, 0.1);
    color: ${props => props.$isActive ? '#3498db' : 'white'};
  }

  &:active {
    transform: scale(0.95);
  }
`;

const RefreshButton = styled(motion.button)`
  background: #3498db;
  color: white;
  border: none;
  padding: 0.5rem;
  border-radius: 0.4rem;
  cursor: pointer;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1rem;
  transition: all 0.2s ease;
  width: 2.5rem;
  height: 2.5rem;

  &:hover {
    background: #2980b9;
    transform: translateY(-1px);
  }

  &:disabled {
    background: #95a5a6;
    cursor: not-allowed;
    transform: none;
  }

  @media (max-width: 768px) {
    width: 2.2rem;
    height: 2.2rem;
    font-size: 0.9rem;
  }
`;

const AdminButton = styled(motion.button)`
  background: #e67e22;
  color: white;
  border: none;
  padding: 0.5rem;
  border-radius: 0.4rem;
  cursor: pointer;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1rem;
  transition: all 0.2s ease;
  width: 2.5rem;
  height: 2.5rem;

  &:hover {
    background: #d35400;
    transform: translateY(-1px);
  }

  @media (max-width: 768px) {
    display: none;
  }
`;

const MobileMenuButton = styled.button`
  display: none;
  background: none;
  border: none;
  color: white;
  font-size: 1.5rem;
  cursor: pointer;
  padding: 0.5rem;

  @media (max-width: 768px) {
    display: block;
  }
`;

const MobileMenu = styled(motion.div)`
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: #2c3e50;
  padding: 1rem;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
  z-index: 1000;
  display: none;

  @media (max-width: 768px) {
    display: block;
  }
`;

const MobileNavLink = styled.button`
  display: block;
  width: 100%;
  background: none;
  border: none;
  color: ${props => props.$isActive ? '#3498db' : 'white'};
  padding: 0.8rem 1rem;
  text-align: left;
  font-weight: 500;
  cursor: pointer;
  border-radius: 0.3rem;
  margin-bottom: 0.5rem;
  font-size: 0.9rem;

  &:hover {
    background: rgba(255, 255, 255, 0.1);
  }

  &:last-child {
    margin-bottom: 0;
  }
`;

const LoadingSpinner = styled.div`
  display: inline-block;
  width: 1rem;
  height: 1rem;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: white;
  animation: spin 1s ease-in-out infinite;

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
`;

const Header = ({ activePage, onPageChange, onRefresh, isLoading, isLoggedIn, onAdminClick }) => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const navItems = [
    { id: 'ferry', label: '🚢 Ferry Status' },
    { id: 'weather', label: '☁️ Weather' },
    { id: 'ferrylight', label: '💡 FerryLight' },
    { id: 'contact', label: '📞 Contact' }
  ];

  const handleNavClick = (pageId) => {
    onPageChange(pageId);
    setIsMobileMenuOpen(false);
  };

  const handleRefresh = () => {
    onRefresh();
    setIsMobileMenuOpen(false);
  };

  const handleAdminClick = () => {
    onAdminClick();
    setIsMobileMenuOpen(false);
  };

  return (
    <HeaderContainer>
      <HeaderContent>
        <Logo onClick={() => handleNavClick('ferry')}>
          FerryLight
        </Logo>

        <Navigation>
          {navItems.map((item) => (
            <NavLink
              key={item.id}
              $isActive={activePage === item.id}
              onClick={() => handleNavClick(item.id)}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              {item.label}
            </NavLink>
          ))}
        </Navigation>

        <div style={{ display: 'flex', alignItems: 'center', gap: '0.8rem' }}>
          <RefreshButton
            onClick={handleRefresh}
            disabled={isLoading}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            title="Refresh Data"
          >
            {isLoading ? (
              <LoadingSpinner />
            ) : (
              <FiRefreshCw />
            )}
          </RefreshButton>

          {!isLoggedIn && (
            <AdminButton
              onClick={handleAdminClick}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.98 }}
              title="Admin Login"
            >
              <FiShield />
            </AdminButton>
          )}
        </div>

        <MobileMenuButton
          onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
        >
          {isMobileMenuOpen ? <FiX /> : <FiMenu />}
        </MobileMenuButton>
      </HeaderContent>

      <AnimatePresence>
        {isMobileMenuOpen && (
          <MobileMenu
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            transition={{ duration: 0.2 }}
          >
            {navItems.map((item) => (
              <MobileNavLink
                key={item.id}
                $isActive={activePage === item.id}
                onClick={() => handleNavClick(item.id)}
              >
                {item.label}
              </MobileNavLink>
            ))}
            <MobileNavLink onClick={handleRefresh}>
              <FiRefreshCw style={{ marginRight: '0.5rem' }} />
              Refresh Data
            </MobileNavLink>
            {!isLoggedIn && (
              <MobileNavLink onClick={handleAdminClick}>
                <FiShield style={{ marginRight: '0.5rem' }} />
                Admin Login
              </MobileNavLink>
            )}
          </MobileMenu>
        )}
      </AnimatePresence>
    </HeaderContainer>
  );
};

export default Header; 