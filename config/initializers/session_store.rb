Rails.application.config.session_store :redis_session_store,
  servers: [
    {
      host: ENV.fetch("REDIS_HOST") { "redis" },
      port: ENV.fetch("REDIS_PORT") { 6379 },
      db: 0,
      namespace: "session"
    }
  ],
  expire_after: 90.minutes,
  key: "_myapp_session",
  threadsafe: false,
  secure: Rails.env.production?
