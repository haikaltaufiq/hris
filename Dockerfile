# Stage 1: Pakai image Node.js resmi
FROM node:18-alpine

WORKDIR /app

# Copy package.json dan package-lock.json lalu install dependencies
COPY package*.json ./
RUN npm install

# Copy server.js dan build web folder
COPY server.js ./
COPY build/web ./build/web

# Expose port
EXPOSE 3000

# Jalankan server
CMD ["npm", "start"]
