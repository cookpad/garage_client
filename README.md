# GarageClient [![Build Status](https://travis-ci.org/cookpad/garage_client.svg?branch=master)](https://travis-ci.org/cookpad/garage_client)
GarageClient is a simple Ruby library to provide a primitive client interface to the Garage application API.

## Install
Install from rake command:

```
$ bundle install
$ rake install
```

or modify Gemfile in your application and invoke `bundle install`.

```ruby
# Gemfile
gem "garage_client"
```

## Usage
Here are quick examples.

### Client initialization
```ruby
require "garage_client"

# First, you have to create a GarageClient::Client with an access token.
# You can get `YOUR_ACCESS_TOKEN` with OAuth 2.0 flow.
client = GarageClient::Client.new(access_token: YOUR_ACCESS_TOKEN)
```

### Read from Garage application
```ruby
# GET https://garage.example.com/v1/recipes
client.get("/recipes")

# GET https://garage.example.com/v1/recipes?fields=id,name,ingredients
client.get("/recipes", fields: "id,name,ingredients")

# GET https://garage.example.com/v1/me
user = client.get("/me")

# GET https://garage.example.com/v1/users/:user_id/recipes?fields=__default__,user[id,name]
client.get("/users/#{user.id}/recipes", fields: "__default__,user[id,name]")
```

### Write to Garage application
```ruby
# POST https://garage.example.com/v1/suggestions
client.post("/suggestions", message: "suggestion message")

# POST https://garage.example.com/v1/users/:user_id/bookmark_tags with JSON {"name":"tag name"}
bookmark_tag = client.post("/users/#{user.id}/bookmark_tags", name: "tag name")

# PUT https://garage.example.com/v1/bookmark_tags/:id with JSON {"name":"new tag name"}
client.put("/bookmark_tags/#{bookmark_tag.id}", name: "new tag name")

# DELETE https://garage.example.com/v1/bookmark_tags/:id
client.delete("/bookmark_tags/#{bookmark_tag.id}")
```

### Response
```ruby
# `.get` method returns a GarageClient::Response of a resource.
user = client.get("/me")
user.id
user.url
user.name

# `.get` method also returns a GarageClient::Response of an array of resources.
# In this case, the response object can respond to `.total_count` method.
recipes = client.get("/recipes")
recipes.total_count
recipes[0].id
recipes[0].name

# While Garage application API returns all default properties, some additional properties are not included in them.
# You can specify the returned properties by `?fields=...` URI query parameters.
recipes = client.get("/recipes", fields: "__default__,user")
recipes[0].id
recipes[0].name
recipes[0].user.id
recipes[0].user.url
recipes[0].user.name

# `.post` method also returns a GarageClient::Response of the newly created resource.
suggestion = client.post("/suggestions", message: "suggestion message")
suggestion.message
```

## Configuration
There are the following options:

- `adapter` - faraday adapter for http client (default: `:net_http`)
- `cacher` - take a cacher class in which caching logic is defined (default: nil)
- `name` - Client's application name, which is embedded in User-Agent by default (default: nil. For Rails, `Rails.application.class.parent_name.underscore` is set by default.)
  - `name` must be configured globally.
- `headers` - default http headers (default: `{ "Accept" => "application/json", "User-Agent" => "garage_client #{VERSION} #{name}" }`)
- `endpoint` - Garage application API endpoint (default: nil)
- `path_prefix` - API path prefix (default: `'/v1'`)
- `verbose` - Enable verbose http log (default: `false`)

You can configure the global settings:

```ruby
GarageClient.configure do |c|
  c.endpoint = "http://localhost:3000"
  c.name = 'my-awesome-client'
  c.verbose = true
end
```

or each GarageClient::Client settings:

```ruby
client = GarageClient::Client.new(
  adapter: :test,
  headers: { "Host" => "garage.example.com" },
  endpoint: "http://localhost:3000",
  path_prefix: "/v2",
  verbose: true,
)
```

## Exceptions
GarageClient raises one of the following exceptions upon an error.
Make sure to always look out for these in your code.

```ruby
GarageClient::BadRequest
GarageClient::Unauthorized
GarageClient::Forbidden
GarageClient::NotFound
GarageClient::NotAcceptable
GarageClient::Conflict
GarageClient::UnsupportedMediaType
GarageClient::UnprocessableEntity
GarageClient::InternalServerError
GarageClient::ServiceUnavailable
GarageClient::GatewayTimeout
```

## Utility
`.properties` returns a list of properties of the resource.

```ruby
user = client.get("/me")
user.properties #=> [:id, :url, :name, :_links]
```

`.links` returns a list of link names related to the resource.

```ruby
user = client.get("/me")
user.properties #=> [:self, :bookmarks, :recipes, ...]
user.links.recipes #=> "https://garage.example.com/v1/users/:user_id/recipes"
```

## Caching
Define a cacher class with your custom caching logic to let it cache response, inheriting GarageClient::Cachers::Base.
It must override `read_from_cache?`, `written_to_cache?`, `key`, and `store` to compose your caching logic.

```ruby
class MyCacher < GarageClient::Cachers::Base
  private

  def read_from_cache?
    has_get_method? && has_cached_path?
  end

  def written_to_cache?
    read_from_cache?
  end

  def key
    @env[:url].to_s
  end

  def store
    Rails.cache
  end

  def options
    { expires_in: 5.minutes }
  end

  def has_get_method?
    @env[:method] == :get
  end

  def has_cached_path?
    case @env[:url].path
    when %r<^/v1/searches>
      true
    when %r<^/v1/recipes/\d+>
      true
    end
  end
end

GarageClient::Client.new(cacher: MyCacher)
```
