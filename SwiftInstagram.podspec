Pod::Spec.new do |s|
 s.name                 = 'SwiftInstagram'
 s.version              = '1.1.2'
 s.cocoapods_version    = '>= 1.1.0'
 s.authors              = { 'Ander Goig' => 'goig.ander@gmail.com' }
 s.license              = { :type => 'MIT', :file => 'LICENSE' }
 s.homepage             = 'https://github.com/AnderGoig/SwiftInstagram'
 s.source               = { :git => 'https://github.com/AnderGoig/SwiftInstagram.git',
                            :tag => "v#{s.version}" }
 s.summary              = 'An Instagram API client written in Swift.'
 s.description          = <<-DESC
                            SwiftInstagram is a wrapper for the Instagram API written in Swift. It allows
                            you to authenticate users and request data from Instagram effortlessly.
                          DESC
 s.documentation_url    = 'https://andergoig.github.io/SwiftInstagram/'

 s.platform             = :ios, '9.0'

 s.default_subspec      = 'Core'
 s.subspec 'Core' do |ss|
     ss.framework       = 'Foundation'
     ss.source_files    = 'Sources/*.swift', 'Sources/**/*.swift'
 end

end
