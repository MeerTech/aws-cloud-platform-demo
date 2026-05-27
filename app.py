import http.server
import socketserver
import os

PORT = int(os.environ.get("PORT", 8080))

HTML = b"""
<!DOCTYPE html>
<html>
<head><title>AWS Cloud Platform Demo</title></head>
<body style="font-family:Arial;padding:40px;background:#1a1a2e;color:#eee;margin:0">
  <h1 style="color:#4fc3f7">AWS Cloud Platform Demo</h1>
  <p>Production-grade AWS platform</p>
  <ul style="line-height:2">
    <li>Terraform IaC - modular, versioned infrastructure</li>
    <li>ECS Fargate - serverless containers</li>
    <li>Private subnet - no direct internet access</li>
    <li>ECR - private container registry with image scanning</li>
    <li>GitHub Actions - automated CI/CD pipeline</li>
    <li>KMS encrypted S3 - secure object storage</li>
  </ul>
  <p style="color:#888;font-size:12px;margin-top:40px">
    Running on ECS Fargate | us-east-1
  </p>
</body>
</html>
"""

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(HTML)

    def log_message(self, format, *args):
        pass

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving on port {PORT}")
    httpd.serve_forever()
