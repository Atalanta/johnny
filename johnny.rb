require 'whois'
require 'redis'
require 'yaml'

class Johnny

  def fetch_upstream(record)
    Whois.whois(record)
  end

  def cache_record(domain, record)
    expiry = Time.now + (rand(3600) + 1800)
    cached_record = {:expiry => expiry, :record => record}
    redis = Redis.new
    redis.set domain, cached_record.to_yaml
  end

  def fetch(domain)
    redis = Redis.new
    if redis.keys.include? domain
      record = YAML::load(redis.get domain)
      if record[:expiry] > Time.now
        record[:record]
      else
        fetch_upstream(record)
      end
    else
      fetch_upstream(record)
    end
  end
  
end
