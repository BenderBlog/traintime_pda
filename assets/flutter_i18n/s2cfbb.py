import yaml
import json
import pypinyin
from collections import OrderedDict
from copy import deepcopy
from random import randint
import re

table_change_alphabet = {
    "l": 1,
    "o": 0,
    "a": 4,
    "e": 3,
    "t": 7,
    "i": 1,
    "g": 9,
    "q": 9,
    "s": 5,
}

abstract_table = {
    'wu': ['🈚', '⑤'],
    'fei': ['💴'],
    'da': ['🐘'],
    'kai': ['🔓'],
    'hui': ['🩶'],
    'yi': ['①', 'Ⅰ', '🥻', '➖'],
    'er': ['②', 'Ⅱ', '👂🏻'],
    'san': ['③', 'Ⅲ', '🌂', '🥪', '☘', '📐'],
    'si': ['④', 'Ⅳ', '似', '☠️'],
    'wu': ['⑤', 'Ⅴ', '🕺🏻'],
    'liu': ['⑥', 'Ⅵ'],
    'qi': ['⑦', 'Ⅶ', '🚴🏿'],
    'ba': ['⑧', 'Ⅷ', '👨🏻'],
    'jiu': ['⑨', 'Ⅸ', '🍷'],
    'shi': ['⑩', 'Ⅹ', '🪨', '💩'],
    'zhi': ['🈯', '☞', '🧻', '📃'],
    'chou': ['🚬'],
    'xiang': ['🐘'],
    'biao': ['⌚'],
    'de': ['🉐'],
    'niu': ['🐂'],
    'hu': ['🐅'],
    'ma': ['🐎'],
    'yang': ['🐏', '☀'],
    'hou': ['🐒'],
    'mo': ['👺'],
    'ji': ['🐔', '✈️'],
    'gou': ['🐕', '🐶'],
    'suan': ['🍋'],
    'ku': ['🆒', '😭', '🥲'],
    'le': ['🤣'],
    'she': ['🐍'],
    'zhu': ['🐖'],
    'long': ['🐉'],
    'zhong': ['🀄️'],
    'hua': ['🌸'],
    'fa:': ['🇫🇷'],
    'fang': ['◻️'],
    'ran': ['🔥'],
    'shu': ['📕', '🐀', '📖'],
    'ru': ['🧴'],
    'ben': ['📕', '📖'],
    'jiao': ['🦵', '🔈', '🎺', *['🗣'] * 3],
    'chong': ['🏄‍'],
    'bi': ['🖊'],
    'gao': ['⛏'],
    'suo': ['🔒'],
    'jian': ['➖'],
    'jing': ['🚨'],
    'dao': ['🔪'],
    'guai': ['🧞'],
    'shuo': ['🗣'],
    'deng': ['🟰', '🛋️'],
    'chu': ['÷', '➗️'],
    'cheng': ['×', '❌', '✖'],
    'jia': ['＋', '➕', '⛽', '🏠'],
    'wu': ['🈚️'],
    'you': ['👉', '🈶'],
    'ce': ['🚻'],
    'cao': ['🌿'],
    'lang': ['🌊', '🐺'],
    'tu': ['🐇'],
    'cai': ['👎', '🥬'],
    'men': ['🚪'],
    'ju': ['🍊'],
    'nao': ['🧠'],
    'bu': ['⛔', '🚫', '🖐🏻'],
    'guo': ['🍎'],
    'he': ['⚛️'],
    'sheng': ['🔊'],
    'xian': ['🧵'],
    'mu': ['🤱🏻'],
    'ma': ['🤱🏻'],
    'shou': ['🖐🏻', '📻'],
    'zai': ['♻️'],
    'shang': ['👆'],
    'xia': ['👇'],
    'zuo': ['👈'],
    'xiao': ['🏫'],
    'hei': ['👨🏿'],
    'kong': ['🈳'],
    'guan': ['📴'],
    'qing': ['🌤'],
    'dong': ['🕳'],
    'yao': ['💊'],
    'kan': ['👀'],
}

