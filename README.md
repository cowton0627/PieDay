<p align="center">
  <img src="docs/icon-1024.png" width="120" alt="PieDay icon" />
</p>

# PieDay

PieDay 是一個以「快速記帳、主動預算、看得懂的現金流」為核心的 UIKit 個人財務 App。它不只記錄流水帳，也會比較當月收入、支出與分類預算，提醒使用者即將超支或已經超支。

## 主要功能

- 以 `Decimal` 儲存金額，避免財務計算的浮點誤差
- 收入／支出快速輸入，支援常用生活分類與備註
- 本月交易依日期排列，支援搜尋、編輯與滑動刪除
- 分類月預算、使用進度及 80%／超支視覺警示
- 收入、支出、可用金額與支出去向集中在單一 dashboard
- 支援月份切換與最近六個月收支趨勢比較
- 支援 VoiceOver 完整摘要與 Dynamic Type 特大字級自適應版面
- 根據現金流、最大支出與預算使用率產生本月洞察
- 一鍵載入完整展示資料，方便作品展示與 UI 驗收
- JSON + `UserDefaults` 本機持久化，不蒐集或上傳財務資料

## 產品設計依據

這次改版參考現代記帳產品的共通做法，但刻意維持適合小型作品的清楚範圍：

- [MOZE](https://moze.app/)：低摩擦記帳、分類、帳戶與預算規劃
- [CWMoney](https://money.cmoney.tw/cwmoney/index)：分類預算進度與收支分析
- [YNAB](https://www.ynab.com/features)：以可用金額、目標與預算決策為核心

PieDay 不宣稱具備銀行同步、發票串接或雲端帳戶；目前專注在可完整展示、可離線運作且容易測試的手動記帳流程。

## 架構

- `Transaction`：以 `Decimal` 表示金額的 Codable domain model
- `TransactionCategory`：收入／支出分類、SF Symbols 與語意色彩
- `TransactionStore`：交易、月度彙總、分類預算、持久化與展示資料
- `TransactionViewController`：搜尋、快速輸入、編輯與刪除交易
- `ViewController`：月度現金流、預算進度、支出圖表與洞察
- `PieChartView` / `DonutChartView`：無第三方套件的 Core Animation 圖表

畫面由程式化 Auto Layout 建構，透過 `TransactionStore.didChangeNotification` 保持分頁同步；資料層可注入獨立 `UserDefaults`，讓測試不污染正式資料。

## 測試

`PieDayTests` 涵蓋：

- Decimal 收支與餘額計算
- 月份資料隔離
- 穩定 ID 的更新與刪除
- 超支比例
- 交易與預算持久化

`PieDayUITests` 涵蓋：

- 空狀態新增交易流程
- 總覽 VoiceOver 語意與月份切換
- Accessibility XXXL 字級下的核心內容可達性

```sh
xcodebuild test -project PieDay.xcodeproj -scheme PieDay \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

需求：Xcode 16 或更新版本、iOS 16+。

## 展示方式

啟動後進入「交易」，點右上角 `⋯` →「載入展示資料」，再切換到「總覽」即可看到完整預算、消費分布與財務洞察。

## 後續方向

- 可自訂分類與多帳戶
- 週期性收支與即將到期帳單
- CSV 匯入／匯出與 iCloud 同步
- 電子發票整合：先支援 QR Code／CSV 匯入，再評估申請財政部電子發票 API 自動同步載具發票

## 變更紀錄

重要版本與專案調整請見 [CHANGELOG.md](CHANGELOG.md)。
