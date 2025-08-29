# Pakai base image Dart terbaru (versi minimal 3.6.0)
FROM dart:3.6

WORKDIR /app

# Copy pubspec.yaml dan pubspec.lock dulu
COPY pubspec.* /app/

# Install dependencies
RUN dart pub get

# Copy semua file project
COPY . /app/

# Build Flutter web (kalau kamu build Flutter di sini, harus install Flutter SDK)
# Kalau kamu cuma deploy hasil build Flutter web (build/web), ini bisa di-skip

# Jalankan server.js (Node.js)
# Jadi kita perlu Node.js juga, bisa ganti pake image node + dart, tapi lebih gampang pisah deploy server dan web
# Kalau pakai Express server Node.js, sebaiknya deploy web dan server secara terpisah atau pakai build custom

# Contoh start server nodejs:
CMD ["npm", "start"]
