# Kotobyte

This is the Ruby on Rails source code for 
[Kotobyte](http://kotobyte.com), a Japanese learner's dictionary.

## Deployment Checklist

- Make sure `export RAILS_ENV=production` is in your `.bash_profile` file.
- Make sure `.env` is available with the following key:
  * `SECRET_KEY_BASE`, obtained from `bin/rails secret`
- Run the following commands as needed:
  * `bundle install --path vendor/bundle`
  * `bin/rake assets:precompile`
  * `bin/rake dict:prepare`
  * `bin/rake dict:create`
- Make sure Nginx is running with a proper reverse proxy configuration.

