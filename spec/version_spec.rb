# frozen_string_literal: true

RSpec.describe Gotenberg do
  it "has a version number" do
    expect(Gotenberg::VERSION).not_to be nil
  end

  it "matches the version pattern x.y.z" do
    expect(Gotenberg::VERSION).to match(/^\d+\.\d+\.\d+$/)
  end
end
