## 2.1.0
- Access token is now embedded in authorization header as a bearer token, instead of embedding in query parameter, to avoid logging and exposing access token value.
  Before: access token is embedded in both query parameter (`?access_token=XXX`) and in authorization header (`Authorization: Token token="XXX"`).
  After: access tok is embedded in authorization header as a bearer token (`Authorization: Bearer XXX`).

## 2.0.0
- Remove `user_agent` configuration, use `headers` option instead.

## 1.3.0
- Provide a convenient way to cache HTTP response

## 1.2.4
- Raise GarageClient::InvalidResponseType when receives invalid response (e.g. String)

## 1.2.3
- Fixed response.respond_to?(:name)

## 1.2.2
- GarageClient::Response supports Link header parsing

## 1.2.1
- Set Content-Type with multipart/form-data when multipart params are detected

## 1.2.0
- `:headers` option will overwrite the entire headers
- `:default_headers` will be deprecated. Please use `:headers`
- `Garage.version` was deprecated. Please use `Garage::VERSION`
- `Garage.configuration` was added to configure settings

## 1.1.2
- Remove needless empty module clause (7f5e13)
- Change gemspec dependency (`hashie ~> 1.2.0` to `hashie >= 1.2.0`) (632ea1)

## 1.1.1
- GarageClient::Error accepts no argument initialization

## 1.1.0
- Add ``:default_headers`` option
- Verbose exception message
- Resource#links does not raise error when _links is not existed
