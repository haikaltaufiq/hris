console.log('ENV VARIABLES:', process.env);

const express = require('express');
const path = require('path');
const app = express();

// Set proper headers untuk Flutter web
app.use((req, res, next) => {
  res.header('Cross-Origin-Embedder-Policy', 'credentialless');
  res.header('Cross-Origin-Opener-Policy', 'same-origin');
  next();
});

// Serve static files dengan proper MIME types
app.use(express.static(path.join(__dirname, 'build/web'), {
  setHeaders: (res, path) => {
    if (path.endsWith('.js')) {
      res.setHeader('Content-Type', 'application/javascript');
    }
    if (path.endsWith('.wasm')) {
      res.setHeader('Content-Type', 'application/wasm');
    }
  }
}));

// Catch all untuk Flutter SPA
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/web/index.html'));
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Static files served from: ${path.join(__dirname, 'build/web')}`);
});