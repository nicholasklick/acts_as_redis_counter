require "acts_as_redis_counter/version"

# ActsAsRedisCounter
module ActsAsRedisCounter #:nodoc:
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def acts_as_redis_counter(*attributes)

      options = attributes.last.is_a?(Hash) ? attributes.pop : {}
      options = {
        :ttl => 5.minutes,
        :hits => 100
      }.merge(options)


      attributes.each do |attribute|
        # inc method
        define_method("redis_counter_#{attribute}_inc") do |*args|
          n = args.first || 1
          key = redis_counter_key(attribute)

          send("redis_counter_load_#{attribute}")
          REDIS.incrby(key, n)
          send("redis_counter_flush_#{attribute}")
          REDIS[key]
        end

        # getter
        define_method("redis_counter_#{attribute}") do
          key = redis_counter_key(attribute)
          REDIS[key] = send(attribute) if REDIS[key].nil?
          REDIS[key]
        end

        # load from db
        define_method("redis_counter_load_#{attribute}") do
          key = redis_counter_key(attribute)
          REDIS[key] = send(attribute) if REDIS[key].nil?
        end

        # save to db
        define_method("redis_counter_flush_#{attribute}") do
          redis_value = send("redis_counter_#{attribute}").to_i
          db_value = send(attribute).to_i
          hits = options[:hits].to_i

          ttl_key = redis_counter_ttl_key(attribute)
          expired = REDIS[ttl_key].nil?

          # save to db
          if (redis_value - db_value) > hits or expired
            send(:update_attribute, attribute, redis_value)

            # set ttl key expiration
            REDIS[ttl_key] = 1
            REDIS.expire ttl_key, options[:ttl].to_i
          end
        end

        # save to db and cleanup redis counter
        define_method("redis_counter_cleanup_#{attribute}") do
          redis_value = send("redis_counter_#{attribute}").to_i
          db_value = send(attribute).to_i

          # save to db
          if redis_value != db_value
            update_attribute(attribute, redis_value)
          end

          REDIS.del redis_counter_key(attribute), redis_counter_ttl_key(attribute)
        end

        # declare private methods
        private "redis_counter_load_#{attribute}"
        private "redis_counter_flush_#{attribute}"
      end

      include ActsAsRedisCounter::InstanceMethods
    end
  end

  module InstanceMethods
    private

    def redis_counter_key(attribute)
      "redis_counter_#{self.class.name.downcase}_#{self.id}_#{attribute}"
    end

    def redis_counter_ttl_key(attribute)
      redis_counter_key(attribute) + "_ttl"
    end
  end
end

ActiveRecord::Base.send(:include, ActsAsRedisCounter)
