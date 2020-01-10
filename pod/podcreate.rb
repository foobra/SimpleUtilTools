#!/bin/env ruby
pwd = ARGV[0]
pod_name = ARGV[1]

system "cd #{pwd}"
system 'mkdir', '-p', "#{pod_name}/Classes"
system 'mkdir', '-p', "#{pod_name}/Tests"
system 'mkdir', '-p', "#{pod_name}/Vendors"
system 'mkdir', '-p', "#{pod_name}/Vendors/Libraries"
system 'mkdir', '-p', "#{pod_name}/Vendors/Frameworks"
system 'mkdir', '-p', "#{pod_name}/Assets"
system 'mkdir', '-p', "#{pod_name}/Assets/Bundles"
system 'mkdir', '-p', "#{pod_name}/Assets/Res"
system 'mkdir', '-p', "#{pod_name}/Assets/Assets.xcassets"

system 'touch', "#{pod_name}/Assets/Assets.xcassets/Contents.json"
system 'touch', "#{pod_name}/#{pod_name}.podspec"
system 'touch', "#{pod_name}/Classes/.gitkeep"
system 'touch', "#{pod_name}/Assets/.gitkeep"
system 'touch', "#{pod_name}/Assets/Bundles/.gitkeep"
system 'touch', "#{pod_name}/Assets/Res/.gitkeep"
system 'touch', "#{pod_name}/Tests/.gitkeep"
system 'touch', "#{pod_name}/Vendors/.gitkeep"
system 'touch', "#{pod_name}/Vendors/Libraries/.gitkeep"
system 'touch', "#{pod_name}/Vendors/Frameworks/.gitkeep"

system 'touch', "#{pod_name}/Classes/#{pod_name}.h"
system 'touch', "#{pod_name}/R#{pod_name}.h"
system 'touch', "#{pod_name}/R#{pod_name}.m"
system 'touch', "#{pod_name}/RResource#{pod_name}.h"
system 'touch', "#{pod_name}/RResource#{pod_name}.m"

