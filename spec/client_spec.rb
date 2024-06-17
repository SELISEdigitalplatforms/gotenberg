# frozen_string_literal: true

require "rspec"
require "webmock/rspec"
require "json"
require_relative "../lib/gotenberg/client"

RSpec.describe Gotenberg::Client do
  let(:api_url) { "http://localhost:3000" }
  let(:client) { described_class.new(api_url) }
  let(:html_content) { { index: "<html><body><h1>Hello, world!</h1></body></html>" } }
  let(:asset_paths) { [] }

  describe "#html" do
    context "when the Gotenberg API is up" do
      before do
        stub_request(:get, "#{api_url}/health").to_return(
          body: { status: "up" }.to_json,
          headers: { "Content-Type" => "application/json" },
          status: 200
        )
      end

      it "converts HTML to PDF" do
        stub_request(:post, "#{api_url}/forms/chromium/convert/html")
          .to_return(body: "PDF content", status: 200)

        pdf_content = client.html(html_content, asset_paths)

        expect(pdf_content).to eq("PDF content")
      end
    end

    context "when the Gotenberg API is down" do
      before do
        stub_request(:get, "#{api_url}/health").to_return(
          body: { status: "down" }.to_json,
          headers: { "Content-Type" => "application/json" },
          status: 500
        )
      end

      it "raises a GotenbergDownError" do
        expect { client.html(html_content, asset_paths) }.to raise_error(Gotenberg::GotenbergDownError)
      end
    end
  end

  describe "#up?" do
    context "when the Gotenberg API is up" do
      it "returns true" do
        stub_request(:get, "#{api_url}/health").to_return(
          body: { status: "up" }.to_json,
          headers: { "Content-Type" => "application/json" },
          status: 200
        )

        expect(client.up?).to eq(true)
      end
    end

    context "when the Gotenberg API is down" do
      it "returns false" do
        stub_request(:get, "#{api_url}/health").to_return(
          body: { status: "down" }.to_json,
          headers: { "Content-Type" => "application/json" },
          status: 500
        )

        expect(client.up?).to eq(false)
      end
    end
  end
end
