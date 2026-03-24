Rails.application.config.session_store :cookie_store,
  key: '_redmine_session',
  domain: :all,
  path: '/',
  same_site: :lax
