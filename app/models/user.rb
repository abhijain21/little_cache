class User < ActiveRecord::Base

  has_many :posts
  has_many :comments

  cache_has_many :posts, :comments

end
