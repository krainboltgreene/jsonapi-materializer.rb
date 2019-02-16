require("spec_helper")

RSpec.describe(JSONAPI::Materializer::Resource) do
  let(:resource) {ArticleMaterializer.new(:object => Article.find(1))}

  before do
    Account.create!(:id => 9, :name => "Dan Gebhardt", :twitter => "dgeb")
    Account.create!(:id => 2, :name => "DHH", :twitter => "DHH")
    Article.create!(:id => 1, :title => "JSON API paints my bikeshed!", :account => Account.find(9))
    Comment.create!(:id => 5, :body => "First!", :article => Article.find(1), :account => Account.find(2))
    Comment.create!(:id => 12, :body => "I like XML better", :article => Article.find(1), :account => Account.find(9))
  end

  describe("#to_json") do
    subject {resource.as_json.deep_stringify_keys}

    it("returns a JSON:API standards compliant payload") do
      expect(subject).to(
        eq(
          "links" => {
            "self" => "http://example.com/articles/1"
          },
          "data" => {
            "id" => "1",
            "type" => "articles",
            "attributes" => {
              "title" => "JSON API paints my bikeshed!"
            },
            "relationships" => {
              "author" => {
                "data" => {
                  "id" => "9",
                  "type" => "people"
                },
                "links" => {
                  "self" => "http://example.com/articles/1/relationships/author",
                  "related" => "http://example.com/articles/1/author"
                }
              },
              "comments" => {
                "data" => [
                  {
                    "id" => "5",
                    "type" => "comments"
                  },
                  {
                    "id" => "12",
                    "type" => "comments"
                  }
                ],
                "links" => {
                  "self" => "http://example.com/articles/1/relationships/comments",
                  "related" => "http://example.com/articles/1/comments"
                }
              }
            },
            "links" => {
                "self" => "http://example.com/articles/1"
            }
          }
        )
      )
    end
  end
end
