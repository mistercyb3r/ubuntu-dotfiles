import http from "node:http";

const port = Number(process.env.PORT || 5173);

const server = http.createServer((req, res) => {
  res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
  res.end("<!doctype html><html><body><h1>PROJECT_NAME</h1></body></html>");
});

server.listen(port, "127.0.0.1", () => {
  console.log(`http://127.0.0.1:${port}`);
});
