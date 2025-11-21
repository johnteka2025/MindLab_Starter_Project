const http = require("http");
const HOST = "0.0.0.0";           // critical in Docker
const PORT = process.env.PORT || 8085;

const server = http.createServer(async (req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, {"Content-Type": "application/json"});
    res.end(JSON.stringify({ ok: true }));
    return;
  }
  res.writeHead(404, {"Content-Type": "application/json"});
  res.end(JSON.stringify({ error: "not found", path: req.url }));
});

server.listen(PORT, HOST, () => {
  console.log(`API listening on http://${HOST}:${PORT}`);
});