podspec_text =  <<-EOF
Pod::Spec.new do |s|
    s.name         = File.basename(path, ".*")
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
    s.source_files = 'Classes/**/*.{h,m,mm,cpp,c,hpp,cc,swift}', "R\#{s.name}.h", "R\#{s.name}.m", "RResource\#{s.name}.h", "RResource\#{s.name}.m", 'Vendors/Libraries/**/*.{h,m,mm,cpp,c,hpp,cc,swift}'
    s.exclude_files = 'Classes/**/*-Bridging-Header.h'
    s.vendored_libraries  = "Vendors/**/*.a"
    s.vendored_framework = 'Vendors/**/*.framework'
    if s.static_framework
        s.resource_bundles = { s.name => ['Assets/Assets.xcassets', 'Assets/Bundles/*.bundle', 'Assets/Res/**/*.*', 'Classes/**/*.{xib,storyboard}'] }
        s.resources = ['Vendors/**/*.bundle']
    else
        s.resources = ['Vendors/**/*.bundle', 'Assets/Assets.xcassets', 'Assets/Bundles/**/*.bundle', 'Assets/Res/**/*.*', 'Classes/**/*.{xib,storyboard}']
    end

    s.test_spec 'Tests' do |t|
        t.source_files = 'Tests/**/*.{h,m,mm,cpp,c,hpp,cc,swift}'
    end

    custom_isDynamicFramework = !s.static_framework ? "--dynamic-framework" : ""
    custom_isResourceBundle = "--is-resource-bundle"

    custom_bundle_imp = ""
    if !s.static_framework
        custom_bundle_imp = <<-EOS
            static NSBundle *_\#{s.name}Bundle = nil;
            NSBundle* \#{s.name}Bundle(void) {
                if (!_\#{s.name}Bundle) {
                    NSBundle *b1 = [NSBundle bundleWithIdentifier:@\\\"org.cocoapods.\#{s.name}\\\"];
                    NSBundle *b2 = [NSBundle bundleWithPath:[b1 pathForResource:@\\\"\#{s.name}\\\" ofType:@\\\"bundle\\\"]];
                    _\#{s.name}Bundle = b2 != nil ? b2 : b1;
                }
                return _\#{s.name}Bundle;
            }
        EOS
    else
        custom_bundle_imp = <<-EOS
            static NSBundle *_\#{s.name}Bundle = nil;
            NSBundle* \#{s.name}Bundle(void) {
                if (_\#{s.name}Bundle)
                    return _\#{s.name}Bundle;
#ifdef POD_PACKAGE_UNIVERSAL_BUNDLE
#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)
              NSBundle *b1 = [NSBundle mainBundle];
              NSBundle *b2 = [NSBundle bundleWithPath:[b1 pathForResource:@TOSTRING(POD_PACKAGE_UNIVERSAL_BUNDLE) ofType:@"bundle"]];
              if (!b2)
                  assert(false && "universalBundle load failed");
              _\#{s.name}Bundle = [NSBundle bundleWithPath:[b2 pathForResource:@\\\"\#{s.name}\\\" ofType:@\\\"bundle\\\"]];
              if (!_\#{s.name}Bundle)
                _\#{s.name}Bundle = b2;
#else
              NSBundle *b1 = [NSBundle mainBundle];
              NSBundle *b2 = [NSBundle bundleWithPath:[b1 pathForResource:@\\\"\#{s.name}\\\" ofType:@\\\"bundle\\\"]];
              _\#{s.name}Bundle = b2 != nil ? b2 : b1;
#endif

                if (!_\#{s.name}Bundle)
                    assert(false && "resBundle load failed");
                return _\#{s.name}Bundle;
            }
        EOS
    end

    custom_bundle_header = <<-EOS
        #ifdef __cplusplus
        extern "C"
        {
        #endif
          NSBundle* \#{s.name}Bundle(void);
        #ifdef __cplusplus
        }
        #endif
    EOS

    generate_bundle_str = <<-EOS
        result=`cat RResource\#{s.name}.h | grep '\#{s.name}Bundle'`
        if [ -z "$result" ]; then
            echo '\#{custom_bundle_header}' > RResource\#{s.name}.h
        fi
        echo '\#{custom_bundle_imp}' > RResource\#{s.name}.m
    EOS
    system(generate_bundle_str)

    s.script_phase  =
    [
        { :name => 'R Objc', :execution_position => :before_compile, :script => <<-EOS
            subdircount=`find $PODS_TARGET_SRCROOT/Assets/Assets.xcassets -maxdepth 1 -type d | wc -l`
            if [ $subdircount -gt 1 ]
            then
              echo "Generate R File"
              $PODS_ROOT/MGR.objc/MGRobjec/Robjc -p \\\"$PODS_TARGET_SRCROOT\\\" --skip-storyboards --skip-strings --skip-themes --skip-segues \#{custom_isDynamicFramework} \#{custom_isResourceBundle} --resource-bundle \#{s.name}
              # cd $PODS_TARGET_SRCROOT
              # sed -i '' -E 's/[[:space:]]*$//' R\#{s.name}.m
              # cd -
            fi
        EOS
        },
    ]

    s.dependency "MGR.objc"
    # Your custom dependencies
end
EOF

assets_json = <<-EOF
{
    "info" : {
      "version" : 1,
      "author" : "xcode"
    }
}
EOF



header_content = <<-EOF
//
//  #{pod_name}.h
//  Pods
//
//  Created by TSG on 1970/01/01.
//

#ifndef #{pod_name}_h
#define #{pod_name}_h


#endif /* #{pod_name}_h */
EOF


File.write("#{pod_name}/#{pod_name}.podspec", podspec_text)
File.write("#{pod_name}/Assets/Assets.xcassets/Contents.json", assets_json)
File.write("#{pod_name}/Classes/#{pod_name}.h", header_content)


