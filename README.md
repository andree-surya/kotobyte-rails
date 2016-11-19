# Deployment Checklist

- Make sure `export RAILS_ENV=production` is in your `.bashrc` file.
- Make sure `.env` is available with `SECRET_KEY_BASE` configured.
- Make sure ElasticSearch is running with Kuromoji plugin installed.
- Run `bin/rake assets:precompile` as needed.
- Run `bin/rake db:migrate` as needed
- Run `bin/rake download:all && bin/rake index:all` as needed.
- Make sure Nginx is running with a proper reverse proxy configuration.

