from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class MockHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        
        if self.path == '/api/auth/login':
            self.wfile.write(json.dumps({
                "code": "SUCCESS",
                "data": {"token": "mock-token-123456"}
            }).encode())
        elif self.path == '/api/v2/payments/quick-pay':
            self.wfile.write(json.dumps({
                "code": "SUCCESS",
                "data": {"orderNo": "TEST123", "status": "PAID"}
            }).encode())
    
    def log_message(self, format, *args):
        pass

server = HTTPServer(('localhost', 8888), MockHandler)
print("Mock server running at http://localhost:8080")
server.serve_forever()