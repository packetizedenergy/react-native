load("@fbsource//tools/build_defs:default_platform_defs.bzl", "IOS", "MACOSX")
load("@fbsource//tools/build_defs:fb_native_wrapper.bzl", "fb_native")
load("@fbsource//tools/build_defs/apple:flag_defs.bzl", "get_debug_preprocessor_flags")
load(
    "//tools/build_defs/oss:rn_defs.bzl",
    "ANDROID",
    "APPLE",
    "CXX",
    "YOGA_CXX_TARGET",
    "fb_xplat_cxx_test",
    "get_apple_compiler_flags",
    "get_apple_inspector_flags",
    "react_native_dep",
    "react_native_target",
    "react_native_xplat_target",
    "rn_android_library",
    "rn_xplat_cxx_library",
)

def rn_codegen(
        name = "",
        schema_target = ""):
    generate_fixtures_rule_name = "generate_fixtures-{}".format(name)
    generate_component_descriptor_h_name = "generate_component_descriptor_h-{}".format(name)
    generate_event_emitter_cpp_name = "generate_event_emitter_cpp-{}".format(name)
    generate_event_emitter_h_name = "generate_event_emitter_h-{}".format(name)
    generate_props_cpp_name = "generate_props_cpp-{}".format(name)
    generate_props_h_name = "generated_props_h-{}".format(name)
    generate_tests_cpp_name = "generate_tests_cpp-{}".format(name)
    generate_shadow_node_cpp_name = "generated_shadow_node_cpp-{}".format(name)
    generate_shadow_node_h_name = "generated_shadow_node_h-{}".format(name)
    generate_module_h_name = "generate_module_h-{}".format(name)
    generate_module_cpp_name = "generate_module_cpp-{}".format(name)
    generate_module_hobjcpp_name = "generate_module_hobjcpp-{}".format(name)
    generate_module_mm_name = "generate_module_mm-{}".format(name)
    copy_generated_java_files = "copy_generated_java_files-{}".format(name)
    zip_generated_java_files = "zip_generated_java_files-{}".format(name)

    fb_native.genrule(
        name = generate_fixtures_rule_name,
        srcs = native.glob(["src/generators/**/*.js"]),
        cmd = "$(exe fbsource//xplat/js/react-native-github/packages/react-native-codegen:rn_codegen) $(location {}) {} $OUT".format(schema_target, name),
        out = "codegenfiles-{}".format(name),
    )

    fb_native.genrule(
        name = generate_component_descriptor_h_name,
        cmd = "cp $(location :{})/ComponentDescriptors.h $OUT".format(generate_fixtures_rule_name),
        out = "ComponentDescriptors.h",
    )

    fb_native.genrule(
        name = generate_event_emitter_cpp_name,
        cmd = "cp $(location :{})/EventEmitters.cpp $OUT".format(generate_fixtures_rule_name),
        out = "EventEmitters.cpp",
    )

    fb_native.genrule(
        name = generate_event_emitter_h_name,
        cmd = "cp $(location :{})/EventEmitters.h $OUT".format(generate_fixtures_rule_name),
        out = "EventEmitters.h",
    )

    fb_native.genrule(
        name = generate_props_cpp_name,
        cmd = "cp $(location :{})/Props.cpp $OUT".format(generate_fixtures_rule_name),
        out = "Props.cpp",
    )

    fb_native.genrule(
        name = generate_tests_cpp_name,
        cmd = "cp $(location :{})/Tests.cpp $OUT".format(generate_fixtures_rule_name),
        out = "Tests.cpp",
    )

    fb_native.genrule(
        name = generate_props_h_name,
        cmd = "cp $(location :{})/Props.h $OUT".format(generate_fixtures_rule_name),
        out = "Props.h",
    )

    fb_native.genrule(
        name = copy_generated_java_files,
        cmd = "mkdir $OUT && find $(location :{}) -name '*.java' -exec cp {{}} $OUT \;".format(generate_fixtures_rule_name),
        out = "java",
    )

    fb_native.zip_file(
        name = zip_generated_java_files,
        srcs = [":{}".format(copy_generated_java_files)],
        out = "{}.src.zip".format(zip_generated_java_files),
        visibility = ["PUBLIC"],
    )

    fb_native.genrule(
        name = generate_shadow_node_cpp_name,
        cmd = "cp $(location :{})/ShadowNodes.cpp $OUT".format(generate_fixtures_rule_name),
        out = "ShadowNodes.cpp",
    )

    fb_native.genrule(
        name = generate_shadow_node_h_name,
        cmd = "cp $(location :{})/ShadowNodes.h $OUT".format(generate_fixtures_rule_name),
        out = "ShadowNodes.h",
    )

    fb_native.genrule(
        name = generate_module_h_name,
        cmd = "cp $(location :{})/NativeModules.h $OUT".format(generate_fixtures_rule_name),
        out = "NativeModules.h",
    )

    fb_native.genrule(
        name = generate_module_cpp_name,
        cmd = "cp $(location :{})/NativeModules.cpp $OUT".format(generate_fixtures_rule_name),
        out = "NativeModules.cpp",
    )

    fb_native.genrule(
        name = generate_module_hobjcpp_name,
        cmd = "cp $(location :{})/RCTNativeModules.h $OUT".format(generate_fixtures_rule_name),
        out = "RCTNativeModules.h",
    )

    fb_native.genrule(
        name = generate_module_mm_name,
        cmd = "cp $(location :{})/RCTNativeModules.mm $OUT".format(generate_fixtures_rule_name),
        out = "RCTNativeModules.mm",
    )

    # libs
    rn_xplat_cxx_library(
        name = "generated_components-{}".format(name),
        tests = [":generated_tests-{}".format(name)],
        srcs = [
            ":{}".format(generate_event_emitter_cpp_name),
            ":{}".format(generate_props_cpp_name),
            ":{}".format(generate_shadow_node_cpp_name),
        ],
        headers = [
            ":{}".format(generate_component_descriptor_h_name),
            ":{}".format(generate_event_emitter_h_name),
            ":{}".format(generate_props_h_name),
            ":{}".format(generate_shadow_node_h_name),
        ],
        exported_headers = {
            "ComponentDescriptors.h": ":{}".format(generate_component_descriptor_h_name),
            "EventEmitters.h": ":{}".format(generate_event_emitter_h_name),
            "Props.h": ":{}".format(generate_props_h_name),
            "ShadowNodes.h": ":{}".format(generate_shadow_node_h_name),
        },
        header_namespace = "react/components/{}".format(name),
        compiler_flags = [
            "-fexceptions",
            "-frtti",
            "-std=c++14",
            "-Wall",
        ],
        fbobjc_compiler_flags = get_apple_compiler_flags(),
        fbobjc_preprocessor_flags = get_debug_preprocessor_flags() + get_apple_inspector_flags(),
        platforms = (ANDROID, APPLE, CXX),
        preprocessor_flags = [
            "-DLOG_TAG=\"ReactNative\"",
            "-DWITH_FBSYSTRACE=1",
        ],
        visibility = ["PUBLIC"],
        deps = [
            "fbsource//xplat/fbsystrace:fbsystrace",
            "fbsource//xplat/folly:headers_only",
            "fbsource//xplat/folly:memory",
            "fbsource//xplat/folly:molly",
            "fbsource//xplat/third-party/glog:glog",
            YOGA_CXX_TARGET,
            react_native_xplat_target("fabric/debug:debug"),
            react_native_xplat_target("fabric/core:core"),
            react_native_xplat_target("fabric/graphics:graphics"),
            react_native_xplat_target("fabric/components/image:image"),
            react_native_xplat_target("fabric/imagemanager:imagemanager"),
            react_native_xplat_target("fabric/components/view:view"),
        ],
    )

    rn_xplat_cxx_library(
        name = "generated_modules-{}".format(name),
        tests = [":generated_tests-{}".format(name)],
        ios_srcs = [
            ":{}".format(generate_module_mm_name),
        ],
        srcs = [
            ":{}".format(generate_module_cpp_name),
        ],
        headers = [
            ":{}".format(generate_module_h_name),
        ],
        ios_headers = [
            ":{}".format(generate_module_hobjcpp_name),
        ],
        exported_headers = {
            "NativeModules.cpp": ":{}".format(generate_module_cpp_name),
            "NativeModules.h": ":{}".format(generate_module_h_name),
        },
        ios_exported_headers = {
            "RCTNativeModules.h": ":{}".format(generate_module_hobjcpp_name),
            "RCTNativeModules.mm": ":{}".format(generate_module_mm_name),
        },
        header_namespace = "react/modules/{}".format(name),
        compiler_flags = [
            "-fexceptions",
            "-frtti",
            "-std=c++14",
            "-Wall",
        ],
        fbobjc_compiler_flags = get_apple_compiler_flags(),
        fbobjc_preprocessor_flags = get_debug_preprocessor_flags() + get_apple_inspector_flags(),
        platforms = (ANDROID, APPLE),
        preprocessor_flags = [
            "-DLOG_TAG=\"ReactNative\"",
            "-DWITH_FBSYSTRACE=1",
        ],
        visibility = ["PUBLIC"],
        exported_deps = [
            react_native_xplat_target("turbomodule/core:core"),
        ],
    )

    rn_android_library(
        name = "generated_components_java-{}".format(name),
        srcs = [
            ":{}".format(zip_generated_java_files),
        ],
        visibility = ["PUBLIC"],
        deps = [
            react_native_dep("third-party/android/androidx:annotation"),
            react_native_target("java/com/facebook/react/bridge:bridge"),
        ],
    )

    # Tests
    fb_xplat_cxx_test(
        name = "generated_tests-{}".format(name),
        srcs = [
            ":{}".format(generate_tests_cpp_name),
        ],
        compiler_flags = [
            "-fexceptions",
            "-frtti",
            "-std=c++14",
            "-Wall",
        ],
        contacts = ["oncall+react_native@xmail.facebook.com"],
        apple_sdks = (IOS, MACOSX),
        platforms = (ANDROID, APPLE, CXX),
        deps = [
            "fbsource//xplat/third-party/gmock:gtest",
            ":generated_components-{}".format(name),
        ],
    )
