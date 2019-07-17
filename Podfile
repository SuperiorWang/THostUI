source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
inhibit_all_warnings!

use_frameworks!

workspace 'UQPayHostUIDemo.xcworkspace'


def commpod
    pod 'JSONModel'
    pod 'AFNetworking'
    pod 'WHToast'
end

target 'UQPayHostUIDemo' do

  project 'UQPayHostUIDemo'
  commpod
  pod 'NSURL+QueryDictionary', '~> 1.0'
  pod 'InAppSettingsKit'

#  pod "UQPayHostUI", :path => "./UQPayHostUI"
end

target 'UQPayHostUI' do
# project 'UQPayHostUI/UQPayHostUI'
 commpod
end

target 'UQPayHostUIKit' do
#  project 'UQPayHostUIKit/UQPayHostUIKit'
end
