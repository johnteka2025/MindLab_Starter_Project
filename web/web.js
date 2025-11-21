import express from "express";
const app = express();
const PORT = process.env.WEB_PORT || 5177;
const API_BASE = process.env.VITE_API_BASE || "http://localhost:8085";
app.get("/", (_req,res)=> res.send(`
  <html><body style="font-family:sans-serif">
    <h1>MindLab Web</h1>
    <p>API: ${API_BASE}</p>
    <script>
      fetch("${API_BASE}/api/health").then(r=>r.json()).then(x=>{
        document.body.insertAdjacentHTML("beforeend", "<pre>health: "+JSON.stringify(x)+"</pre>")
      }).catch(err=>{
        document.body.insertAdjacentHTML("beforeend", "<pre style='color:red'>"+err+"</pre>")
      })
    </script>
  </body></html>
`));
app.listen(PORT, ()=> console.log("Web listening on", PORT));
