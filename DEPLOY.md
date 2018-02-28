
# Deployment Checklist

- Make sure `export RAILS_ENV=production` is in your `.bash_profile` file.
- Make sure `.env` is available with the following key:
  * `SECRET_KEY_BASE`, obtained from `bin/rails secret`
- Run the following commands as needed:
  * `bundle install --path vendor/bundle`
  * `bin/rake assets:precompile`
  * `bin/rake dict:prepare`
  * `bin/rake dict:create`
- Make sure Nginx is running with a proper reverse proxy configuration.
- Make sure Rails and Nginx will be started-up on system boot.

# Nginx Configuration

```
upstream kotobyte {
    server unix:<app-dir>/tmp/sockets/puma.sock fail_timeout=0;
}

server {
    listen 80 deferred;
    server_name localhost kotobyte.com www.kotobyte.com;

    root <app-dir>/public;

    try_files $uri @app;

    location @app {
        proxy_pass http://kotobyte;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
    }
}
```

# Systemd Configuration

```
[Unit]
Description=Kotobyte Application Server
After=network.target

[Service]
Type=simple
User=ang
WorkingDirectory=<app-dir>
ExecStart=<home-dir>/.rbenv/shims/ruby <app-dir>/bin/puma -S <app-dir>/tmp/pids/puma.state -b unix:///home/ang/kotobyte-rails/tmp/sockets/puma.sock
ExecStop=<home-dir>/.rbenv/shims/ruby <app-dir>/bin/pumactl -S <app-dir>/tmp/pids/puma.state stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
```
