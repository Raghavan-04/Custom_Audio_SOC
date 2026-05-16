#!/usr/bin/env python3
"""
Audio SoC Interactive Simulator - Local Web Server
Hosts the simulator on http://localhost:8000
"""

import http.server
import socketserver
import os
import webbrowser
from urllib.parse import urlparse
import sys

PORT = 8000
HOST = 'localhost'

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Custom HTTP request handler with proper MIME types"""
    
    def end_headers(self):
        """Add headers to prevent caching during development"""
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()
    
    def do_GET(self):
        """Handle GET requests"""
        # Default to index.html if root is requested
        if self.path == '/' or self.path == '':
            self.path = '/index.html'
        
        return super().do_GET()
    
    def guess_type(self, path):
        """Guess MIME type for files"""
        mimetype = super().guess_type(path)
        if path.endswith('.js'):
            return 'application/javascript'
        if path.endswith('.css'):
            return 'text/css'
        if path.endswith('.json'):
            return 'application/json'
        return mimetype

def run_server():
    """Start the web server"""
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    handler = MyHTTPRequestHandler
    
    try:
        with socketserver.TCPServer(("", PORT), handler) as httpd:
            url = f"http://{HOST}:{PORT}"
            
            print("=" * 60)
            print("Audio SoC Interactive Simulator")
            print("=" * 60)
            print(f"\n✓ Server running at: {url}\n")
            print("Press Ctrl+C to stop the server\n")
            print("Serving files from:", os.getcwd())
            print("=" * 60)
            
            # Try to open browser automatically
            try:
                webbrowser.open(url)
                print(f"\n✓ Opening {url} in your default browser...\n")
            except Exception as e:
                print(f"\nℹ Could not open browser automatically")
                print(f"ℹ Please visit: {url}\n")
            
            httpd.serve_forever()
            
    except KeyboardInterrupt:
        print("\n\n✓ Server stopped.")
        sys.exit(0)
    except OSError as e:
        print(f"\n✗ Error: {e}")
        print(f"✗ Port {PORT} might already be in use.")
        print(f"\nTrying port {PORT + 1}...")
        PORT = PORT + 1
        run_server()

if __name__ == '__main__':
    run_server()