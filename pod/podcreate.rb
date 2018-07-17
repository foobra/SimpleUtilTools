
pwd = ARGV[0]
pod_name = ARGV[1]

system "cd #{pwd}"
system 'mkdir', '-p', "#{pod_name}/Classes"
system 'mkdir', '-p', "#{pod_name}/Tests"
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

system 'touch', "#{pod_name}/R#{pod_name}.h"
system 'touch', "#{pod_name}/R#{pod_name}.m"
system 'touch', "#{pod_name}/RResource#{pod_name}.h"
system 'touch', "#{pod_name}/RResource#{pod_name}.m"

podspec_text =  <<-EOF
Pod::Spec.new do |s|
    s.name         = "#{pod_name}"
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
    s.cocoapods_version = '= 1.5.3'
    s.swift_version = '4.1'
    s.source_files = 'Classes/**/*.{h,m,mm,cpp,c,hpp,cc,swift}', "R\#{s.name}.h", "R\#{s.name}.m", "RResource\#{s.name}.h", "RResource\#{s.name}.m"
    s.exclude_files = 'Classes/**/*-Bridging-Header.h'
    if s.static_framework
        s.resource_bundles = { s.name => ['Assets/Assets.xcassets', 'Assets/Bundles/*.bundle', 'Assets/Res/**/*.*', 'Classes/**/*.{xib,storyboard}'] }
    else
        s.resources = ['Assets/Assets.xcassets', 'Assets/Bundles/**/*.bundle', 'Assets/Res/**/*.*', 'Classes/**/*.{xib,storyboard}']
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
                if (!_\#{s.name}Bundle) {
                    NSBundle *b1 = [NSBundle mainBundle];
                    NSBundle *b2 = [NSBundle bundleWithPath:[b1 pathForResource:@\\\"\#{s.name}\\\" ofType:@\\\"bundle\\\"]];
                    _\#{s.name}Bundle = b2 != nil ? b2 : b1;
                }
                return _\#{s.name}Bundle;
            }
        EOS
    end

    custom_bundle_header = <<-EOS
        NSBundle* \#{s.name}Bundle(void);
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

File.write("#{pod_name}/#{pod_name}.podspec", podspec_text)
File.write("#{pod_name}/Assets/Assets.xcassets/Contents.json", assets_json)




