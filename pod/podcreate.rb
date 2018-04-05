
pwd = ARGV[0]
pod_name = ARGV[1]

system "cd #{pwd}"
system 'mkdir', '-p', "#{pod_name}/Classes"
system 'mkdir', '-p', "#{pod_name}/Assets"
system 'mkdir', '-p', "#{pod_name}/Assets/Assets.xcassets"
system 'touch', "#{pod_name}/Assets/Assets.xcassets/Contents.json"
system 'touch', "#{pod_name}/#{pod_name}.podspec"
system 'touch', "#{pod_name}/Classes/.gitkeep"
system 'touch', "#{pod_name}/Assets/.gitkeep"
system 'touch', "#{pod_name}/R#{pod_name}.h"
system 'touch', "#{pod_name}/R#{pod_name}.m"

podspec_text =  <<-EOF
Pod::Spec.new do |s|
    s.name         = "#{pod_name}"
    s.version      = "1.0.0"
    s.homepage     = "https://www.github.com"
    s.author       = "TSG iOS"
    s.summary      = s.name
    s.source       = { :path => '.' }
    s.platform     = :ios, '9.0'
    s.ios.deployment_target = '9.0'
    s.framework    = "Foundation", "UIKit"
    s.requires_arc = true
    s.static_framework = true
    s.cocoapods_version = '>= 1.4.0'
    s.swift_version = '4.1'
    s.source_files = 'Classes/**/*.{h,m,mm,cpp,c,hpp,cc,swift}', "R\#{s.name}.h", "R\#{s.name}.m"
    s.exclude_files = 'Classes/**/*-Bridging-Header.h'
    # s.resources = "Assets/**/*.{bundle,json,xcassets,gif}"
    s.resource_bundles = { s.name => ['Assets/**/*.*', 'Classes/**/*.{xib,storyboard}'] }

    custom_isDynamicFramework = !s.static_framework ? "--dynamic-framework" : ""
    # FIXME 这里暂时需要自己重复申明一次
    isResourceBundle = true
    custom_isResourceBundle = isResourceBundle ? "--is-resource-bundle" : ""

    custom_bundle_header = ""
    custom_bundle_imp = ""
    if !s.static_framework
        if isResourceBundle
            custom_bundle_header = <<-EOS
NSBundle* \#{s.name}Bundle(void);
               EOS
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
        end
    else
        if isResourceBundle
            custom_bundle_header = <<-EOS
NSBundle* \#{s.name}Bundle();
EOS
custom_bundle_imp = <<-EOS
static NSBundle *_\#{s.name}Bundle = nil;
NSBundle* \#{s.name}Bundle() {
    if (!_\#{s.name}Bundle) {
        NSBundle *b1 = [NSBundle mainBundle];
        NSBundle *b2 = [NSBundle bundleWithPath:[b1 pathForResource:@\\\"\#{s.name}\\\" ofType:@\\\"bundle\\\"]];
        _\#{s.name}Bundle = b2 != nil ? b2 : b1;
    }
    return _\#{s.name}Bundle;
}
EOS
        end
    end

    s.script_phase  =
    [
        { :name => 'R Objc', :execution_position => :before_compile, :script => <<-EOS
            if [ -d $PODS_TARGET_SRCROOT/Assets/*.xcassets ];then
              echo "Generate R File"
              $PODS_ROOT/MGR.objc/Robjc -p \\\"$PODS_TARGET_SRCROOT\\\" --skip-storyboards --skip-strings --skip-themes --skip-segues \#{custom_isDynamicFramework} \#{custom_isResourceBundle} --resource-bundle \#{s.name}
            fi
          EOS
        },
        { :name => 'Generate Bundle Function', :execution_position => :before_compile, :script => <<-EOS
            result=`cat ${PODS_TARGET_SRCROOT}/R\#{s.name}.h | grep '\#{s.name}Bundle'`
            if [ -z "$result" ]; then
                echo 'Write Bundle Function'
                echo '\#{custom_bundle_header}' >> $PODS_TARGET_SRCROOT/R\#{s.name}.h
                echo '\#{custom_bundle_imp}' >> $PODS_TARGET_SRCROOT/R\#{s.name}.m
            fi
            EOS
        },
        { :name => 'Clang-format', :execution_position => :before_compile, :script => <<-EOS
            clang_format=$PODS_ROOT/clang-format-bin/clang-format
            run_clangformat() {
                local filename="${1}"
                cd $SRCROOT/../
                if [ ! -f "$filename" ]; then
                return
                fi
                FILE_ALIAS='file'

                if [[ "${filename##*.}" == "m" || "${filename##*.}" == "h" || "${filename##*.}" == "mm" || "${filename##*.}" == "hpp" || "${filename##*.}" == "cpp" || "${filename##*.}" == "cc" ]]; then
                $clang_format -i -style=$FILE_ALIAS "$SRCROOT/../$filename"
                fi
            }

            cd $SRCROOT/../
            touch .gitignore
            git ls-files -om --exclude-from=.gitignore | grep "\#{s.name}/Classes/" | while read filename; do run_clangformat "${filename}"; done
            git diff --cached --name-only | grep "\#{s.name}/Classes/" | while read filename; do run_clangformat "${filename}"; done
                      EOS
        },
        { :name => 'SwiftFormat', :execution_position => :before_compile, :script => <<-EOS
            SWIFT_FORMAT="${PODS_ROOT}/SwiftFormat/CommandLineTool/swiftformat"
            run_swiftformat() {
                local filename="${1}"
                cd $SRCROOT/../
                if [ ! -f "$filename" ]; then
                return
                fi

    if [[ "${filename##*.}" == "swift" ]]; then
    ${SWIFT_FORMAT} --disable 'redundantSelf' "${filename}" --decimalgrouping ignore --binarygrouping ignore --decimalgrouping ignore --octalgrouping ignore --indent 2
                fi
            }

            cd $SRCROOT/../
            touch .gitignore
            git ls-files -om --exclude-from=.gitignore | grep "\#{s.name}/Classes/" | while read filename; do run_swiftformat "${filename}"; done
            git diff --cached --name-only | grep "\#{s.name}/Classes/" | while read filename; do run_swiftformat "${filename}"; done
                      EOS
        },
        { :name => 'SwiftLint', :execution_position => :before_compile, :script => <<-EOS
SWIFT_LINT="${PODS_ROOT}/SwiftLint/swiftlint"
run_swiftlint() {
    local filename="${1}"
    echo $filename
    cd $SRCROOT/../
    if [ ! -f "$filename" ]; then
    return
    fi

    if [[ "${filename##*.}" == "swift" ]]; then
    ${SWIFT_LINT} autocorrect --path "${filename}"
    ${SWIFT_LINT} lint --path "${filename}"
    fi
}


cd $SRCROOT/../
touch .gitignore
git ls-files -om --exclude-from=.gitignore | grep "\#{s.name}/Classes/" | while read filename; do run_swiftlint "${filename}"; done
git diff --cached --name-only | grep "\#{s.name}/Classes/" | while read filename; do run_swiftlint "${filename}"; done
                      EOS
        },
    ]

    s.dependency "MGR.objc"
    s.dependency "clang-format-bin"
    s.dependency "SwiftFormat/CLI"
    s.dependency "SwiftLint"

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




