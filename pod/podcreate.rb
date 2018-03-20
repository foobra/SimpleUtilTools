
pwd = ARGV[0]
pod_name = ARGV[1]

system "cd #{pwd}"
system 'mkdir', '-p', "#{pod_name}/Classes"
system 'mkdir', '-p', "#{pod_name}/Assets"
system 'touch', "#{pod_name}/#{pod_name}.podspec"

podspec_text =  <<-EOF
Pod::Spec.new do |s|
    s.name         = #{pod_name}
    s.version      = "1.0.0"
    s.homepage     = "https://www.github.com"
    s.author       = "TSG iOS"
    s.summary      = s.name
    s.source       = { :path => '.' }
    s.platform     = :ios, '9.0'
    s.framework    = "Foundation", "UIKit"
    s.requires_arc = true
    s.static_framework = true
    s.cocoapods_version = '>= 1.4.0'
    s.swift_version = '4.0'
    s.source_files = 'Classes/**/*.{h,m,mm,cpp,c,hpp,cc,swift}', 'R*.h', 'R*.m'
    # s.resources = "Assets/**/*.{bundle,json,xcassets,gif}"
    s.resource_bundles = { s.name => ['Assets/**/*.*', 'Classes/**/*.{xib,storyboard}'] }

    custom_isDynamicFramework = !s.static_framework ? "--dynamic-framework" : ""
    # FIXME 这里暂时需要自己重复申明一次
    isResourceBundle = true
    custom_isResourceBundle = isResourceBundle ? "--is-resource-bundle" : ""

    custom_pch_str = ""
    if !s.static_framework
        if isResourceBundle
            custom_pch_str = "#define \#{s.name}Bundle [NSBundle bundleWithIdentifier:@\\\"org.cocoapods.\#{s.name}\\\"]"
        else
            custom_pch_str = "#define \#{s.name}Bundle [NSBundle bundleWithIdentifier:@\\\"org.cocoapods.\#{s.name}\\\"]"
        end
    else
        if isResourceBundle
            custom_pch_str = "#define \#{s.name}Bundle [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@\\\"\#{s.name}\\\" ofType:@\\\"bundle\\\"]]"
        else
            custom_pch_str = "#define \#{s.name}Bundle [NSBundle mainBundle]"
        end
    end

    s.script_phase  =
    [
        { :name => 'R Objc', :script => "$PODS_ROOT/MGR.objc/Robjc -p \\\"$PODS_TARGET_SRCROOT\\\" --skip-storyboards --skip-strings --skip-themes --skip-segues \#{custom_isDynamicFramework} \#{custom_isResourceBundle} --resource-bundle \#{s.name}", :execution_position => :before_compile },
        { :name => 'Generate Macro', :script => "echo \\\"\#{custom_pch_str}\\\" >> $PODS_TARGET_SRCROOT/R\#{s.name}.h", :execution_position => :before_compile },
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

            #git ls-files --exclude-from=.gitignore | grep "MiGuIMP/" | while read filename; do run_clangformat "${filename}"; done
            cd $SRCROOT/../
            touch .gitignore
            git ls-files -om --exclude-from=.gitignore | grep "MGBaseUI/Classes/" | while read filename; do run_clangformat "${filename}"; done
            git diff --cached --name-only | grep "MGBaseUI/Classes/" | while read filename; do run_clangformat "${filename}"; done
                      EOS
        },
    ]

    s.dependency "MGR.objc"
    s.dependency "clang-format-bin"
end
EOF

File.write("#{pod_name}/#{pod_name}.podspec", podspec_text)




