# gotenberg

`gotenberg` is a simple Ruby client for gotenberg

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add gotenberg

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install gotenberg

## Usage
```ruby
    client = Gotenberg::Client.new(ENV.fetch('GOTENBERG_ENDPOINT', nil))
    pdf_content = client.html(pdf_html)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SELISEdigitalplatforms/l3-ruby-gem-gotenberg.git
