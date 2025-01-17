# frozen_string_literal: true

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 3.2.0'
  s.name                  = 'sidekiq-events'
  s.version               = '1.0.0'
  s.summary               = 'Provides an easy interface to publish and subscribe to events with Wisper + Sidekiq'
  s.description           = 'Provides an easy interface to publish and subscribe to events with Wisper + Sidekiq'
  s.authors               = ['Joe Gaudet', 'Patrick Muller']
  s.email                 = ''
  s.homepage              = 'https://github.com/patrickemuller/sidekiq-events'
  s.license               = 'MIT'
  s.files                 = Dir['{lib}/**/*', 'CHANGELOG.md', 'MIT-LICENSE', 'README.md']
  s.require_paths         = ['lib']
  s.extra_rdoc_files      = ['README']

  s.post_install_message = '
[SIDEKIQ-EVENTS]
Thanks for installing Sidekiq-Events, we hope you find it useful as this is for us!
Check the changelog for the latest updates and features.

[SPECIAL THANKS]
Thanks to Joe Gaudet for the original implementation of the event/handler system!
Thank you "Kris Leech" for the original implementation of wisper-sidekiq, and for inspiring us on doing this improvement

[changelog]
https://github.com/patrickemuller/sidekiq-events/blob/main/CHANGELOG.md
  '

  s.add_dependency 'wisper-sidekiq', '~> 1.3.0'
  s.metadata['rubygems_mfa_required'] = 'true'
end
