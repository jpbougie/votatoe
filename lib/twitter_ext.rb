module Twitter
  def self.with_access(token, secret)
    
    oa = oauth(true)
    oa.authorize_from_access(token, secret)
    
    client = CachingTwitterClient.new(oa, token, Redis.new)
    
    yield Twitter::Base.new(client)
  end
  
  def self.oauth(sign_in = true)
    conf = File.open(File.join(File.dirname(__FILE__), '..', 'config', 'twitter.yml') ) { |yf| YAML::load( yf ) }
    
    Twitter::OAuth.new(conf[Rails.env]['token'], conf[Rails.env]['secret'], :sign_in => sign_in)
  end
end

class FakeHTTPResponse
  attr_reader :code, :body
  def initialize(code, body)
    @code, @body = code.to_s, body
  end
end

class CachingTwitterClient
  extend Forwardable
  
  def_delegators :client, :post, :put, :delete #only cache the get query
  attr_reader :client
  
  def initialize(client, identifier, store, options = {})
    @client = client
    @identifier = identifier
    @store = store
    @expires = options[:expires] || 15 * 60 # 15 minutes
  end
  
  def key(path)
    ["twitter", @identifier, path].join(":")
  end
  
  def get(path, headers)
    k = key(path)
    if @store.exists k
      result = @store.get k
      FakeHTTPResponse.new("200", result)
    else
      begin
        result = @client.get(path, headers)
        @store.setex(k, @expires, result.body)
        result
      rescue Exception => ex
        Rails.logger.error(ex)
        raise ex
      end
    end
  end
end

class SetApiVersion
  def initialize(client, version)
    @client, @version = client, version
  end
  
  def get(path, headers)
    client.get(path =~ /^\/\d/ ? path : "/1#{path}", headers)
  end
  
  def post(path, headers, body)
    client.post(path =~ /^\/\d/ ? path : "/1#{path}", headers, body)
  end
  
  def put(path, headers, body)
    client.put(path =~ /^\/\d/ ? path : "/1#{path}", headers, body)
  end
  
  def delete(path, headers, body)
    client.delete(path =~ /^\/\d/ ? path : "/1#{path}", headers, body)
  end
end