# 🔐 راهنمای امنیت و تنظیمات GitHub Secrets

## ✅ وضعیت امنیتی فعلی

پروژه با استانداردهای امنیتی زیر تنظیم شده است:

### فایل‌های حفاظت‌شده در `.gitignore`:
- ✅ `key.properties` - اطلاعات کلیدهای محلی
- ✅ `*.keystore` - فایل‌های keystore
- ✅ `android/app/zedsecure-release-new.keystore` - keystore اصلی
- ✅ `keystore-base64.txt` - نسخه base64 موقت
- ✅ `convert-keystore.ps1` - اسکریپت تبدیل

### کد امن:
- ✅ Password های hardcoded حذف شدند
- ✅ Build بدون environment variable/key.properties fail می‌شود
- ✅ GitHub Actions از Secrets استفاده می‌کند

---

## 📝 راهنمای گام‌به‌گام تنظیم GitHub Secrets

### مرحله 1️⃣: آماده‌سازی Keystore

اگر keystore ندارید، ابتدا آن را بسازید:

```bash
cd android/app
keytool -genkey -v -keystore zedsecure-release-new.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias zedsecure
```

اطلاعات را یادداشت کنید:
- **Keystore Password:** `________`
- **Key Alias:** `zedsecure`
- **Key Password:** `________`

### مرحله 2️⃣: تبدیل Keystore به Base64

در **PowerShell** (Windows):

```powershell
.\convert-keystore.ps1
```

یا دستی:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android\app\zedsecure-release-new.keystore")) | Out-File keystore-base64.txt -Encoding ASCII
```

در **Terminal** (Linux/macOS):

```bash
base64 android/app/zedsecure-release-new.keystore > keystore-base64.txt
```

⚠️ **توجه:** فایل `keystore-base64.txt` خیلی بزرگ است (چند هزار خط). این طبیعی است!

### مرحله 3️⃣: اضافه کردن Secrets به GitHub

1. به repository خود در GitHub بروید
2. کلیک کنید: **Settings** (در بالای صفحه)
3. از منوی سمت چپ: **Secrets and variables** → **Actions**
4. کلیک کنید: **New repository secret**

حالا 4 secret زیر را اضافه کنید:

#### Secret 1: KEYSTORE_FILE_BASE64

```
Name: KEYSTORE_FILE_BASE64
Value: [محتویات کامل فایل keystore-base64.txt را کپی/پیست کنید]
```

#### Secret 2: KEYSTORE_PASSWORD

```
Name: KEYSTORE_PASSWORD
Value: [رمز عبور keystore که در مرحله 1 یادداشت کردید]
```

#### Secret 3: KEY_ALIAS

```
Name: KEY_ALIAS
Value: zedsecure
```

#### Secret 4: KEY_PASSWORD

```
Name: KEY_PASSWORD
Value: [رمز عبور key - معمولاً همان KEYSTORE_PASSWORD]
```

### مرحله 4️⃣: پاکسازی فایل‌های موقت

⚠️ **بسیار مهم:**

```powershell
del keystore-base64.txt
```

این فایل را **حتماً** حذف کنید! اگر commit شود، امنیت به خطر می‌افتد.

### مرحله 5️⃣: تست Build

#### روش 1: با زدن Tag (توصیه می‌شود)

```bash
git tag v1.3.0
git push origin v1.3.0
```

#### روش 2: Manual Trigger

1. در GitHub به **Actions** بروید
2. روی **Build & Release APK** کلیک کنید
3. **Run workflow** → **Run workflow**

### مرحله 6️⃣: بررسی نتیجه

1. به tab **Actions** بروید
2. workflow جدید را باز کنید
3. باید همه step ها سبز شوند ✅
4. در **Artifacts** یا **Releases** فایل APK ظاهر می‌شود

---

## 🏗️ Build محلی (Local Development)

برای build در سیستم خود:

### گزینه 1: استفاده از `key.properties` (راحت‌تر)

```bash
copy key.properties.example key.properties
```

سپس `key.properties` را ویرایش کنید و اطلاعات واقعی را وارد کنید:

```properties
storeFile=android/app/zedsecure-release-new.keystore
storePassword=YOUR_ACTUAL_PASSWORD
keyAlias=zedsecure
keyPassword=YOUR_ACTUAL_PASSWORD
```

### گزینه 2: Environment Variables

در **PowerShell**:

```powershell
$env:KEYSTORE_PASSWORD="YOUR_PASSWORD"
$env:KEY_ALIAS="zedsecure"
$env:KEY_PASSWORD="YOUR_PASSWORD"
flutter build apk --release
```

در **CMD**:

```cmd
set KEYSTORE_PASSWORD=YOUR_PASSWORD
set KEY_ALIAS=zedsecure
set KEY_PASSWORD=YOUR_PASSWORD
flutter build apk --release
```

در **Linux/macOS**:

```bash
export KEYSTORE_PASSWORD="YOUR_PASSWORD"
export KEY_ALIAS="zedsecure"
export KEY_PASSWORD="YOUR_PASSWORD"
flutter build apk --release
```

---

## 🔍 بررسی امنیت

### چک کنید که این فایل‌ها در git نیستند:

```bash
git ls-files | findstr /i "keystore key.properties"
```

باید فقط `key.properties.example` را نشان دهد. ✅

### چک کنید که keystore-base64 پاک شده:

```powershell
Test-Path keystore-base64.txt
```

باید `False` برگرداند. ✅

### چک کنید که Secrets در GitHub تنظیم شده‌اند:

در GitHub: **Settings → Secrets and variables → Actions**

باید 4 secret ببینید:
- KEYSTORE_FILE_BASE64
- KEYSTORE_PASSWORD
- KEY_ALIAS
- KEY_PASSWORD

---

## ❌ چیزهایی که هرگز نباید انجام دهید

1. ❌ هرگز `keystore` را commit نکنید
2. ❌ هرگز `key.properties` با اطلاعات واقعی را commit نکنید
3. ❌ هرگز `keystore-base64.txt` را commit نکنید
4. ❌ هرگز password را در کد hardcode نکنید
5. ❌ هرگز keystore را در Telegram/Discord/Email به اشتراک نگذارید
6. ❌ هرگز screenshot از secrets نگیرید

---

## 🆘 عیب‌یابی

### خطا: "KEYSTORE_PASSWORD environment variable is not set"

**علت:** فایل `key.properties` وجود ندارد و environment variable هم ست نشده.

**راه‌حل:**
- `key.properties` را از example کپی کنید و پر کنید
- یا environment variables را ست کنید

### خطا در GitHub Actions: "KEYSTORE_FILE_BASE64: not found"

**علت:** Secret در GitHub تنظیم نشده.

**راه‌حل:**
- به Settings → Secrets and variables → Actions بروید
- همه 4 secret را اضافه کنید

### Build موفق اما APK sign نشده

**علت:** keystore یا passwords اشتباه است.

**راه‌حل:**
- Secrets را دوباره چک کنید
- keystore را دوباره تبدیل و آپلود کنید

---

## 📱 نکته نهایی

بعد از تنظیم صحیح Secrets:

✅ **می‌توانید:**
- کد را به راحتی push کنید
- با زدن tag به صورت خودکار APK بگیرید
- مطمئن باشید که اطلاعات شما امن است

✅ **نیاز نیست:**
- keystore را همراه با کد نگه دارید
- نگران امنیت باشید
- هربار دستی build بگیرید

---

**تاریخ آخرین بروزرسانی:** 2025-10-16  
**نسخه:** 1.3.0

