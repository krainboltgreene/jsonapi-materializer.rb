# jsonapi-materializer

  - [![Build](http://img.shields.io/travis-ci/krainboltgreene/jsonapi-materializer.rb.svg?style=flat-square)](https://travis-ci.org/krainboltgreene/jsonapi-materializer.rb)
  - [![Downloads](http://img.shields.io/gem/dtv/jsonapi-materializer.svg?style=flat-square)](https://rubygems.org/gems/jsonapi-materializer)
  - [![Version](http://img.shields.io/gem/v/jsonapi-materializer.svg?style=flat-square)](https://rubygems.org/gems/jsonapi-materializer)

jsonapi-materializer is a way to turn data objects (for example, active record models) into json:api specification responses. Largely the class doesn't care what it's given, as long as it responds to certain properties.


## Using

To start, lets say we have a simple rails application setup, with the model first:

``` ruby
class Account < ApplicationRecord
  has_many(:articles)
  has_many(:comments)

  def self.setup!
    ActiveRecord::Migration.create_table(:accounts, :force => true) do |table|
      table.text(:name, :null => false)
      table.text(:twitter, :null => false)
      table.timestamps(:null => false)
    end
  end
end
```

And a controller:

``` ruby
class AccountsController < ApplicationController
  def index
    render(
      :json => AccountMaterializer::Collection.new(:object => object)
    )
  end

  def show
    render(
      :json => AccountMaterializer::Resource.new(:object => object)
    )
  end
end
```

Finally, lets setup `JSONAPI::Materializer`:

``` ruby
JSONAPI::Materializer.configuration do |let|
  let.default_origin = "http://localhost:3001"
end
```

Now you need to define a materializer, which is a class that determines how and what to return as a json:api payload:

``` ruby
class AccountMaterializer
  include(JSONAPI::Materializer::Resource)

  type(:accounts)

  has_many(:reviews, :class_name => "ReviewMaterializer")

  has(:name)
end
```

That's it! Your endpoint should correctly return:

``` json
{
  "links": {
    "self": "http://localhost:3001/accounts/cf305673-ce1f-4605-8aa4-cba33a6a5a17"
  },
  "data": {
    "id": "cf305673-ce1f-4605-8aa4-cba33a6a5a17",
    "type": "accounts",
    "attributes": {
      "name": "Sally Stuthers"
    },
    "relationships": {
      "reviews": {
        "data": [
          {
            "id": "91a8ca48-df58-423c-bf36-344cd07e1a51",
            "type": "reviews"
          }
        ],
        "links": {
          "self": "http://localhost:3001/accounts/cf305673-ce1f-4605-8aa4-cba33a6a5a17/relationships/reviews",
          "related": "http://localhost:3001/accounts/cf305673-ce1f-4605-8aa4-cba33a6a5a17/reviews"
        }
      }
    },
    "links": {
      "self": "http://localhost:3001/accounts/cf305673-ce1f-4605-8aa4-cba33a6a5a17"
    }
  }
}
```

You're going to want to handle both sparse fieldset and includes, but materializer doesn't do any of that work for you:

``` ruby
class AccountsController < ApplicationController
  def index
    render(
      :json => AccountMaterializer::Collection.new(
        :object => object,
        :selects => {"accounts" => ["name"]},
        :includes => [["reviews"]]
      )
    )
  end
end
```

We suggest [jsonapi-realizer](https://github.com/krainboltgreene/jsonapi-realizer.rb) to handle this for you.


### rails

There is *nothing* specific about rails for this library, it can be used in any framework. You just need:

  0. A place to turn models into json (rails controller)
  0. A place to store the configuration at boot (rails initializers)


### policy (aka pundit)

If you're using some sort of policy logic like pundit you'll have the ability to pass it as a context to the materializer:

``` ruby
class AccountsController < ApplicationController
  def show
    context = {
      :policy => policy
    }
    render(
      :json => AccountMaterializer::Resource.new(:object => object, :context => context)
    )
  end
end
```

And now the use of that context object:

``` ruby
class AccountMaterializer
  include(JSONAPI::Materializer::Resource)

  type(:accounts)

  has_many(:reviews, :class_name => "ReviewMaterializer")

  has(:name, :visible => :visible_attribute?)

  private def visible_attribute?(attribute)
     context.policy.read_attribute(attribute.from)
  end
end
```

You'll notice that context is an object, not a hash, when referenced on the materializer. That's because we give you the ability to enforce the context for saftey:

``` ruby

class AccountMaterializer
  include(JSONAPI::Materializer::Resource)

  type(:accounts)

  has_many(:reviews, :class_name => "ReviewMaterializer")

  has(:name, :visible => :visible_attribute?)

  context.validate_presence_of(:policy)

  private def visible_attribute?(attribute)
     context.policy.read_attribute(attribute.from)
  end
end
```

These are just aliases for ActiveModel::Validations.


### Sister Projects

I'm already using jsonapi-materializer. and it's sister project [jsonapi-realizer](https://github.com/krainboltgreene/jsonapi-realizer.rb) in a new gem of mine that allows services to be discoverable: [jsonapi-home](https://github.com/krainboltgreene/jsonapi-home.rb).


## Installing

Add this line to your application's Gemfile:

    $ bundle add jsonapi-materializer

Or install it yourself with:

    $ gem install jsonapi-materializer


## Contributing

  1. Read the [Code of Conduct](/CONDUCT.md)
  2. Fork it
  3. Create your feature branch (`git checkout -b my-new-feature`)
  4. Commit your changes (`git commit -am 'Add some feature'`)
  5. Push to the branch (`git push origin my-new-feature`)
  6. Create new Pull Request
