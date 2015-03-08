class Post < ActiveRecord::Base
    has_many :comments
	belongs_to :user

	cache_has_many :comments
	uncache_has_many :user
end
