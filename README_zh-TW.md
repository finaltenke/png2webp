# PNG to WebP Converter

一個 macOS 桌面應用程式，支援拖放 PNG 圖片轉換為 WebP 格式。

## 功能

- 拖放 PNG 檔案即可轉換
- 可調整輸出品質 (0-100)
- 輸出檔案自動儲存在原檔案相同位置
- 顯示轉換結果：檔案大小變化、壓縮比例
- 支援深色/淺色模式
- 支援英文與繁體中文介面

## 需求

- macOS
- Flutter SDK
- cwebp (透過 Homebrew 安裝)

```bash
brew install webp
```

## 執行

```bash
flutter run -d macos
```

## 建置

```bash
flutter build macos
```

建置完成後，應用程式位於 `build/macos/Build/Products/Release/png2webp_app.app`

## 授權

MIT License
