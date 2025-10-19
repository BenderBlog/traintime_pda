## 简介

这个文件夹中主要存放的是 PDA 物理实验分数识别程序的图像匹配原文件。目前已经有 11 个可以被准确识别的分数，如果你有新的分数信息，欢迎提出 PR 提交！

## 识别原理

我们推测成绩图像是不变的，所以仅需要计算图片文件的哈希值即可。

(BenderBlog 补充) 本人认为，如果图片连文件名都不变，那将来直接按照文件名来匹配吧。

## 已经收集到的分数数据

| 成绩 | 文件名 | 哈希值(MD5) |
|-------|-------|-------|
| 已上传 | __CF0429053BE1624B0AE557A2 | 536e85894cd73e97799457238821a0d4 |
| 未上传 | __2B0A2898A8636392D36D4FD3 | 96df69201f754f554aded7076618b049 |
| 0     |       | 1e132501c0b8f55fda1fa159119ecb79 |
| 5.5   | __C4006511E511A3F2A90F5138 | 4339cc32f36c073cb486cd9554898783 |
| 6     | __C94F2959A8B2781871FE4AE2 | a99492ec5e00e65229f730c2cfc3c815 |
| 6.5   | __4B66616AEB2EA46E369250FF | dc50f78996082bf95c643dab7e41da7b |
| 7     |       | e5927c5213985aceb2b5c8c0b2dfe07c |
| 7.5   |       | c15a054a7a1dd4d22e320379e877564c |
| 8     | __44F829DB8884773BCD794AF3 | 9b26762e2e993815e71ac82a8d374506 |
| 8.5   | __C70F61ECCB00A391920D5110 | 72e5547c6b39a4b490ea4a0e20999f73 |
| 9     | __98EA29D6183C77F5B12346BF | b0c862acc5ec5e408e8091d11b5c91c1 |
| 9.5   |       | 54012b7cb53f7600b42afd59c9d1f287 |

## 尚未得到的分数数据

| 成绩 | 
|-------|
| 0.5   |
| 1     |
| 1.5   |
| 2     |
| 2.5   |
| 3     |
| 3.5   |
| 4     |
| 4.5   |
| 5     |

### 文件夹结构

~~~plaintext
experiment_score/
├── calculate_md5.py        # 预计算哈希值
├── calculate_md5.dart      # 预计算哈希值
├── README.md               # README 文件
├── cache                   # 预计算数据，用于提升计算速度（本质是JSON）
└── scores/                 # 图片信息原数据
~~~

### 如何生成预计算文件

~~~bash
dart run ./calculate_fnv1a.dart scores <target_file_name>
~~~

~~~bash
python3 ./calculate_fnv1a.py scores <target_file_name>
~~~
