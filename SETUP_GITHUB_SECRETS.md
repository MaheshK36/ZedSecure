# راهنمای تنظیم GitHub Secrets برای Build امن 🔐

این راهنما به شما کمک می‌کند تا keystore و اطلاعات حساس را به صورت امن در GitHub Secrets تنظیم کنید.

## 📋 مراحل تنظیم

### مرحله 1: تبدیل Keystore به Base64

#### در Windows (PowerShell):
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android\app\zedsecure-release-new.keystore")) | Out-File -FilePath keystore-base64.txt -Encoding ASCII
```

یا استفاده از فایل آماده:
```powershell
.\convert-keystore.ps1
```

#### در Linux/macOS:
```bash
base64 android/app/zedsecure-release-new.keystore > keystore-base64.txt
```

### مرحله 2: اضافه کردن Secrets به GitHub

1. به repository خود در GitHub بروید
2. `Settings` → `Secrets and variables` → `Actions`
3. `New repository secret` را کلیک کنید
4. Secrets زیر را اضافه کنید:

#### Secret 1: KEYSTORE_FILE_BASE64
- **Name:** `KEYSTORE_FILE_BASE64`
- **Value:** محتویات فایل `keystore-base64.txt` را کپی کنید

#### Secret 2: KEYSTORE_PASSWORD
- **Name:** `KEYSTORE_PASSWORD`
- **Value:** رمز عبور keystore خود را وارد کنید

#### Secret 3: KEY_ALIAS
- **Name:** `KEY_ALIAS`
- **Value:** `zedsecure`

#### Secret 4: KEY_PASSWORD
- **Name:** `KEY_PASSWORD`
- **Value:** رمز عبور key را وارد کنید (معمولاً همان KEYSTORE_PASSWORD است)

### مرحله 3: تست Build

بعد از اضافه کردن secrets:

1. یک tag جدید بسازید:
```bash
git tag v1.3.0
git push origin v1.3.0
```

2. به `Actions` tab در GitHub بروید
3. workflow `Build & Release APK` باید به صورت خودکار اجرا شود
4. اگر همه چیز درست باشد، APK ها build می‌شوند و در Releases منتشر می‌شوند

## 🔒 نکات امنیتی

✅ **انجام شده:**
- keystore در `.gitignore` قرار دارد
- `key.properties` در `.gitignore` قرار دارد
- Passwords در کد hardcode نیستند
- Build در CI/CD از GitHub Secrets استفاده می‌کند

⚠️ **هشدارها:**
- هرگز `keystore-base64.txt` را commit نکنید
- هرگز passwords واقعی را در کد قرار ندهید
- فایل `key.properties` فقط برای build محلی است

## 🗑️ پاکسازی بعد از Setup

بعد از اضافه کردن secrets، فایل‌های موقت را پاک کنید:
```bash
del keystore-base64.txt
```

## 📦 Build محلی (Local Development)

برای build در سیستم خودتان، `key.properties` را از `key.properties.example` کپی کنید:

```bash
copy key.properties.example key.properties
```

سپس اطلاعات واقعی خود را در `key.properties` قرار دهید.

## ✅ Checklist

- [ ] keystore به base64 تبدیل شد
- [ ] 4 secret در GitHub اضافه شدند
- [ ] فایل `keystore-base64.txt` حذف شد
- [ ] فایل `key.properties` در `.gitignore` است
- [ ] Test build با tag زدن انجام شد

---

**نکته:** این تنظیمات یکبار انجام می‌شوند و برای همیشه امن هستند! 🚀

