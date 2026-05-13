# Finarcast Dashboard Widget Board Planı 🚀💎

Bu belge, Finarcast ana sayfasının iOS ve Android (Samsung) widget standartlarına uygun, modüler ve premium bir "Widget Panosu"na dönüştürülme stratejisini içerir.

## 1. Temel Mimari (Grid System)
Ana sayfa, esnek bir 2 sütunlu ızgara yapısına sahip olacaktır. Her widget aşağıdaki standart boyutlardan birine sahip olmalıdır:

- **1x1 (Small):** Kompakt bilgi, tek eylem.
- **2x1 (Wide):** Yatay özetler, liste başlıkları.
- **2x2 (Large):** Detaylı analizler, interaktif listeler, ana grafikler.

---

## 2. Planlanan Widget'lar 🧩

### A. Timeline Activity (Geçmiş İzleyici) - [Size: 2x2]
- **Görev:** Günlük, Aylık ve Yıllık bazda eklenen son işlemleri listeler.
- **Özellikler:** 
    - Üst kısımda "Gün / Ay / Yıl" geçiş tabları.
    - Glass list item tasarımı.
    - Tıklandığında işlem detayına hızlı geçiş.

### B. Due Date Radar (Ödeme Radarı) - [Size: 2x2]
- **Görev:** Yaklaşan (1 hafta içindeki) ödemeleri ve beklenen gelirleri takip eder.
- **Özellikler:**
    - Periyot takibi (Kaç gün kaldı?).
    - Vadesi gelenler için "Pulsing Alert" (Parlayan Uyarı) efekti.
    - Hatırlatıcı/Alarm entegrasyonu.

### C. Spending Giants (Harcama Devleri) - [Size: 2x2]
- **Görev:** Belirlenen periyotta en çok harcama yapılan kategorileri ve işlemleri gösterir.
- **Özellikler:**
    - Top 3 Kategori (İkon + Tutar + Yüzde).
    - Top 3 En Büyük İşlem.
    - Hafta/Ay/Yıl bazlı filtreleme.

### D. Budget Pulse (Bütçe Nabzı) - [Size: 2x1 veya 2x2]
- **Görev:** Günlük harcanabilir limitin durumunu gösterir.
- **Özellikler:**
    - Akışkan (Fluid) halka grafik.
    - "Kalan Limit" bilgisi.
    - Mevcut `RotaryTimeDial`'ın widget'a dönüştürülmüş hali.

---

## 3. Tasarım ve Estetik Kuralları (Design Language) 🎨

1. **Squircle Corners:** Tüm widget'lar iOS tarzı yumuşatılmış köşelere sahip olmalıdır.
2. **Premium Glass:** `PremiumGlassCard` temeli kullanılacak; katmanlar arası derinlik hissi korunacaktır.
3. **Glanceable UI:** Yazılar minimumda tutulacak, ikonlar ve renklerle bilgi hiyerarşisi sağlanacaktır.
4. **Micro-Interactions:** Widget içi geçişler (Tab değiştirme vb.) akışkan animasyonlarla yapılacaktır.
5. **Haptic Feedback:** Her etkileşimde fiziksel widget hissi için haptik (titreşim) geri bildirimi verilecektir.

---

## 4. Teknik Yol Haritası 🛠️

1. **Base Class:** `DashboardWidget` sarmalayıcısının oluşturulması.
2. **Grid Layout:** Ana sayfanın mevcut yapısının `SliverGrid` veya `Wrap` sistemine taşınması.
3. **Widget Implementation:** A, B ve C widget'larının sırayla geliştirilmesi.
4. **Customization:** Kullanıcının widget yerlerini veya boyutlarını değiştirebilme altyapısının hazırlanması (Opsiyonel).
