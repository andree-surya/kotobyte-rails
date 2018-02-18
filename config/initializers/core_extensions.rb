
# Load all core extensions in `lib/core_ext` directory.
Dir[File.join(Rails.root, 'lib', 'core_ext', '*.rb')].each { |l| require l }