# Kotobyte

This is the Ruby on Rails source code for 
[Kotobyte](http://kotobyte.com), a Japanese learner's dictionary.

# Deployment Checklist

- Make sure ElasticSearch is running with Kuromoji plugin installed.
- Make sure `export RAILS_ENV=production` is in your `.bashrc` file.
- Make sure `.env` is available with the following keys:
  * `SECRET_KEY_BASE`, obtained from `bin/rails secret`
  * `GOOGLE_CLIENT_SECRET` obtained from Google API console.
- Run the following commands as needed:
  * `bundle install --path vendor/bundle`
  * `bin/rake assets:precompile`
  * `bin/rake db:migrate`
  * `bin/rake download:all && bin/rake index:all`
- Make sure Nginx is running with a proper reverse proxy configuration.

