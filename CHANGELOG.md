## 2.3.3
- Fix a bug to not resolve application name when garage_client-rails is bundled.
- Stop to support ruby version < 2.2.2.

## 2.3.2
- Automatically set `Rails.application.class.parent_name.underscore`
  to `name` configuration in Rails by default.

## 2.3.1
- Raise `GarageClient::GatewayTimeout` for 504 error

## 2.3.0
- Add `name` configuration to set application name to User-Agent

## 2.2.0
- Change all 4xx exceptions to be `GarageClient::ClientError`
- Change all 5xx exceptions to be `GarageClient::ServerError`

## 2.1.7
- Append `HTTP_X_REQUEST_ID` header by `Thread.current[:request_id]`

## 2.1.6
- Raise error on 4xx client errors or 5xx server errors.

## 2.1.5
- Better error message for unexpected property access
- Add `:timeout` and `:open_timeout` option

## 2.1.4
- Remove mime-types dependency

## 2.1.3
- Raise GrageClient::BadRequest on 400 response as same as other http errors.

## 2.1.2
- Fix GarageClient::Cachers's bug.
- Lazy evaluate global configuration.

## 2.1.1
- First release of OSS version :tada:.
