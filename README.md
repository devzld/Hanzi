# 汉字卡 iOS（SwiftUI）

零基础 1-200 识字卡应用的原生 iOS 版本：课程列表、田字格大字卡、发音、收藏、卡片制作。

## 用 CI 编译（推荐，无需 Mac）

推送到 `main` 分支会自动在 macOS 云机器（`macos-15`）上编译，产物在 Actions → 最新一次运行 → Artifacts：

- `HanZiCard-simulator.zip` —— 模拟器版 `.app`
- `HanZiCard-unsigned.ipa` —— 真机版（**未签名**，需自行用证书重签后才能安装）

也可以在 Actions 页面手动 `Run workflow`。

> 注：`macos-14` 已于 2026-11-02 被 GitHub 退役，工作流使用 `macos-15`。
> 编译失败时，CI 会把 `xcodebuild` 的错误摘要提交到 `ci-logs/build-errors.md`，方便没有 Xcode 的环境排查。

## 本地 Mac 上运行

```bash
brew install xcodegen
xcodegen generate          # 依据 project.yml 生成 HanZiCard.xcodeproj
open HanZiCard.xcodeproj   # 选择 iPhone 模拟器，Cmd+R
```

## 工程结构

```
project.yml                      # XcodeGen 工程定义（bundle id / 部署版本 / Info.plist 键）
HanZiCard/
├── App/       HanZiCardApp.swift · Theme.swift
├── Models/    Lesson.swift
├── Data/      HanziData.swift（200 字字库 + 拼音表）
├── Services/  AppStore.swift（本地持久化）· SpeechService.swift（AVSpeechSynthesizer 朗读）
└── Views/     MainTabView · HomeView · LessonRow · Tianzige · CardMakerView · SettingsView
```

## 功能

- 首页：40 课 × 5 字，「一」= 字 1-100、「二」= 字 101-200；田字格（绿色边框 + 十字虚线 + 楷体）、「上次学习」角标、乱序、朗读
- 卡片：输入词语生成大字卡，点左右两侧翻页，收藏、朗读、保存到本地卡片集
- 设置：翻页自动发音、语速、清除学习记录、收藏/卡片统计
