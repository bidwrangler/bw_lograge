Gem::Specification.new do |s|
  s.name         = 'bw_lograge'
  s.version      = '0.0.1'
  s.date         = '2018-05-30'
  s.summary      = "BidWrangler Lograge"
  s.description  = "Configuration and log formaters to produce JSON parseable rails logs"
  s.authors      = ["BidWrangler"]
  s.email        = 'developers@bidwrangler.com'
  s.files        = ["lib/bw_log_formatter.rb", "lib/bw_lograge.rb"]
  s.homepage     = 'https://github.com/bidwrangler/bw_lograge'
  s.license      = 'MIT'
  s.require_path = 'lib'
  s.add_dependency 'airbrake', '~> 6.0'
  s.add_dependency 'lograge'
  s.add_dependency 'useragent'
  s.add_dependency 'oj'
end
