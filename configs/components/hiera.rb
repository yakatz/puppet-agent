component "hiera" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/hiera.json')

  pkg.build_requires 'puppet-runtime' # Provides ruby and rubygem-deep-merge
  pkg.replaces 'hiera', '2.0.0'
  pkg.provides 'hiera', '2.0.0'

  pkg.replaces 'pe-hiera'

  configdir = settings[:puppet_configdir]
  flags = " --bindir=#{settings[:bindir]} \
            --sitelibdir=#{settings[:ruby_vendordir]} \
            --ruby=#{File.join(settings[:bindir], 'ruby')} "

  if platform.is_cross_compiled? && platform.is_macos?
    ruby_version_y = settings[:ruby_version].gsub(/(\d+)\.(\d+)\.(\d+)/, '\1.\2')
    pkg.build_requires "ruby@#{ruby_version_y}"
  end

  if platform.is_windows?
    pkg.add_source("file://resources/files/windows/hiera.bat", sum: "bbe0a513808af61ed9f4b57463851326")
    pkg.install_file "../hiera.bat", "#{settings[:link_bindir]}/hiera.bat"
  end

  pkg.install do
    ["#{settings[:host_ruby]} install.rb \
    --configs \
    --configdir=#{configdir} \
    --man \
    --mandir=#{settings[:mandir]} \
    --no-batch-files \
    --no-configs \
    #{flags}"]
  end

  pkg.install_file ".gemspec", "#{settings[:gem_home]}/specifications/#{pkg.get_name}-#{pkg.get_version_forced}.gemspec"

end
