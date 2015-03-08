module HasManyExtension

  extend ActiveSupport::Concern

  # This method generates cache key for the has_many or belongs_to association.
  # If belongs_to_assoc param is provided, it generates for belongs_to association.
  # This method would be called on instances of class that implement has_many.
  # Generated Cache key examples: 
  # 1. "User_<user_id>_has_many_Comment_<foreign_key>"
  # 2. "Post_<post_id>_has_many_Comment_<foreign_key>"
  def get_cache_key col, belongs_to_assoc = nil
    if belongs_to_assoc
      klass_name = col.class.name
      foreign_key = col.class.reflect_on_association(belongs_to_assoc).foreign_key
    else
      klass_name = self.class.reflect_on_association(col).klass.name
      foreign_key = self.class.reflect_on_association(col).foreign_key
    end
    "#{self.class}_#{self.id}_has_many_#{klass_name}_#{foreign_key}"
  end

  # add your static(class) methods here
  module ClassMethods

    # Caches has_many association. The association needs to be declared using `has_many :posts` for using this method.
    # Usage:
    # class User < ActiveRecord::Base
    #   has_many :posts
    #   has_many :comments
    #   cache_has_many :posts, :comments
    # end
    def cache_has_many *collections
      collections.each do |col|
        define_method("cached_#{col}") do
          Rails.cache.fetch(self.get_cache_key(col), expires_in: 1.hour) do
              # `reload` calls the SQL query and gets the association loaded. 
              # Otherwise it would do a lazy load and caching won't really happen 
              self.send(col).reload
          end
        end
      end
    end

    # Hooks callbacks to invalidate the cache whenever an association item is modified/deleted or a new one is created for a record.
    def uncache_has_many *associations
      # Clear cache for a record for which a new association is created.
      before_update do
        associations.each do |assoc|
          obj = self.class.reflect_on_association(assoc).klass.find(self.send("#{self.class.reflect_on_association(assoc).foreign_key}_was"))
          if self.send("#{self.class.reflect_on_association(assoc).foreign_key}_changed?")
            if Rails.cache.exist?(obj.get_cache_key(self, assoc))
              puts "deleting the cache... #{obj.get_cache_key(self, assoc)}"
              Rails.cache.delete(obj.get_cache_key(self, assoc))
            end
          end
      end
      end
      # clear cache for a record whose association is modified.
      after_commit do
        associations.each do |assoc|
          obj = self.send(assoc)
          if Rails.cache.exist?(obj.get_cache_key(self, assoc))
            puts "deleting the cache... #{obj.get_cache_key(self, assoc)} if exists"
            Rails.cache.delete(obj.get_cache_key(self, assoc))
          end
        end
      end
    end

  end

end

# include the extension 
ActiveRecord::Base.send(:include, HasManyExtension)
