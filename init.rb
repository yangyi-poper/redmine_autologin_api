Redmine::Plugin.register :redmine_autologin_api do
  name 'Redmine Autologin API Plugin'
  author 'CloudStudio Team'
  description 'Provides REST API for autologin token management to support SSO integration'
  version '1.0.0'
  url 'https://github.com/your-org/redmine_autologin_api'
  author_url 'https://your-company.com'

  requires_redmine version_or_higher: '5.0.0'
end
