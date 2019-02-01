import sys
import os


abspath = os.path.dirname(__file__)
print abspath

if len(abspath) > 0:
    sys.path.append(abspath)
    os.chdir(abspath)

import web
import signal
from datetime import datetime

urls = (
    '/hosttrack/', 'index',
    '/hosttrack/ping', 'ping',
    '/', 'index',
    '/ping', 'ping'
)

renderer = web.template.render('templates', globals=globals())

is_running = True


class ServerList:

    def __init__(self):
        self.servers = {}

    def put(self, server_name, args):
        self.servers[server_name] = args

    def get(self):
        keys = sorted(self.keys())
        return [self.servers[k] for k in keys]

    def get(self):
        for k in self.servers:
            self.servers[k]['age'] = datetime.now() - self.servers[k]['ts']
        keys = sorted(self.servers, key=lambda x: self.servers[x]['ts'], reverse=True)
        return [self.servers[k] for k in keys]

servers = ServerList()

class index:
    def GET(self):
        # session.count += 1
        # session.env = {}
        # for (k, v) in web.ctx.env.items():
        #     if type(v) is str:
        #         session.env[k] = v
        return renderer.index(servers.get())

class ping:

    def process(self):

        args = {
            'name': web.input(name='unknown').name,
            'ip': web.input(ip='x.x.x.x').ip,
            'comment': web.input(comment='').comment,
            'ts': datetime.now(),
            'updated': web.input(updated='').updated,
            'public_ip': web.input(public_ip='').public_ip
        }
        print args
        servers.put(args['name'], args)
        return web.ok()

    def GET(self):
        return self.process()
    def POST(self):
        return self.process()


def signal_handler(signum, frame):
    os._exit(signal.SIGTERM)


class IPTracker(web.application):
    def run(self, *middleware):
        func = self.wsgifunc(*middleware)
        return web.httpserver.runsimple(func, ('0.0.0.0', 5555))


if __name__ == '__main__':
    app = IPTracker(urls, globals())
    signal.signal(signal.SIGINT, signal_handler)
    app.run()
else:
    web.config.debug = False
    app = web.application(urls, globals(), autoreload=False)
    application = app.wsgifunc()
