# 🚴 Delievry_App - On-Demand Food Delivery Application

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/UI--Theme-Elegant--Light-orange?style=for-the-badge" alt="UI Theme">
</p>

## 📖 نبذة عن المشروع (Project Overview)
[cite_start]**Delievry_App** هو تطبيق هاتف محمول متطور ومتكامل لطلب وتوصيل الطعام على غرار التطبيقات العالمية الشهيرة مثل "طلبات"[cite: 484]. [cite_start]تم بناء التطبيق باستخدام بيئة عمل **Flutter** ليعمل بكفاءة عالية على نظامي Android و iOS بكود برمجي موحد[cite: 522].

[cite_start]يهدف المشروع إلى توفير تجربة مستخدم سلسة وعصرية تعتمد على **الوضع الفاتح (Light Theme)**، وتربط ديناميكياً بين ثلاثة أطراف رئيسية[cite: 460, 488]:
1. [cite_start]**العميل (Customer):** لتصفح المطاعم، إضافة الوجبات للسلة، الدفع، وتتبع الطلب[cite: 493].
2. [cite_start]**المطعم (Restaurant Partner):** لاستقبال الطلبات، إدارتها، وتجهيز المنيو[cite: 494].
3. [cite_start]**الكابتن/المندوب (Delivery Driver):** لقبول طلبات التوصيل القريبة والوصول للوجهة عبر الخريطة[cite: 495].

---

## 🎨 النظام التصميمي والهوية البصرية (Design System)

تم فحص واجهات التطبيق الفعلية بدقة واشتقاق لوحة الألوان والخطوط لتعبّر تماماً عن الهوية البصرية الحية للتطبيق.

### 🔴 لوحة الألوان الفعلية (Color Palette)

| العنصر | كود الـ Hex | الاستخدام في الواجهات |
| :--- | :--- | :--- |
| **البرتقالي الحيوي** | `#FF6F00` | اللون الأساسي للتطبيق؛ يُستخدم للأزرار الرئيسية (CTA)، الأوامر التفاعلية، ومسارات التوجيه. |
| **الخلفية الأساسية** | `#FFFFFF` | اللون الأبيض النقي للخلفيات لتوفير مظهر نظيف وإبراز صور الأكلات. |
| **الرمادي الناعم** | `#F5F5F7` | خلفيات بطاقات الطعام (Cards)، شريط البحث، وحقول الإدخال. |
| **النصوص والعناوين** | `#1A1A1A` | اللون الأسود الداكن لضمان تباين ممتاز وقراءة مريحة للعناوين والأسعار. |
| **الأخضر التأكيدي** | `#10B981` | يُستخدم لإشعارات النجاح، تأكيد الطلبات، وحالات التوصيل الناجحة. |

### 🔤 الخطوط المستخدمة (Typography)
* يعتمد التطبيق على خطوط **Google Fonts** العصرية (مثل **Inter** و **Poppins** للواجهات الإنجليزية بالتكامل مع خط **Cairo** أو **Tajawal** للغة العربية) لضمان انسيابية النصوص وتناسقها مع أحجام الشاشات المختلفة.

---

## 📸 لقطات من داخل التطبيق (App Screenshots)

يحتوي المشروع على **18 واجهة مستخدم** متكاملة تم تنظيمها بروابط نسبية ذكية لتظهر مباشرة على حسابك في GitHub بدون أخطاء:

<p align="center">
  <img src="screenshots/landing_page.png" width="24%" alt="Landing Page" />
  <img src="screenshots/home.png" width="24%" alt="Home Screen" />
  <img src="screenshots/restaurant_page.png" width="24%" alt="Restaurant Page" />
  <img src="screenshots/my_cart.png" width="24%" alt="My Cart" />
</p>

<p align="center">
  <img src="screenshots/ckechout_page.png" width="24%" alt="Checkout Page" />
  <img src="screenshots/place_order.png" width="24%" alt="Place Order" />
  <img src="screenshots/tracking_order.png" width="24%" alt="Tracking Order" />
  <img src="screenshots/my_profile_page.png" width="24%" alt="My Profile" />
</p>

