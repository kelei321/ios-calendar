# CalendarMVP

SwiftUI 原生 iOS 17+ 日历 MVP，支持本地日程、SwiftData 持久化、中国节假日/调休标记、母亲节和父亲节。

## 功能

- 月、周、日视图
- 本地日程增删改查
- 标题、地点、备注搜索
- 本地通知提醒
- 内置 2025-2026 中国官方节假日和补班日
- 内置常用传统节日、母亲节、父亲节

## 开发说明

当前工作区在 Windows 上生成，无法使用 `xcodebuild` 做真实编译验证。请在 macOS 上用 Xcode 打开 `CalendarMVP.xcodeproj`，选择 iOS 17+ 模拟器运行并执行测试。

## Windows 上如何测试

- 真实 iOS 编译/模拟器测试需要 macOS + Xcode。
- Windows 上可以直接打开 `WebPreview/index.html`，预览月视图、节假日、休/班标记、日程详情和搜索交互。
- 推送到 GitHub 后，`.github/workflows/ios.yml` 会在 macOS runner 上执行 Xcode 测试。
