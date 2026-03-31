const http = require("http");

const HOST = "0.0.0.0";
const PORT = process.env.PORT || 8085;

const server = http.createServer((req, res) => {

  if (req.method === "POST" && req.url === "/score") {
    let body = "";

    req.on("data", chunk => {
      body += chunk.toString();
    });

    req.on("end", () => {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({
        ok: true,
        received: body ? JSON.parse(body) : null
      }));
    });

    return;
  }

  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok" }));
    return;
  }

  res.writeHead(404, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ error: "not found", path: req.url }));

});

server.listen(PORT, HOST, () => {
  console.log(`Server running on port ${PORT}`);
});
