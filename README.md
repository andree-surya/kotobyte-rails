# Kotobyte

Kotobyte is a Japanese learner's dictionary webapp built Ruby on Rails and JavaScript.

## Development Setup

### Starting the app

```
// Install dependencies
$ bundle install

// Create dictionary file
$ bin/rake dict:create

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