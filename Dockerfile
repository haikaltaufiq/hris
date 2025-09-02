# Stage 1: build Flutter Web
FROM cirrusci/flutter:3.13.9 AS builder

WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release

# Stage 2: serve dengan Node
FROM node:18-alpine

WORKDIR /app

# Copy package.json & install dependency
COPY package*.json ./
RUN npm install --production

# Copy hasil build Flutter Web dari stage builder
COPY --from=builder /app/build/web ./build/web

# Copy server.js
COPY server.js .

EXPOSE 3000
CMD ["npm", "start"]
