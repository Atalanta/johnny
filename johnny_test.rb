require 'minitest/spec'
require 'minitest/autorun'
require 'redis'
require 'yaml'

require_relative 'johnny'

describe Johnny do


  it "retrieves whois records from upstream" do
    johnny = Johnny.new
    record = johnny.fetch_upstream("google.com")
    record.must_be_instance_of Whois::Record
  end

  it "puts whois records into a cache" do
    johnny = Johnny.new
    domain = "google.com"
    record = johnny.fetch_upstream(domain)
    johnny.cache_record(domain, record)
    redis = Redis.new
    r = YAML.load(redis.get domain)
    r[:expiry].must_be_instance_of Time
    r[:record].must_be_instance_of  Whois::Record
  end

  it "fetches from its own cache if within expiry period" do
    johnny = Johnny.new
    domain = "microsoft.com"
    record = johnny.fetch_upstream(domain)
    johnny.cache_record(domain, record)
    r = johnny.fetch(domain)
    r.must_be_instance_of Hash
  end

end
