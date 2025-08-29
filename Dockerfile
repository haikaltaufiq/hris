# Stage 1: Build Flutter Web
FROM cirrusci/flutter:stable AS build

WORKDIR /app

COPY pubspec.* /app/
RUN flutter pub get

COPY . /app/

RUN flutter build web --release

# Stage 2: Serve dengan Node.js
FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY --from=build /app/build/web ./build/web
COPY server.js ./

CMD ["npm", "start"]
