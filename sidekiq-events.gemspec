# frozen_string_literal: true

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 3.2.0'
  s.name                  = 'sidekiq_events'
  s.version               = '1.0.0'
  s.summary               = 'Provides an easy interface to publish and subscribe to events with Wisper + Sidekiq'
  s.description           = 'Provides an easy interface to publish and subscribe to events with Wisper + Sidekiq'
  s.authors               = ['Joe Gaudet', 'Patrick Muller']
  s.email                 = ''
  s.homepage              = 'https://github.com/patrickemuller/sidekiq-events'
  s.license               = 'MIT'
  s.require_paths         = ['lib']
  s.extra_rdoc_files      = ['README']

  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless s.respond_to?(:metadata)

  s.metadata['allowed_push_host'] = 'https://rubygems.org'

  s.metadata['homepage_uri'] = s.homepage
  s.metadata['changelog_uri'] = 'https://github.com/patrickemuller/sidekiq-events/CHANGELOG.md'
  s.metadata['source_code_uri'] = 'https://github.com/patrickemuller/sidekiq-events'
  s.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  s.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
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

  s.add_dependency 'dry-struct', '~> 1.0'
  s.add_dependency 'dry-types', '~> 1.8'
  s.add_dependency 'wisper', '~> 3.0.0'
  s.add_dependency 'wisper-sidekiq', '~> 1.3.0'
end
