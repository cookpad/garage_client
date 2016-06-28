## 2.3.0
- Add new configuration parameter `name`, which is embedded in User-Agent by default

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
