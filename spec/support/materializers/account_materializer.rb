class AccountMaterializer
  include(JSONAPI::Materializer::Resource)

  type(:people)

  has_many(:comments, :class_name => "CommentMaterializer")
  has_many(:articles, :class_name => "ArticleMaterializer")

  has(:name, :visible => :readable_attribute?)

  context.validates_presence_of(:policy)

  private def readable_attribute?(attribute)
     context.policy.read_attribute?(attribute.from)
  end
end
