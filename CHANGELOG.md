# Changelog

本專案的重要變更記錄於此。

## 2026-07-21

### 現代化財務體驗

- 修正啟動時總覽延遲載入；App 現在直接顯示財務總覽，再由使用者切換至交易明細。
- 將舊式圓餅圖練習改造為以現金流與預算決策為核心的產品。
- 金額由 `Double` 改為 `Decimal`，並統一使用新台幣格式。
- 新增生活化收支分類、交易搜尋、編輯、滑動刪除與備註。
- 新增分類月預算、預算進度、80% 警示與超支狀態。
- 新增月度收入／支出／可用金額、支出分布及自動財務洞察。
- 新增一鍵展示資料與安全的全部清除流程。
- UI 改為程式化 Auto Layout 與 navigation-based tab 結構。
- 新增 `PieDayTests` target，涵蓋計算、月份隔離、CRUD、超支與持久化。
- 最低支援版本調整為 iOS 16。

### 專案正式命名為 PieDay

- 將本機資料夾與 GitHub repository 由 `Demo_018` 改名為 `PieDay`。
- 統一 Xcode project、target、scheme、source directory 與 app product 名稱。
- 將 bundle identifier 更新為 `ClcStudio.PieDay`。
- 更新 Storyboard module、文件路徑與 README，移除舊專案名稱。
- GitHub repository 搬移至 <https://github.com/cowton0627/PieDay>。

對應提交：`61b56df`（將專案重新命名為 PieDay）
