const express = require("express");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;

// serve static files dari folder Flutter build
app.use(express.static(path.join(__dirname, "build", "web")));

// fallback ke index.html biar SPA jalan (routing di Flutter Web tetap aman)
app.get("*", (req, res) => {
  res.sendFile(path.join(__dirname, "build", "web", "index.html"));
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
