require 'lograge'
require 'airbrake'
require 'bw_log_formatter'

#  Monkey-patch so that we can capture the entire exception
module ActiveSupport
  module Notifications
    class Instrumenter
      def instrument(name, payload={})
        start name, payload
        begin
          yield payload
        rescue Exception => e
          payload[:exception_object] = e
          raise e
        ensure
          finish name, payload
        end
      end
    end
  end
end

# Shared lograge configuration
module BwLograge
  class << self
    attr_accessor :configuration

    def lograge!
      #  Go configure the rails app
      Rails.application.configure do
        # Airbrake for exception logging
        config.middleware.use Airbrake::Rack::Middleware

        config.log_level = :info
        config.log_formatter = BwLogFormatter.new
        config.lograge.enabled = true

        config.lograge.custom_options = lambda {|e|
          err = e.payload[:exception_object]
          options = {
            :time => e.time,
            :params => e.payload[:params],
            :extra => e.payload[:extra]
          }
          options[:extra] = {
            :error_class => err.class.name,
            :error_message => err.message,
            :error_backtrace => err.backtrace
          } if err
          options
        }

        config.lograge.before_format = lambda do |data, payload|
          [:controller, :action, :format].each {|k| data.delete(k); data[:params].delete(k.to_s)}
          h = ActiveSupport::OrderedHash.new
          [:time, :method, :path, :status, :duration, :view, :db, :extra, :params].each {|k| h[k] = data[k]}
          return h
        end

        config.lograge.formatter = Lograge::Formatters::Json.new
      end
    end
  end
end
