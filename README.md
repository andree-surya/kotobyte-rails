# Kotobyte

![Test -> Deployment](https://github.com/andree-surya/kotobyte-rails/actions/workflows/test-deploy.yml/badge.svg)

[Kotobyte](https://kotobyte.et.r.appspot.com) is a Japanese learner's dictionary web application.

## Development Setup

### Starting the app

```
// Install dependencies
$ bundle install

// Precompile assets file
$ bin/rake assets:precompile

// Start server
$ bin/rails server
```

### Maintenance

```
// Download and update dictionary source data
$ bin/rake dict:download
$ bin/rake dict:create

// Recreate Protobuf models
$ bin/rake proto:create
```