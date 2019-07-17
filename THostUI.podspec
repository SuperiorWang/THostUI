Pod::Spec.new do |s|

  s.name           = "THostUI"
  s.version        = "0.0.1"
  s.summary        = "THostUI :A modern foundation for accepting payments"

  s.description    = <<-DESC
                     THostUI is a full-stack payments platform for developers
                     This CocoaPod will help you accept payment in your iOS app.
                     DESC

  s.license        = "MIT"

  s.author         = { "cqwang" => "wangchaoqun@uqpay.com" }

  s.platform       = :ios, "9.0"
  s.requires_arc   = true
  # s.compiler_flags = "-Wall -Werror -Wextra"

  s.homepage       = "https://github.com/SuperiorWang/THostUI"
  s.source         = { :git => "https://github.com/SuperiorWang/THostUI.git", :tag => s.version.to_s }

  s.default_subspecs = %w[HostUI]

  s.subspec "UIKit" do |s|
    s.source_files = "UQPayHostUIKit/**/*.{h,m}"
    s.public_header_files = "UQPayHostUIKit/Public/*.h"
    s.frameworks = "UIKit"
    s.resource_bundles = {
      "ThostUI-UIKit-Localization" => ["UQPayHostUIKit/Localization/*.lproj"]
    }
  end

  s.subspec "HostUI" do |s|
    s.source_files = "UQPayHostUI/**/*.{h,m}"
    s.public_header_files = "UQPayHostUI/Public/*.h"
    s.frameworks = "Foundation","UIKit"
    s.dependency "JSONModel"
    s.dependency "AFNetworking"
    s.dependency "WHToast"
    s.dependency "THostUI/UIKit"
    # s.vendored_frameworks = 'UQPayHostUI/**/*.framework'
  end


end
