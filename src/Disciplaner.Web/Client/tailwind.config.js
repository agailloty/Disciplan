const path = require("path");

module.exports = {
  content: [
    path.resolve(__dirname, "./Pages/**/*.razor"),
    path.resolve(__dirname, "./Components/**/*.razor"),
    path.resolve(__dirname, "./Layout/**/*.razor"),
    path.resolve(__dirname, "./Auth/**/*.razor"),
    path.resolve(__dirname, "./wwwroot/index.html"),
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: [
          "-apple-system",
          "BlinkMacSystemFont",
          "Segoe UI",
          "Helvetica",
          "Arial",
          "sans-serif"
        ]
      }
    }
  },
  plugins: [],
}