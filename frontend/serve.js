const http = require("http")
const fs = require("fs")
const path = require("path")

const root = path.join(__dirname)

http.createServer((req, res) => {
  let filePath = path.join(root, req.url === "/" ? "index.html" : req.url)

  if (!fs.existsSync(filePath)) {
    res.writeHead(404)
    return res.end("Not found")
  }

  const data = fs.readFileSync(filePath)
  res.writeHead(200)
  res.end(data)
}).listen(8090, () => {
  console.log("Frontend running at http://localhost:8090")
})
