class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  uncache_has_many :user, :post

end
