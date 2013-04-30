Twitter.configure do |config|
  config.consumer_key = AppConfig.twitter.consumer_key
  config.consumer_secret = AppConfig.twitter.consumer_secret
end

# Monkey patch to solve: https://dev.twitter.com/discussions/15989
module Twitter
  class Client
    def request(method, path, params={}, signature_params=params)
      connection.send(method.to_sym, path, params) do |request|
        request.headers[:authorization] = auth_header(method.to_sym, path, signature_params).to_s
        request.headers['accept-encoding'] = ""  ## Disable gzip encoding in responses
      end.env
    rescue Faraday::Error::ClientError
      raise Twitter::Error::ClientError
    rescue MultiJson::DecodeError
      raise Twitter::Error::DecodeError
    end
  end
end
