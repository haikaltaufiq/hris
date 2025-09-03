# Stage 1: build Flutter Web
FROM ghcr.io/cirruslabs/flutter:latest AS builder

WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release

# Stage 2: serve dengan Node.js
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install --production

COPY --from=builder /app/build/web ./build/web
COPY server.js .

EXPOSE 3000
CMD ["npm", "start"]
