require("spec_helper")

RSpec.describe(JSONAPI::Materializer::VERSION) do
  it("should be a string") do
    expect(JSONAPI::Materializer::VERSION).to(be_kind_of(String))
  end
end
