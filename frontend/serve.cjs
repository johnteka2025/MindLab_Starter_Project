const http = require("http")
const fs = require("fs")
const path = require("path")

const root = __dirname

function getContentType(file) {
  if (file.endsWith(".js")) return "application/javascript"
  if (file.endsWith(".html")) return "text/html"
  if (file.endsWith(".css")) return "text/css"
  return "text/plain"
}

http.createServer((req, res) => {
  let filePath = path.join(root, req.url === "/" ? "index.html" : req.url)

  if (!fs.existsSync(filePath)) {
    res.writeHead(404)
    return res.end("Not found")
  }

  const data = fs.readFileSync(filePath)
  res.writeHead(200, { "Content-Type": getContentType(filePath) })
  res.end(data)
}).listen(8090, () => {
  console.log("Frontend running at http://localhost:8090")
})
