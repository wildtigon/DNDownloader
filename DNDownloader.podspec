Pod::Spec.new do |spec|
  spec.name         = "DNDownloader"
  spec.version      = "0.1"
  spec.summary      = "A CocoaPods library written in Swift"
  spec.swift_version = "5.1"
  spec.ios.deployment_target = "10.0"
  spec.description  = <<-DESC
  A tiny library helps you perform download in Swift easier
                   DESC
  spec.homepage     = "https://github.com/wildtigon/DNDownloader"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Dat Nguyen" => "wildtigon@gmail.com" }
  spec.source       = { :git => "https://github.com/wildtigon/DNDownloader.git", :tag => "#{spec.version}" }
  spec.source_files  = "DNDownloader/**/*.{h,m,swift}"
  spec.exclude_files = "Classes/Exclude"
end
