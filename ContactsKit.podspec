Pod::Spec.new do |s|
  s.name         = "ContactsKit"
  s.version      = "2.0.0"
  s.summary      = "Contacts management without headache"
  s.homepage     = "https://github.com/Serjip/ContactsKit"
  s.license      = { :type => "MIT", :file => "LICENSE.txt" }
  s.author       = { "Sergey Popov" => "serj@ttitt.ru" }
  s.source       = { :git => "https://github.com/Serjip/ContactsKit.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.source_files = "ContactsKit/**/*.{h,m}"
  s.public_header_files = "ContactsKit/Public/*.h"

#iOS
  s.ios.frameworks   = "AddressBook"
  s.ios.deployment_target = "6.0"
  

#OSX
  s.osx.frameworks   = "AddressBook"
  s.osx.deployment_target = "10.7"

end
