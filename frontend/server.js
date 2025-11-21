const http = require("http");
const fs = require("fs");
const path = require("path");
const PORT = 5177;
const html = fs.readFileSync(path.join(__dirname, "index.html"));
http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type":"text/html; charset=utf-8" });
  res.end(html);
}).listen(PORT, "127.0.0.1", () => {
  console.log("frontend listening on", PORT);
});
