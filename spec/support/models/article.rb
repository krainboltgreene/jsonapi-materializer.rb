class Article < ActiveRecord::Base
  belongs_to(:account)
  has_many(:comments)
end
