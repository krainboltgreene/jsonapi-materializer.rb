# frozen_string_literal: true

class CommentMaterializer
  include(JSONAPI::Materializer::Resource)

  type(:comments)

  has_one(:author, from: :account, class_name: "AccountMaterializer")
  has_one(:article, class_name: "ArticleMaterializer")

  has(:body)
end
