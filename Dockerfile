# Base image Node.js
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package.json dan package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy semua file project (termasuk server.js, build/web, dll)
COPY . .

# Expose port
EXPOSE 3000

# Start server
CMD ["npm", "start"]
