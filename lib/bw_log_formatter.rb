class BwLogFormatter
  def self.log_hash(data, datetime=nil)
    if data.instance_of?(String)
      data = {message: data.dup}
    else
      data = data.dup
    end
    timings = data.delete(:time) rescue nil
    ActiveSupport::OrderedHash.new.tap do |h|
      h[:time] = datetime.iso8601 if datetime
      h[:method] = data.delete(:method) if data.has_key?(:method)
      h[:path] = data.delete(:path) if data.has_key?(:path)
      h[:status] = data.delete(:status) if data.has_key?(:status)
      h[:duration] = timings[:total] if timings && timings.has_key?(:total)
      h[:db] = timings[:db] if timings && timings.has_key?(:db)
      h[:view] = timings[:view] if timings && timings.has_key?(:view)
      h[:message] = data.delete(:message) if data.has_key?(:message)
      h[:params] = data.delete(:params).symbolize_keys.except(
        *Rails.application.config.filter_parameters) if data.has_key?(:params)
      h[:extra] = data.delete(:extra) if data.has_key?(:extra)
    end
  end

  def call(severity, datetime, progname, data)
    if data =~ /^\{/ # JSON data... already formated
      return data + "\n"
    else
      Oj.dump(self.class.log_hash(data, datetime), mode: :compat) + "\n"
    end
  end
end
