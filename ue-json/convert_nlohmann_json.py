import re
import sys
import os

# Function to extract namespace and struct definitions from the original header file
def extract_namespace_and_structs(header_content):
    # Search for the first namespace that is not "nlohmann"
    namespace_match = re.search(r'namespace\s+((?!nlohmann)\w+)\s*{', header_content)
    namespace = None
    if namespace_match:
        potential_namespace = namespace_match.group(1)
        if potential_namespace != "nlohmann":
            namespace = potential_namespace

    structs = re.findall(r'struct\s+\w+\s*{[^}]*};', header_content)

    return namespace, structs

# Function to generate RspFwd.hpp content
def generate_rspfwd_hpp(namespace, struct_definitions):
    hpp_content = f"#pragma once\n#include <optional>\n#include <string>\n#include <vector>\n#include <cstdint>\n\n"
    hpp_content += f"namespace {namespace} {{\n"

    for struct in struct_definitions:
        hpp_content += f"{struct}\n"

    hpp_content += f"""
}} // namespace {namespace}

namespace {namespace} {{
    template<class T>
    T parse(const std::string& jsonString);

    template<class T>
    std::string dump(const T& obj);
}} // namespace {namespace}
"""

    return hpp_content

# Function to generate RspFwd.cpp content
def generate_rspfwd_cpp(namespace, original_content, struct_names):
    # Remove struct definitions from the original content
    for struct_name in struct_names:
        original_content = re.sub(rf'\s*struct\s+{struct_name}\s*{{[^}}]*}};', '', original_content)

    # Remove `#pragma once` from the original content
    original_content = re.sub(r'#pragma once\n', '', original_content)

    cpp_content = f'#include "{input_file_name}Fwd.hpp"\n\n'
    cpp_content += original_content.strip()

    cpp_content += f'\n\nnamespace {namespace} {{\n'
    cpp_content += f"""
template<class T>
T parse(const std::string& jsonString)
{{
    return nlohmann::json::parse(jsonString).get<T>();
}}

template<class T>
std::string dump(const T& obj)
{{
    nlohmann::json jsonObj = obj;
    return jsonObj.dump();
}}
    """

    cpp_content += f'\n\n'

    for struct_name in struct_names:
        cpp_content += f'template {struct_name} parse<{struct_name}>(const std::string& jsonString);\n'
        cpp_content += f'template std::string dump(const {struct_name}& obj);\n'

    cpp_content += f'}} // namespace {namespace}\n'

    return cpp_content

# Main execution
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <input_file> [output_dir]")
        sys.exit(1)

    input_file_path = sys.argv[1]
    input_file_name, _ = os.path.splitext(os.path.basename(input_file_path))
    output_dir = sys.argv[2] if len(sys.argv) == 3 else os.path.dirname(input_file_path)

    output_header_name = os.path.join(output_dir, f"{input_file_name}Fwd.hpp")
    output_cpp_name = os.path.join(output_dir, f"{input_file_name}Fwd.cpp")

    # Read the original header content
    with open(input_file_path, "r") as file:
        header_content = file.read()

    # Extract namespace and struct definitions
    namespace, struct_definitions = extract_namespace_and_structs(header_content)

    # Ensure that a valid namespace was found
    if namespace:
        # Generate header file content
        hpp_content = generate_rspfwd_hpp(namespace, struct_definitions)
        with open(output_header_name, "w") as file:
            file.write(hpp_content)

        # Extract struct names for template instantiation
        struct_names = [re.search(r'struct\s+(\w+)', struct).group(1) for struct in struct_definitions]

        # Generate cpp file content
        cpp_content = generate_rspfwd_cpp(namespace, header_content, struct_names)
        with open(output_cpp_name, "w") as file:
            file.write(cpp_content)

    else:
        print("No valid namespace found.")
