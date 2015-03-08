# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

10.times do 
  u = User.create(email: Faker::Internet.email)
end

# Too many queries! This needs to be optimized.
50.times do
  p = Post.create(user: User.order("Random()").first, content: Faker::Lorem.sentence(8))
  rand(10).times do
    Comment.create(user: User.order("RANDOM()").first, post: p, content: Faker::Lorem.paragraph(5))
  end
end