### 📱 دليل الواجهات الـ 18 المتضمنة في مجلد المستودع:
* **`landing_page`**: الواجهة الترحيبية الأولى للهبوط بهوية التطبيق الجذابة.
* **`login` / `register` / `reset_password`**: الشاشات الخاصة بمنظومة تسجيل الدخول وإنشاء الحسابات.
* **`OPT_Verification`**: واجهة التحقق عبر كود الدخول المؤقت لأمان الحسابات.
* **`home` / `search_page`**: الشاشات الرئيسية لتصفح الوجبات، الأقسام، واستخدام فلاتر البحث الذكية.
* **`restaurant_page` / `select_order`**: استعراض منيو المطعم المختار وتخصيص تفاصيل الوجبة.
* **`favorites_page`**: قائمة حفظ الأطعمة والمطاعم المفضلة للوصول السريع إليها.
* **`my_cart` / `ckechout_page` / `place_order`**: سلة المشتريات، اختيار مراجعة الحساب، وإإتمام الطلب.
* **`tracking_order`**: شاشة تتبع الكابتن حياً على الخريطة في الوقت الفعلي.
* **`my_orders` / `order_details` / `past_order`**: إدارة ومتابعة الطلبات الجارية وأرشيف الطلبات السابقة.
* **`my_profile_page`**: التحكم في البيانات الشخصية، الإعدادات، والعناوين المحفوظة.

---

## 🚀 الميزات الأساسية للمشروع (Core Features)

### 👤 تطبيق العميل (Customer App)
* [cite_start]**تحديد المواقع الذكي:** التعرف التلقائي على الموقع عبر الـ GPS وحفظ عناوين متعددة (المنزل / العمل)[cite: 498, 499].
* **سلة مرنة:** إضافة وتعديل مكونات الوجبات مع كتابة ملاحظات خاصة للمطبخ[cite: 500].
* [cite_start]**الدفع المتعدد:** دعم الدفع النقدي عند الاستلام (COD) والدفع الإلكتروني (البطاقات والمحافظ)[cite: 502, 503].
* [cite_start]**التتبع الحي:** عرض حركة المندوب مباشرة على الخريطة باستخدام Google Maps API[cite: 505].

### 🍳 لوحة تحكم المطاعم (Restaurant Panel)
* **إدارة فوريّة للطلبات:** استقبال تنبيهات صوتية قوية للطلبات الجديدة وقبولها أو رفضها مع تحديد وقت التحضير[cite: 507, 508].
* [cite_start]**التحكم بالمنيو:** إضافة الوجبات وتحديث الأسعار أو تحويل الوجبات غير المتوفرة إلى (Out of stock)[cite: 509, 510].

### 🚗 تطبيق المندوب (Driver App)
* [cite_start]**تغيير الحالة:** زر مرن للتحول إلى (نشط / غير نشط) لاستقبال الطلبات حسب الرغبة[cite: 512].
* **الطلبات الذكية:** استقبال الطلبات القريبة جغرافياً مع توضيح المكسب وموقع المطعم والعميل[cite: 513].
* [cite_start]**التوجيه الديناميكي:** رسم أسرع مسار على الخريطة للوصول للمطعم ثم العميل[cite: 514].

---

## 🛠️ التقنيات المستخدمة (Tech Stack)
* [cite_start]**واجهات المستخدم (Frontend):** Flutter & Dart Framework[cite: 522].
* **الخرائط والمواقع:** Google Maps Flutter SDK[cite: 525].
* [cite_start]**الإشعارات الفورية:** Firebase Cloud Messaging (FCM)[cite: 526].
* [cite_start]**التحقق والتأمين:** Firebase Auth / SMS OTP Verification[cite: 527].

---

## 💻 طريقة تشغيل المشروع محلياً (Installation Guide)

إذا كنت ترغب في تشغيل المشروع على جهازك الشخصي ومعاينة الواجهات الـ 18، يرجى اتباع الخطوات التالية:

### 1️⃣ تحميل المستودع
قم بفتح الـ Terminal الخاص بك وعمل Clone للمستودع:
```bash
git clone [https://github.com/MohamedIbrahimAbdulghani/Delievry_App.git](https://github.com/MohamedIbrahimAbdulghani/Delievry_App.git)
cd Delievry_App
```


### 2️⃣ تثبيت الاعتماديات وحزم Flutter
قم بفتح الـ Terminal الخاص بك وعمل Clone للمستودع:
```bash
flutter pub get
```


### 3️⃣ تجهيز وفحص المحاكي
قم بفتح الـ Terminal الخاص بك وعمل Clone للمستودع:
```bash
flutter devices
```

### 4️⃣ تشغيل التطبيق
قم بفتح الـ Terminal الخاص بك وعمل Clone للمستودع:
```bash
flutter run
```