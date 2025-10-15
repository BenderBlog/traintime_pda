## 简介

这个文件夹中主要存放的是 PDA 物理实验分数识别程序的图像匹配原文件。目前已经有 10 个可以被准确识别的分数，如果你有新的分数信息，欢迎提出 PR 提交！！

| 已有的分数 | 没有的分数 |
|-------|-------|
| 已上传   | 0.5   |
| 未上传   | 1     |
| 0     | 1.5   |
| 6     | 2     |
| 6.5   | 2.5   |
| 7     | 3     |
| 7.5   | 3.5   |
| 8     | 4     |
| 8.5   | 4.5   |
| 9     | 5     |
| 9.5   | 5.5   |
| -     | 10    |

--- 

### 文件夹结构

~~~plaintext
experiment_score/
├── calculate_hashes.dart   # 预计算 MD5 值
├── README.md               # README 文件
├── cache                   # 预计算数据，用于提升计算速度（本质是JSON）
└── scores/                 # 图片信息原数据
~~~

### 如何生成预计算文件

~~~dart
dart run .\calculate_md5.dart scores <target_file_name>
~~~