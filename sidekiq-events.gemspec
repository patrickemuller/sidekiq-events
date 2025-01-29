# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

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
  s.files                 = Dir['{lib}/**/*', 'CHANGELOG.md', 'LICENSE', 'README.md', 'CODE_OF_CONDUCT.md']
  s.require_paths         = ['lib']
  s.extra_rdoc_files      = ['README']

  if s.respond_to?(:metadata)
    s.metadata['allowed_push_host'] = 'https://rubygems.org'

    s.metadata['homepage_uri'] = s.homepage
    s.metadata['changelog_uri'] = 'https://github.com/patrickemuller/sidekiq-events/CHANGELOG.md'
    s.metadata['source_code_uri'] = 'https://github.com/patrickemuller/sidekiq-events'
    s.metadata['rubygems_mfa_required'] = 'true'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

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
end
