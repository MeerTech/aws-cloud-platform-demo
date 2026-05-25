#!/bin/bash
# Update system
dnf update -y || true

# Ensure SSM agent is running
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent || true

# Install CloudWatch agent
dnf install -y amazon-cloudwatch-agent || true

# Create Python web app
python3 -c "
import http.server
import socketserver

html = b'''<html><body style=\"font-family:Arial;padding:40px;background:#1a1a2e;color:#eee\">
<h1>AWS Cloud Platform Demo</h1>
<p>Production-grade AWS: Terraform IaC, Private Subnet, SSM Access, CloudWatch</p>
</body></html>'''

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(html)
    def log_message(self, format, *args):
        pass

with socketserver.TCPServer(('', 8080), Handler) as httpd:
    httpd.serve_forever()
" &

echo "Bootstrap complete $(date)" > /var/log/user-data.log
