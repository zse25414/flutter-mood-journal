# 📝 Flutter Mood Journal

一款由 Flutter + Firebase 製作的簡潔日記 App，支援「心情記錄」、「主題分類」、「AI 鼓勵語」、「圖表分析」與「Firebase 雲端同步」。

![preview](preview.png)

## ✨ 功能特色

- 📅 新增 / 編輯每日日記
- 😊 心情選單（含 Emoji 與可視化）
- 🏷️ 主題分類（自訂分類）
- 🤖 AI 鼓勵語自動生成（使用 Gemini API）
- 📊 心情時間軸圖表（折線圖）
- ☁️ Firebase Firestore 實時同步
- 🔒 支援 Firebase 使用者登入（匿名登入）

---

## 🔧 技術棧

| 技術       | 說明 |
|------------|------|
| Flutter    | 前端框架（支援 iOS / Android / Web） |
| Firebase   | 登入、資料儲存 |
| Gemini API | AI 鼓勵語生成（REST API） |
| Shimmer    | 骨架動畫 loading |
| fl_chart   | 心情折線圖表 |
| Cloud Firestore | 日記與使用者資料儲存 |

---

## 🖼️ 預覽畫面

| 新增日記 | 心情選擇 | 心情統計 |
|---------|---------|---------|
| ![](screenshots/new.png) | ![](screenshots/mood.png) | ![](screenshots/chart.png) |

---

## 🛠️ 開發說明

```bash
flutter pub get
flutterfire configure
flutter run
```

若要發布到 Web：

```bash
flutter build web
```

---

## 📁 專案架構

```
lib/
├── main.dart                # App 入口點
├── login_page.dart          # 登入畫面
├── journal_home_page.dart   # 首頁（日記卡片）
├── add_journal_page.dart    # 新增日記
├── edit_journal_page.dart   # 編輯與 AI 鼓勵語
└── mood_timeline_page.dart  # 心情時間軸圖表
```

---

## 🧠 作者資訊

由 [zse25414](https://github.com/zse25414) 製作  
📬 Email: zse25414@gmail.com

---

## 🌈 License

MIT License