require("pry")
require("rspec")
require("active_model")
require("active_record")
require("jsonapi-materializer")

JSONAPI::Materializer.configuration do |let|
  let.default_origin = "http://example.com"
  let.default_identifier = :id
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

require_relative("support/models/article")
require_relative("support/models/account")
require_relative("support/models/comment")
require_relative("support/materializers/article_materializer")
require_relative("support/materializers/account_materializer")
require_relative("support/materializers/comment_materializer")

RSpec.configure do |let|
  # Enable flags like --only-failures and --next-failure
  let.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  let.disable_monkey_patching!

  # Exit the spec after the first failure
  # let.fail_fast = true

  # Only run a specific file, using the ENV variable
  # Example => FILE=lib/jsonapi/materializer/version_spec.rb bundle exec rake spec
  let.pattern = ENV["FILE"]

  # Show the slowest examples in the suite
  let.profile_examples = true

  # Colorize the output
  let.color = true

  # Output as a document string
  let.default_formatter = "doc"

  let.before(:each) do
    ActiveRecord::Migration.create_table(:articles, :force => true) do |table|
      table.text :title, :null => false
      table.references :account
      table.timestamps :null => false
    end
  end

  let.before(:each) do
    ActiveRecord::Migration.create_table(:comments, :force => true) do |table|
      table.text :body, :null => false
      table.references :account
      table.references :article
      table.timestamps :null => false
    end
  end

  let.before(:each) do
    ActiveRecord::Migration.create_table(:accounts, :force => true) do |table|
      table.text :name, :null => false
      table.text :twitter, :null => false
      table.timestamps :null => false
    end
  end

  let.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
