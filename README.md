# SmartPreloader

Smart preloader allows to:
- Preload polymorphic associations
- Filter records for preloading
- Preload composite key associations

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'smart_preloader'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install smart_preloader

## Usage

### Preload polymorphic associations
```ruby
class Comment < ApplicationRecord
  belongs_to :owner, polymorphic: true # User or Post
end
```

To preload use the same syntax as for Rails eager load with one extra layer for polymorphic association
Use class constants to specify corresponding preloads
```ruby
comments = Comment.all
ActiveRecord::SmartPreloader.(comments, owner: [
  User => :account,
  Post => :votes
])
```
Class name in preload tree considered as a filter for a records

### Filter records for preloading
It allows filter records at ruby level for further preloading
```ruby
comments = Comment.all
ActiveRecord::SmartPreloader.(comments, ->(comment) { comment.rated? } => :author)
```
The code filters `rated?` comments and preloads `Comment#author` association 

### Preload composite key associations
Models could be referenced not by single id but by composite/multi key, like [:category_id, :author_id]

```ruby
class AuthorRating < ApplicationRecord
  belongs_to :author
  belongs_to :category
end
class Post < ApplicationRecord
  belongs_to :category
  belongs_to :author
  has_one :author_rating,
          ->(post) { where(category_id: post.category_id) },
          class_name: 'AuthorRating', foreign_key: :author_id, primary_key: :author_id
end
```

To preload post's author rating in the category:
```ruby
ActiveRecord::SmartPreloader.(posts, ActiveRecord::CompositeKey.new(:author_rating, [:author_id, :category_id]))
```

and it could be put in tree as usual:
```ruby
ActiveRecord::SmartPreloader.(comments, post: [
  ActiveRecord::CompositeKey.new(:author_rating, [:author_id, :category_id]) => :voters
])
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/2rba/smart_preloader.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
