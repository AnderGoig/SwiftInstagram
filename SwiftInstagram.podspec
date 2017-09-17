Pod::Spec.new do |s|
 s.name = 'SwiftInstagram'
 s.version = '1.0.0'
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'A Swift wrapper for the Instagram API'
 s.homepage = 'https://github.com/AnderGoig/SwiftInstagram'
 s.social_media_url = 'https://twitter.com/AnderGoig'
 s.authors = { "Ander Goig" => "goig.ander@gmail.com" }
 s.source = { :git => "https://github.com/AnderGoig/SwiftInstagram.git", :tag => "v"+s.version.to_s }
 s.platforms     = { :ios => "9.0" }
 s.requires_arc = true

 s.default_subspec = "Core"
 s.subspec "Core" do |ss|
     ss.source_files  = "Sources/*.swift"
     ss.framework  = "Foundation"
 end

end
