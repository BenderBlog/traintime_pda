# i18n 迁移说明

## 方案变更

项目 i18n 方案已从 `flutter_i18n` 迁移至 `flutter_localizations` (intl)，但 **开发流程保持不变**。

## 核心原则

**本文件夹下的 YAML 文件是 i18n 的唯一数据源。**

- **禁止直接修改** `lib/l10n/` 目录下的 `.arb` 文件，它们由脚本自动生成，手动修改会被覆盖
- **禁止直接修改** `lib/generated/` 目录下的 Dart 文件，它们由 `flutter gen-l10n` 自动生成

## 修改 i18n 的正确流程

1. **编辑 YAML** — 修改 `assets/flutter_i18n/` 下对应的 `.yaml` 文件（`en_US.yaml` / `zh_CN.yaml` / `zh_TW.yaml`）
2. **运行迁移脚本** — 将 YAML 转换为 ARB：
   ```bash
   python assets/flutter_i18n/yaml_to_arb.py
   ```
3. **生成 Dart 代码** — 从 ARB 生成 Dart 国际化类：
   ```bash
   flutter gen-l10n
   ```

每次修改 YAML 文件后，**必须**依次执行上述两步，否则修改不会生效。

## 迁移脚本说明

`yaml_to_arb.py` 负责将 YAML 格式的翻译文件转换为 Flutter intl 所需的 ARB 格式：

| YAML 文件 | 输出 ARB 文件 |
|---|---|
| `assets/flutter_i18n/en_US.yaml` | `lib/l10n/intl_en.arb` |
| `assets/flutter_i18n/zh_CN.yaml` | `lib/l10n/intl_zh.arb` |
| `assets/flutter_i18n/zh_TW.yaml` | `lib/l10n/intl_zh_TW.arb` |

转换规则：

- YAML 嵌套结构会扁平化为点分路径，再转换为驼峰 key
- 字符串中的 `{param}` 占位符会自动提取，生成对应的 `@key` 元数据声明
- 类型默认为 `String`，无需手动声明
- 值为 `null` 的 key 会被跳过（不会出现在 ARB 中）
