require 'open-uri'

namespace :download do

  desc 'Download all dictionary data'
  task all: [:words_source, :kanji_source, :kanji_strokes]

  desc 'Download words source file'
  task words_source: :environment do

    download_gzip_file(
        from_url: Rails.configuration.app[:words_source_url],
        to_file: Rails.configuration.app[:words_source_file]
    )
  end

  desc 'Download Kanji source file'
  task kanji_source: :environment do
    
    download_gzip_file(
        from_url: Rails.configuration.app[:kanji_source_url],
        to_file: Rails.configuration.app[:kanji_source_file]
    )
  end

  desc 'Download Kanji strokes file'
  task kanji_strokes: :environment do

    download_gzip_file(
        from_url: Rails.configuration.app[:kanji_strokes_url],
        to_file: Rails.configuration.app[:kanji_strokes_file]
    )
  end

  private

    def download_gzip_file(from_url:, to_file:)
      puts "Downloading '#{from_url}' to '#{to_file}'"

      open(from_url) do |remote_file|
        open(to_file, 'w') do |local_file|

          local_file.write(Zlib::GzipReader.new(remote_file).read)
        end
      end
    end
end
