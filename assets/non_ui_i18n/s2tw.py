import opencc
import yaml
from collections import OrderedDict

converter = opencc.OpenCC('s2tw.json')

# 自定义 Loader，使用 OrderedDict 读取 YAML 文件
class OrderedLoader(yaml.SafeLoader):
    pass

def construct_mapping(loader, node):
    loader.flatten_mapping(node)
    return OrderedDict(loader.construct_pairs(node))

OrderedLoader.add_constructor(
    yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
    construct_mapping
)

# 读取 YAML 文件并保持顺序
with open('zh_CN.yaml', 'r', encoding='utf-8') as file:
    yaml_content = yaml.load(file, Loader=OrderedLoader)

# 遍历 YAML 内容并转换
def convert_yaml(content):
    if isinstance(content, dict):
        return OrderedDict((key, convert_yaml(value)) for key, value in content.items())
    elif isinstance(content, list):
        return [convert_yaml(item) for item in content]
    elif isinstance(content, str):
        return converter.convert(content)  # 转换字符串中的汉字
    else:
        return content

# 对 YAML 文件的内容进行转换
converted_content = convert_yaml(yaml_content)

# 自定义 Dumper，确保输出时保持顺序
class OrderedDumper(yaml.SafeDumper):
    pass

def dict_representer(dumper, data):
    return dumper.represent_dict(data.items())

OrderedDumper.add_representer(OrderedDict, dict_representer)

# 将转换后的内容写入新的 YAML 文件，并保持顺序
with open('zh_TW.yaml', 'w', encoding='utf-8') as file:
    file.write("# Translated using OpenCC s2twp Dictionary, script by Hancl777\n")
    yaml.dump(converted_content, file, Dumper=OrderedDumper, allow_unicode=True)

print("YAML 文件中的中文已经转换并保持了顺序！")
