class ArticleMaterializer
  include(JSONAPI::Materializer::Resource)

  type(:articles)

  has_one(:author, :from => :account, :class_name => "AccountMaterializer")
  has_many(:comments, :class_name => "CommentMaterializer")

  has(:title, :selectable => true)
end
