class AccountMaterializer
  include(JSONAPI::Materializer::Resource)

  type(:people)

  has_many(:comments, :class_name => "CommentMaterializer")
  has_many(:articles, :class_name => "ArticleMaterializer")

  has(:name)
end
