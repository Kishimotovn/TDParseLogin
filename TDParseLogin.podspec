Pod::Spec.new do |s|

  s.name         = "TDParseLogin"
  s.version      = "1.0"
  s.summary      = "An framework for fast social login and modifying PFUser."
  s.homepage     = "https://bitbucket.com/thedistance"
  s.license      = "MIT"
  s.author       = { "The Distance" => "dev@thedistance.co.uk" }
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/Kishimotovn/TDParseLogin.git", :tag => "#{s.version}" }
  s.requires_arc = true
  
  # If more than one source file: https://guides.cocoapods.org/syntax/podspec.html#source_files
  s.source_files = 'TDParseLogin/*.swift'
  s.dependency 'Bolts'
  s.dependency 'Parse'
  s.dependency 'ParseFacebookUtilsV4'
  s.dependency 'ParseTwitterUtils'
  s.dependency 'Google/SignIn'
end
