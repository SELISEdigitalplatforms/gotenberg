# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "mime/types"
require "net/http/post/multipart"
require "tempfile"
require "securerandom"
require "fileutils"

module Gotenberg
  class IndexFileMissing < StandardError; end

  # Client class for interacting with the Gotenberg API
  class Client
    # Initialize a new Client
    #
    # @param api_url [String] The base URL of the Gotenberg API
    def initialize(api_url)
      @api_url = api_url
    end

    # Convert HTML files to PDF and write it to the output file
    #
    # @param htmls [Hash{Symbol => String}] A hash with the file name as the key and the HTML content as the value
    # @param asset_paths [Array<String>] Optional args, paths to the asset files (like CSS, images) required by the HTML files # rubocop:disable Layout/LineLength
    # @param properties [Hash] Additional properties for PDF conversion
    # @option properties [Float] :paperWidth The width of the paper
    # @option properties [Float] :paperHeight The height of the paper
    # @option properties [Float] :marginTop The top margin
    # @option properties [Float] :marginBottom The bottom margin
    # @option properties [Float] :marginLeft The left margin
    # @option properties [Float] :marginRight The right margin
    # @option properties [Boolean] :preferCssPageSize Whether to prefer CSS page size
    # @option properties [Boolean] :printBackground Whether to print the background
    # @option properties [Boolean] :omitBackground Whether to omit the background
    # @option properties [Boolean] :landscape Whether to use landscape orientation
    # @option properties [Float] :scale The scale of the PDF
    # @option properties [String] :nativePageRanges The page ranges to include
    # @return [String] The resulting PDF content
    # @raise [GotenbergDownError] if the Gotenberg API is down
    #
    # Example:
    #   htmls = { index: "<h1>Html</h1>", header: "<h1>Header</h1>", footer: "<h1>Footer</h1>" }
    #   asset_paths = ["path/to/style.css", "path/to/image.png"]
    #   properties = { paperWidth: 8.27, paperHeight: 11.7, marginTop: 1, marginBottom: 1 }
    #   client = Gotenberg::Client.new("http://localhost:3000")
    #   pdf_content = client.html(htmls, asset_paths, properties)
    #
    # Credit: https://github.com/jbd0101/ruby-gotenberg-client/blob/master/lib/gotenberg.rb
    def html(htmls, asset_paths = [], properties = {}) # rubocop:disable Metrics/CyclomaticComplexity
      raise GotenbergDownError unless up?

      raise IndexFileMissing unless (htmls.keys & ["index", :index]).any?

      dir_name = SecureRandom.uuid
      dir_path = File.join(Dir.tmpdir, dir_name)
      FileUtils.mkdir_p(dir_path)

      htmls.each do |key, value|
        File.write(File.join(dir_path, "#{key}.html"), value)
      end

      uri = URI("#{@api_url}/forms/chromium/convert/html")

      # Gotenberg requires all files to be in the same directory
      asset_paths.each do |path|
        FileUtils.cp(path, dir_path)
        next unless path.split(".").last == "css"

        # This preprocessing is necessary for the gotenberg
        raw_css = File.read(path)
        preprocessed = raw_css.gsub("url(/assets/", "url(").gsub("url(/", "url(")
        File.write(path, preprocessed)
      end

      # Rejecting .. and .
      entries = Dir.entries(dir_path).reject { |f| f.start_with?(".") }

      payload = entries.each_with_object({}).with_index do |(entry, obj), index|
        entry_abs_path = File.join(dir_path, entry)
        mime_type = MIME::Types.type_for(entry_abs_path).first.content_type
        obj["files[#{index}]"] = UploadIO.new(entry_abs_path, mime_type)
      end

      response = multipart_post(uri, payload.merge(properties))
      response.body.dup.force_encoding("utf-8")
    ensure
      FileUtils.rm_rf(dir_path) if dir_path
    end

    # Check if the Gotenberg API is up and healthy
    #
    # @return [Boolean] true if the API is up, false otherwise
    def up?
      uri = URI("#{@api_url}/health")
      request = Net::HTTP::Get.new(uri)
      request.basic_auth(
        ENV.fetch("GOTENBERG_API_BASIC_AUTH_USERNAME", nil),
        ENV.fetch("GOTENBERG_API_BASIC_AUTH_PASSWORD", nil)
      )

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      response = http.request(request)

      response.is_a?(Net::HTTPSuccess) && JSON.parse(response.body)["status"] == "up"
    rescue StandardError
      false
    end

    private

    def multipart_post(uri, payload)
      request = Net::HTTP::Post::Multipart.new(uri.path, payload)
      request.basic_auth(
        ENV.fetch("GOTENBERG_API_BASIC_AUTH_USERNAME", nil),
        ENV.fetch("GOTENBERG_API_BASIC_AUTH_PASSWORD", nil)
      )

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.request(request)
    end
  end

  # Custom error class for Gotenberg API downtime
  class GotenbergDownError < StandardError; end
end
