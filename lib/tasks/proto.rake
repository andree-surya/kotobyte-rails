
namespace :proto do

  desc 'Create models from Protobuf configuration file'
  task create: :environment do

    `protoc models.proto --proto_path=config --ruby_out=lib`
  end
end