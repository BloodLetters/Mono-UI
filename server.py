import http.server
import socketserver
import os
import re

PORT = 6767
DIRECTORY = os.path.dirname(os.path.abspath(__file__))

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/mono-ui.luau':
            # Serve the bundled library file
            file_path = os.path.join(DIRECTORY, 'dist', 'mono-ui.luau')
            if os.path.exists(file_path):
                self.send_response(200)
                self.send_header('Content-type', 'text/plain; charset=utf-8')
                self.send_header('Access-Control-Allow-Origin', '*')  # Enable CORS for Roblox executor HttpGet
                self.end_headers()
                with open(file_path, 'rb') as f:
                    self.wfile.write(f.read())
            else:
                self.send_error(404, 'File Not Found: dist/mono-ui.luau')
        elif self.path == '/sniper-arena':
            # Serve the Sniper Arena script
            sniper_path = os.path.join(DIRECTORY, 'Sniper-arena.lua')
            if os.path.exists(sniper_path):
                self.send_response(200)
                self.send_header('Content-type', 'text/plain; charset=utf-8')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                with open(sniper_path, 'rb') as f:
                    self.wfile.write(f.read())
            else:
                self.send_error(404, 'File Not Found: Sniper-arena.lua')
        elif self.path == '/demo':
            # Serve the demo script (modifying local require to fetch from this local server)
            example_path = os.path.join(DIRECTORY, 'example.lua')
            if os.path.exists(example_path):
                with open(example_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Replace: local MonoUI = require("./init") or similar
                pattern = r'local\s+MonoUI\s+=\s+require\(["\']\./init["\']\)'
                replacement = 'local MonoUI = loadstring(game:HttpGet("http://localhost:6767/mono-ui.luau"))()'
                modified_content = re.sub(pattern, replacement, content)
                
                self.send_response(200)
                self.send_header('Content-type', 'text/plain; charset=utf-8')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(modified_content.encode('utf-8'))
            else:
                self.send_error(404, 'File Not Found: src/example.lua')
        else:
            # Fallback to standard directory server
            super().do_GET()

if __name__ == '__main__':
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), MyHandler) as httpd:
        print(f"[SERVER] Local test server running on port {PORT}")
        print(f"[INFO] Load library raw script: loadstring(game:HttpGet(\"http://localhost:6767/mono-ui.luau\"))()")
        print(f"[INFO] Run full demo script:    loadstring(game:HttpGet(\"http://localhost:6767/demo\"))()")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n[SERVER] Stopping server...")