abstract_table_multi = {
    '啥b': '😅',
    '可可': '🍥🥹可可',
    '0xcafebabe': '☕👶🏻',
    'cafebabe': '☕👶🏻',
    '我': '👴',
    'luo': '🐕',
    '信号': '📶',
    'xkm': '🐱',
    '电脑': '💻',
    '企鹅': '🐧',
    '厕所': '🚻',
    'wc': '🚾',
    '?': '❓',
    '？': '❓',
    '豆腐': '🧈',
}

# 函数：在保留大括号内容的情况下转换字符串
def conv2a3(raw: str) -> str:
    # 查找所有大括号内容
    curly_brace_matches = re.findall(r'\{.*?\}', raw)
    
    # 大括号内容的临时占位符，使用特殊格式以避免冲突
    placeholder_template = "哈哈哈哈哈哈"
    placeholders = {f"{placeholder_template.format(i)}": match for i, match in enumerate(curly_brace_matches)}
    
    # 用占位符替换大括号内容
    for i, match in enumerate(curly_brace_matches):
        raw = raw.replace(match, placeholder_template.format(i))

    # 对不含大括号内容的字符串进行转换
    for (i, v) in abstract_table_multi.items():
        raw = raw.replace(i, v)
    pin_ = pypinyin.core.Pinyin()
    aa = list(deepcopy(raw))
    a3 = pypinyin.lazy_pinyin(aa)
    a3_copy = deepcopy(a3)
    
    for i, v in enumerate(a3):
        if v in abstract_table.keys():
            ll = abstract_table[v]  
            a3[i] = ll[randint(0, len(ll) - 1)]

    for i in range(len(a3_copy)):
        if a3_copy[i] == a3[i]:
            a3[i] = aa[i]
    
    for i in range(len(a3)):
        for j in range(len(a3[i])):
            change = randint(1919, 114514) <= 88100
            change2 = randint(0, 20) <= 10
            if change2 and change and a3[i][j].lower() == 'o':
                a3[i] = a3[i][:j] + '⭕️' + a3[i][j+1:]
                continue
            if change and a3[i][j].lower() in table_change_alphabet:
                a3[i] = a3[i][:j] + str(table_change_alphabet[a3[i][j].lower()]) + a3[i][1+j:]
                continue

    converted_string = "".join(a3)
    
    # 将大括号内容重新插入转换后的字符串中
    for placeholder, original in placeholders.items():
        converted_string = converted_string.replace(placeholder, original)
    
    return converted_string

# 自定义 YAML 加载器，以保持使用 OrderedDict 的顺序
class OrderedLoader(yaml.SafeLoader):
    pass

def construct_mapping(loader, node):
    loader.flatten_mapping(node)
    return OrderedDict(loader.construct_pairs(node))

OrderedLoader.add_constructor(
    yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
    construct_mapping
)

# 自定义 YAML 转储器，以在写入时保留 OrderedDict
class OrderedDumper(yaml.SafeDumper):
    pass

def dict_representer(dumper, data):
    return dumper.represent_dict(data.items())

OrderedDumper.add_representer(OrderedDict, dict_representer)

# 函数：在保持顺序的情况下修改 YAML 元数据值
def modify_yaml(filename: str):
    # 以 OrderedDict 的形式加载 YAML 文件以保留顺序
    with open(filename, 'r', encoding='utf-8') as file:
        yaml_data = yaml.load(file, Loader=OrderedLoader)

    # 递归修改字典中的值
    def recursive_modify(data):
        if isinstance(data, dict):
            for key, value in data.items():
                data[key] = recursive_modify(value)
        elif isinstance(data, list):
            data = [recursive_modify(item) for item in data]
        elif isinstance(data, str):
            # 仅对字符串值应用 conv2a3 转换
            data = conv2a3(data)
        return data

    modified_data = recursive_modify(yaml_data)

    # 将修改后的数据保存在新的YAML文件，保持原本的顺序
    with open(f"modified_{filename}", 'w', encoding='utf-8') as file:
        json.dump(modified_data, file)
        #yaml.dump(modified_data, file, allow_unicode=True, Dumper=OrderedDumper)

    print(f"Modified YAML saved as 'modified_{filename}'")

if __name__ == '__main__':
    filename = input("Enter the YAML file name: ")
    modify_yaml(filename)