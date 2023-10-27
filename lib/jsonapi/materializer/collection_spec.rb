# frozen_string_literal: true

require("spec_helper")

PaginationAdapter = Struct.new(:in, :page, :pages, :prev, :next)

RSpec.describe(JSONAPI::Materializer::Collection) do
  let(:described_class) { ArticleMaterializer::Collection }
  let(:collection) do
    described_class.new(
      object:,
      includes: [["comments"], ["author"]],
      pagination:
    )
  end
  let(:pagination) do
    PaginationAdapter.new(
      10, # items in page
      9, # current page
      10, # total pages
      100, # previous page
      80 # next page
    )
  end

  describe("#as_json") do
    subject { collection.as_json.deep_stringify_keys }

    before do
      Account.create!(id: 9, name: "Dan Gebhardt", twitter: "dgeb")
      Account.create!(id: 2, name: "DHH", twitter: "DHH")
      Article.create!(id: 1, title: "JSON API paints my bikeshed!", account: Account.find(9))
      Article.create!(id: 2, title: "Rails is Omakase", account: Account.find(9))
      Article.create!(id: 3, title: "What is JSON:API?", account: Account.find(9))
      Comment.create!(id: 5, body: "First!", article: Article.find(1), account: Account.find(2))
      Comment.create!(id: 12, body: "I like XML better", article: Article.find(1), account: Account.find(9))
    end

    context("when the list has items") do
      let(:object) { Kaminari.paginate_array(Article.all).page(1).per(1) }

      it("has a data key at root with the resources") do
        expect(subject.fetch("data")).to(eq([{
                                              "id" => "1",
                                              "type" => "articles",
                                              "attributes" => {
                                                "title" => "JSON API paints my bikeshed!"
                                              },
                                              "relationships" => {
                                                "author" => {
                                                  "data" => { "id" => "9", "type" => "people" },
                                                  "links" => {
                                                    "self" => "http://example.com/articles/1/relationships/author",
                                                    "related" => "http://example.com/articles/1/author"
                                                  }
                                                },
                                                "comments" => {
                                                  "data" => [
                                                    { "id" => "5", "type" => "comments" },
                                                    { "id" => "12", "type" => "comments" }
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
                                            }]))
      end

      context("when on the first page") do
        let(:pagination) do
          PaginationAdapter.new(
            10, # items in page
            1, # current page
            10, # total pages
            nil, # previous page
            2 # next page
          )
        end

        it("has a links key at root with pagination") do
          expect(subject.fetch("links")).to(eq(
                                              "last" => "http://example.com/articles?page[offset]=10&page[limit]=10",
                                              "next" => "http://example.com/articles?page[offset]=2&page[limit]=10",
                                              "self" => "http://example.com/articles?page[offset]=1&page[limit]=10"
                                            ))
        end
      end

      context("when on the last page") do
        let(:pagination) do
          PaginationAdapter.new(
            10, # items in page
            10, # current page
            10, # total pages
            9, # previous page
            nil # next page
          )
        end

        it("has a links key at root with pagination") do
          expect(subject.fetch("links")).to(eq(
                                              "first" => "http://example.com/articles?page[offset]=1&page[limit]=10",
                                              "prev" => "http://example.com/articles?page[offset]=9&page[limit]=10",
                                              "self" => "http://example.com/articles?page[offset]=10&page[limit]=10"
                                            ))
        end
      end

      context("when on the middle page") do
        let(:pagination) do
          PaginationAdapter.new(
            10, # items in page
            5, # current page
            10, # total pages
            4, # previous page
            6 # next page
          )
        end

        it("has a links key at root with pagination") do
          expect(subject.fetch("links")).to(eq(
                                              "first" => "http://example.com/articles?page[offset]=1&page[limit]=10",
                                              "last" => "http://example.com/articles?page[offset]=10&page[limit]=10",
                                              "next" => "http://example.com/articles?page[offset]=6&page[limit]=10",
                                              "prev" => "http://example.com/articles?page[offset]=4&page[limit]=10",
                                              "self" => "http://example.com/articles?page[offset]=5&page[limit]=10"
                                            ))
        end
      end

      context("when on the only page") do
        let(:pagination) do
          PaginationAdapter.new(
            10, # items in page
            1, # current page
            1, # total pages
            nil, # previous page
            nil # next page
          )
        end

        it("has a links key at root with pagination") do
          expect(subject.fetch("links")).to(eq(
                                              "self" => "http://example.com/articles?page[offset]=1&page[limit]=10"
                                            ))
        end
      end

      it("has a included key at root with included models") do
        expect(subject.fetch("included")).to(include(
                                               {
                                                 "id" => "5",
                                                 "type" => "comments",
                                                 "attributes" => { "body" => "First!" },
                                                 "relationships" => {
                                                   "author" => { "data" => { "id" => "2", "type" => "people" }, "links" => { "self" => "http://example.com/comments/5/relationships/author", "related" => "http://example.com/comments/5/author" } },
                                                   "article" => { "data" => { "id" => "1", "type" => "articles" }, "links" => { "self" => "http://example.com/comments/5/relationships/article", "related" => "http://example.com/comments/5/article" } }
                                                 },
                                                 "links" => { "self" => "http://example.com/comments/5" }
                                               },
                                               {
                                                 "id" => "12",
                                                 "type" => "comments",
                                                 "attributes" => { "body" => "I like XML better" },
                                                 "relationships" => {
                                                   "author" => { "data" => { "id" => "9", "type" => "people" }, "links" => { "self" => "http://example.com/comments/12/relationships/author", "related" => "http://example.com/comments/12/author" } },
                                                   "article" => { "data" => { "id" => "1", "type" => "articles" }, "links" => { "self" => "http://example.com/comments/12/relationships/article", "related" => "http://example.com/comments/12/article" } }
                                                 },
                                                 "links" => { "self" => "http://example.com/comments/12" }
                                               },
                                               {
                                                 "id" => "9",
                                                 "type" => "people",
                                                 "attributes" => { "name" => "Dan Gebhardt" },
                                                 "relationships" => {
                                                   "comments" => { "data" => [{ "id" => "12", "type" => "comments" }], "links" => { "self" => "http://example.com/people/9/relationships/comments", "related" => "http://example.com/people/9/comments" } },
                                                   "articles" => {
                                                     "data" => [{ "id" => "1", "type" => "articles" }, { "id" => "2", "type" => "articles" }, { "id" => "3", "type" => "articles" }],
                                                     "links" => { "self" => "http://example.com/people/9/relationships/articles", "related" => "http://example.com/people/9/articles" }
                                                   }
                                                 },
                                                 "links" => { "self" => "http://example.com/people/9" }
                                               }
                                             ))
      end
    end
  end
end
