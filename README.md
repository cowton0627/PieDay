<p align="center">
  <img src="docs/icon-1024.png" width="120" alt="PieDay icon" />
</p>

# PieDay — 簡易記帳軟體

於「交易」頁逐筆新增收入／支出並指定分類，資料即時寫入 `TransactionStore` 並持久化。切到「預算」頁可看到各分類金額與佔薪水百分比的即時計算；按下「圓餅圖」或「環狀圖」呈現比例 — 圓餅圖每片以拉線標出分類與百分比，環狀圖中央顯示結餘金額。資料尚未足夠繪圖時彈出警示視窗。

UIKit + Swift 練習作。圓餅／環狀圖以 `UIBezierPath` 自繪，無第三方圖表套件。

## 畫面

| 交易頁 | 預算頁（summary） |
| :---: | :---: |
| ![Transaction](docs/screenshots/01-transaction.png) | ![Budget](docs/screenshots/02-budget.png) |

| 預算頁 ＋ 圓餅圖 | 預算頁 ＋ 環狀圖 |
| :---: | :---: |
| ![Pie](docs/screenshots/03-budget-pie.png) | ![Donut](docs/screenshots/04-budget-donut.png) |

## 架構

- `Transaction` / `TransactionCategory` / `TransactionType` — Model
- `TransactionStore` — 單一資料來源，UserDefaults 持久化，`NotificationCenter` 廣播變更
- `PieChartView` / `DonutChartView` — 自繪 `UIView`，自動依 bounds 自適應大小與線寬
- `TransactionViewController` — 新增／刪除交易、顯示餘額
- `ViewController`（預算 dashboard）— 依 `TransactionStore` 加總按分類顯示，並繪製圓餅／環狀圖

兩個分頁透過 `TransactionStore` 解耦，沒有互相認識；資料變動由 store 廣播給所有訂閱者。

## 變更紀錄

重要版本與專案調整請見 [CHANGELOG.md](CHANGELOG.md)。
