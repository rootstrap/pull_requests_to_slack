Sentry.init do |config|
  config.dsn = 'https://247bbfef889243499c97d6d58cd2a788@o4505048325881856.ingest.sentry.io/4505048325881856'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
end
