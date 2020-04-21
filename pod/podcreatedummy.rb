#!/bin/env ruby
pwd = ARGV[0]
pod_name = ARGV[1]

system "cd #{pwd}"
system 'mkdir', '-p', "#{pod_name}/Vendors"
system 'mkdir', '-p', "#{pod_name}/Vendors/Libraries"
system 'mkdir', '-p', "#{pod_name}/Vendors/Frameworks"

system 'touch', "#{pod_name}/#{pod_name}.podspec"
system 'touch', "#{pod_name}/Vendors/.gitkeep"
system 'touch', "#{pod_name}/Vendors/Libraries/.gitkeep"
system 'touch', "#{pod_name}/Vendors/Frameworks/.gitkeep"

system 'touch', "#{pod_name}/DUMMY_CLASS_NSObject_Addition_#{pod_name}_Dummy.h"
system 'touch', "#{pod_name}/DUMMY_CLASS_NSObject_Addition_#{pod_name}_Dummy.m"

podspec_text =  <<-EOF
Pod::Spec.new do |s|
    s.name         = File.basename(path, ".*")
    s.module_name  = s.name + "Dummy"
    s.version      = "1.0.0"
    s.homepage     = "https://www.github.com"
    s.author       = "iOS"
    s.summary      = s.name
    s.source       = { :path => '.' }
    s.platform     = :ios, '9.0'
    s.ios.deployment_target = '9.0'
    s.framework    = "Foundation", "UIKit"
    s.requires_arc = true
    s.static_framework = true
    s.cocoapods_version = '= 1.8.0'
    s.swift_version = '5.0'
    s.source_files = 'DUMMY_CLASS_NSObject_Addition_#{pod_name}_Dummy.m'
    s.resources = ['Vendors/Libraries/*.bundle', 'Vendors/Frameworks/*.bundle']
    s.vendored_libraries  = "Vendors/**/*.a"
    s.vendored_framework = 'Vendors/**/*.framework'

    s.pod_target_xcconfig = {
        "EXCLUDED_SOURCE_FILE_NAMES" => "*-dummy.m"
    }


    # s.dependency "MGR.objc"
    # Your custom dependencies
end
EOF





header_content = <<-EOF
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DUMMY_CLASS_NSObject_Addition_#{pod_name}_Dummy : NSObject

@end

NS_ASSUME_NONNULL_END
EOF

src_content = <<-EOF
#import "DUMMY_CLASS_NSObject_Addition_#{pod_name}_Dummy.h"

@implementation DUMMY_CLASS_NSObject_Addition_#{pod_name}_Dummy

@end
EOF


File.write("#{pod_name}/#{pod_name}.podspec", podspec_text)
File.write("#{pod_name}/DUMMY_CLASS_NSObject_Addition_#{pod_name}_Dummy.h", header_content)
File.write("#{pod_name}/DUMMY_CLASS_NSObject_Addition_#{pod_name}_Dummy.m", src_content)


