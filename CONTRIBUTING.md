# Contributing to FerryLight

Thank you for your interest in contributing to FerryLight! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Types of Contributions

We welcome contributions in the following areas:

- **Bug Reports**: Help us identify and fix issues
- **Feature Requests**: Suggest new features or improvements
- **Code Contributions**: Submit pull requests with code changes
- **Documentation**: Improve or add documentation
- **Testing**: Help with testing and quality assurance
- **Design**: UI/UX improvements and design suggestions

### Before You Start

1. **Check Existing Issues**: Look through existing issues to avoid duplicates
2. **Read Documentation**: Familiarize yourself with the project structure
3. **Set Up Development Environment**: Follow the setup instructions in README.md

## 🛠️ Development Setup

### Prerequisites

- Node.js 18+
- npm or yarn
- Git
- Docker (for testing deployment)

### Local Development

```bash
# Fork and clone the repository
git clone https://github.com/yourusername/ferrylight-app.git
cd ferrylight-app

# Install dependencies
npm install

# Start development server
npm start

# Run tests
npm test

# Build for production
npm run build
```

### Code Style Guidelines

#### JavaScript/React
- Use **ES6+** features
- Follow **ESLint** configuration
- Use **functional components** with hooks
- Implement **proper error handling**
- Add **JSDoc comments** for complex functions

#### Styling
- Use **Styled Components** for styling
- Follow **mobile-first** responsive design
- Maintain **consistent spacing** (0.8rem base unit)
- Use **semantic color names** and CSS variables

#### File Naming
- **Components**: PascalCase (e.g., `FerryStatus.js`)
- **Utilities**: camelCase (e.g., `apiService.js`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `API_ENDPOINTS.js`)

## 📝 Pull Request Process

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 2. Make Your Changes

- Write **clear, descriptive commit messages**
- Follow the **existing code style**
- Add **tests** for new functionality
- Update **documentation** as needed

### 3. Test Your Changes

```bash
# Run all tests
npm test

# Run tests with coverage
npm test -- --coverage

# Build for production
npm run build

# Test Docker build
docker build -t ferrylight-test .
```

### 4. Submit a Pull Request

- **Title**: Clear, descriptive title
- **Description**: Detailed description of changes
- **Related Issues**: Link to any related issues
- **Screenshots**: Include screenshots for UI changes

### Pull Request Template

```markdown
## Description
Brief description of the changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Refactoring

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] No console errors

## Screenshots (if applicable)
Add screenshots for UI changes.

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No sensitive information included
```

## 🧪 Testing Guidelines

### Unit Tests
- Test **component rendering** and **user interactions**
- Mock **API calls** and **external dependencies**
- Test **error states** and **edge cases**
- Aim for **80%+ code coverage**

### Integration Tests
- Test **API integration** and **data flow**
- Verify **authentication** and **session management**
- Test **error handling** and **fallback scenarios**

### Manual Testing
- Test on **multiple browsers** (Chrome, Firefox, Safari, Edge)
- Test on **mobile devices** and **tablets**
- Verify **accessibility** features
- Test **offline functionality**

## 🐛 Bug Reports

### Before Reporting
1. **Search existing issues** for similar problems
2. **Test on latest version** of the app
3. **Clear browser cache** and try again
4. **Check browser console** for errors

### Bug Report Template

```markdown
## Bug Description
Clear description of the bug.

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

## Expected Behavior
What you expected to happen.

## Actual Behavior
What actually happened.

## Environment
- Browser: [e.g., Chrome 91]
- OS: [e.g., macOS 12.0]
- Device: [e.g., Desktop/Mobile]

## Additional Information
Screenshots, console logs, or other relevant information.
```

## 💡 Feature Requests

### Before Requesting
1. **Check existing issues** for similar requests
2. **Consider the scope** and **complexity**
3. **Think about user value** and **impact**

### Feature Request Template

```markdown
## Feature Description
Clear description of the requested feature.

## Problem Statement
What problem does this feature solve?

## Proposed Solution
How should this feature work?

## Alternative Solutions
Any alternative approaches considered?

## Additional Context
Screenshots, mockups, or other relevant information.
```

## 🔒 Security

### Security Guidelines
- **Never commit sensitive information** (API keys, passwords, etc.)
- **Use environment variables** for configuration
- **Validate user input** and **sanitize data**
- **Follow security best practices** for authentication
- **Report security issues** privately to maintainers

### Security Issues
If you discover a security vulnerability, please:
1. **Do not create a public issue**
2. **Email the maintainers** directly
3. **Provide detailed information** about the vulnerability
4. **Allow time** for assessment and fix

## 📚 Documentation

### Documentation Standards
- **Keep documentation up-to-date** with code changes
- **Use clear, concise language**
- **Include code examples** where helpful
- **Add screenshots** for UI documentation
- **Follow markdown formatting** guidelines

### Documentation Areas
- **API documentation** for new endpoints
- **Component documentation** for new components
- **Setup instructions** for new features
- **Troubleshooting guides** for common issues

## 🏷️ Issue Labels

We use the following labels to categorize issues:

- **bug**: Something isn't working
- **enhancement**: New feature or request
- **documentation**: Improvements or additions to documentation
- **good first issue**: Good for newcomers
- **help wanted**: Extra attention is needed
- **question**: Further information is requested
- **wontfix**: This will not be worked on

## 🎯 Code of Conduct

### Our Standards
- **Be respectful** and **inclusive**
- **Use welcoming and inclusive language**
- **Be collaborative** and **constructive**
- **Focus on what is best for the community**
- **Show empathy** towards other community members

### Enforcement
- **Unacceptable behavior** will not be tolerated
- **Maintainers** will address and resolve conflicts
- **Violations** may result in temporary or permanent bans

## 🙏 Recognition

### Contributors
- **All contributors** will be recognized in the project
- **Significant contributions** will be highlighted
- **Regular contributors** may be invited to join the team

### Ways to Contribute
- **Code contributions** through pull requests
- **Bug reports** and **feature requests**
- **Documentation** improvements
- **Testing** and **quality assurance**
- **Community support** and **helping others**

## 📞 Getting Help

### Questions and Support
- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Email**: For security issues or private matters

### Resources
- **README.md**: Project overview and setup
- **INTERNAL_DOCUMENTATION.md**: Detailed technical documentation
- **API Documentation**: External API integration details
- **React Documentation**: React framework documentation

---

**Thank you for contributing to FerryLight!** 🚢✨

*Your contributions help make ferry travel better for everyone.* 