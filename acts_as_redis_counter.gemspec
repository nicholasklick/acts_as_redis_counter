# -*- encoding: utf-8 -*-
require File.expand_path('../lib/acts_as_redis_counter/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'activerecord', '>= 3.0.0'
  gem.add_dependency 'redis'

  gem.authors       = ["oleg dashevskii"]
  gem.email         = ["olegdashevskii@gmail.com"]
  gem.description   = %q{The acts_as_redis_counter plugin implements high performance counters using write-back strategy with Redis key-value database}
  gem.summary       = %q{Redis-backed counters for activerecord}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "acts_as_redis_counter"
  gem.require_paths = ["lib"]
  gem.version       = ActsAsRedisCounter::VERSION
end
