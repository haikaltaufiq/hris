const express = require('express');
const path = require('path');
const app = express();

// Serve file statis dari folder build/web
app.use(express.static(path.join(__dirname, 'build/web')));

// Semua request lain arahkan ke index.html (buat support routing di Flutter Web)
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/web/index.html'));
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
