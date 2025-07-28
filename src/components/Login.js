import React, { useState } from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { FiLock, FiEye, FiEyeOff, FiUser, FiAlertCircle } from 'react-icons/fi';

const LoginContainer = styled.div`
  max-width: 400px;
  margin: 0 auto;
  padding: 1rem;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
`;

const LoginCard = styled(motion.div)`
  background: #f8f9fa;
  border-radius: 0.8rem;
  padding: 2rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  text-align: center;
`;

const LoginHeader = styled.div`
  margin-bottom: 2rem;
`;

const Title = styled.h1`
  font-size: 2rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
  font-weight: 700;
`;

const Subtitle = styled.p`
  color: #7f8c8d;
  font-size: 1rem;
  margin: 0;
`;

const Form = styled.form`
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
`;

const InputGroup = styled.div`
  position: relative;
`;

const Input = styled.input`
  width: 100%;
  padding: 1rem;
  border: 2px solid #e1e8ed;
  border-radius: 0.5rem;
  font-size: 1rem;
  transition: all 0.2s ease;
  background: white;

  &:focus {
    outline: none;
    border-color: #3498db;
    box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
  }

  &::placeholder {
    color: #95a5a6;
  }
`;

const PasswordToggle = styled.button`
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: #7f8c8d;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 0.3rem;
  transition: all 0.2s ease;

  &:hover {
    color: #2c3e50;
    background: rgba(0, 0, 0, 0.05);
  }
`;

const LoginButton = styled(motion.button)`
  background: #3498db;
  color: white;
  border: none;
  padding: 1rem;
  border-radius: 0.5rem;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;

  &:hover {
    background: #2980b9;
  }

  &:disabled {
    background: #95a5a6;
    cursor: not-allowed;
  }
`;

const ErrorMessage = styled.div`
  background: #e74c3c;
  color: white;
  padding: 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
`;

const SuccessMessage = styled.div`
  background: #27ae60;
  color: white;
  padding: 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
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

const Login = ({ onLoginSuccess }) => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!username || !password) {
      setError('Please enter both username and password');
      return;
    }

    setIsLoading(true);
    setError('');
    setSuccess('');

    // Simulate API call delay
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Check credentials - use environment variables for security
    const adminUsername = process.env.REACT_APP_ADMIN_USERNAME || 'admin';
    const adminPassword = process.env.REACT_APP_ADMIN_PASSWORD || 'admin';
    
    if (username === adminUsername && password === adminPassword) {
      setSuccess('Login successful! Redirecting to admin panel...');
      
      // Store admin session
      localStorage.setItem('ferrylight_admin', 'true');
      localStorage.setItem('ferrylight_admin_time', Date.now().toString());
      
      // Redirect to admin panel after a short delay
      setTimeout(() => {
        onLoginSuccess();
      }, 1500);
    } else {
      setError('Invalid username or password');
    }

    setIsLoading(false);
  };

  const togglePasswordVisibility = () => {
    setShowPassword(!showPassword);
  };

  return (
    <LoginContainer>
      <LoginCard
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <LoginHeader>
          <Title>🔐 Admin Login</Title>
          <Subtitle>Access FerryLight administration panel</Subtitle>
        </LoginHeader>

        {error && (
          <ErrorMessage>
            <FiAlertCircle />
            {error}
          </ErrorMessage>
        )}

        {success && (
          <SuccessMessage>
            <FiUser />
            {success}
          </SuccessMessage>
        )}

        <Form onSubmit={handleSubmit}>
          <InputGroup>
            <Input
              type="text"
              placeholder="Username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              disabled={isLoading}
            />
          </InputGroup>

          <InputGroup>
            <Input
              type={showPassword ? 'text' : 'password'}
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              disabled={isLoading}
            />
            <PasswordToggle
              type="button"
              onClick={togglePasswordVisibility}
              disabled={isLoading}
            >
              {showPassword ? <FiEyeOff /> : <FiEye />}
            </PasswordToggle>
          </InputGroup>

          <LoginButton
            type="submit"
            disabled={isLoading}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            {isLoading ? (
              <>
                <LoadingSpinner />
                Logging in...
              </>
            ) : (
              <>
                <FiLock />
                Login
              </>
            )}
          </LoginButton>
        </Form>
      </LoginCard>
    </LoginContainer>
  );
};

export default Login; 