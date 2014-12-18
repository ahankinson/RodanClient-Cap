from BaseHTTPServer import HTTPServer
from SimpleHTTPServer import SimpleHTTPRequestHandler
from SocketServer import ThreadingMixIn


class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """ This class allows to handle requests in separated threads.
        No further content needed, don't touch this. """
    pass

if __name__ == '__main__':
    server = ThreadedHTTPServer(('localhost', 8000), SimpleHTTPRequestHandler)
    print 'Starting server on port 8000...'
    server.serve_forever()
