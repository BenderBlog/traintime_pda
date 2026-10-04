import glob
import os

import opencc
import yaml
from collections import OrderedDict

converter = opencc.OpenCC('s2tw.json')


class OrderedLoader(yaml.SafeLoader):
    pass


def construct_mapping(loader, node):
    loader.flatten_mapping(node)
    return OrderedDict(loader.construct_pairs(node))


OrderedLoader.add_constructor(
    yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
    construct_mapping
)


def convert_yaml(content):
    if isinstance(content, dict):
        return OrderedDict((key, convert_yaml(value)) for key, value in content.items())
    elif isinstance(content, list):
        return [convert_yaml(item) for item in content]
    elif isinstance(content, str):
        return converter.convert(content)
    else:
        return content


class OrderedDumper(yaml.SafeDumper):
    pass


def dict_representer(dumper, data):
    return dumper.represent_dict(data.items())


OrderedDumper.add_representer(OrderedDict, dict_representer)


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    src_dir = os.path.join(script_dir, 'zh')
    dst_dir = os.path.join(script_dir, 'zh_TW')
    os.makedirs(dst_dir, exist_ok=True)

    for src_path in sorted(glob.glob(os.path.join(src_dir, '*.yaml'))):
        filename = os.path.basename(src_path)

        with open(src_path, 'r', encoding='utf-8') as file:
            yaml_content = yaml.load(file, Loader=OrderedLoader)

        converted_content = convert_yaml(yaml_content)

        dst_path = os.path.join(dst_dir, filename)
        with open(dst_path, 'w', encoding='utf-8') as file:
            file.write("# Translated using OpenCC s2twp Dictionary, script by Hancl777 and Hazuki Keatsu\n")
            yaml.dump(converted_content, file, Dumper=OrderedDumper, allow_unicode=True)

        print(f'  [OK]    zh/{filename} → zh_TW/{filename}')

    print('简体转繁体完成！')


if __name__ == '__main__':
    main()
