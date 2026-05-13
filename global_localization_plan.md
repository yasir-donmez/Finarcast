# Finarcast Global Yerelleştirme ve Para Birimi Planı

Bu plan, uygulamanın global standartlara (EFIGS + CJK) tam olarak ulaşması ve para birimi formatlamasının farklı kültürlere göre mükemmelleştirilmesi için hazırlanmıştır.

## 1. Dil Genişletmesi (Standartların Tamamlanması)
Mevcut 8 dile ek olarak global pazarın devleri olan **Çince** ve **Korece** eklenecektir.
- **Eklenecek Diller:** Çince (zh), Korece (ko).
- **Yöntem:** `app_zh.arb` ve `app_ko.arb` dosyaları oluşturulacak ve tüm arayüz metinleri profesyonelce çevrilecek.
- **Arayüz:** Dil seçim listesine "中文" ve "한국어" eklenecek.

## 2. Para Birimi ve API Entegrasyonu
Tüm dillerin kendi yerel para birimlerini kullanabilmesi için altyapı güncellenecektir.
- **Yeni Birimler:** BRL (Brezilya Reali), CNY (Çin Yuanı), KRW (Kore Wonu), CHF (İsviçre Frangı), JPY (Japon Yeni).
- **API Güncellemesi:** `CurrencyService` bu yeni kurları canlı olarak çekecek.
- **Seçim Listesi:** Kullanıcılar ayarlar kısmından sadece ₺,$,€,£ değil; bu yeni simgeleri de (¥, ₩, R$, Fr, 元) seçebilecek.
- *Not: Japon Yeni için `¥`, Çin Yuanı için `元` simgeleri kullanılarak karışıklık önlenecek.*

## 3. Akıllı Formatlama (Kültürel Uyumluluk - Kritik)
Para birimleri sadece simge değildir; yazım kuralları da kültüre göre değişir.
- **Ondalık Farkı:** Japon Yeni (¥) ve Kore Wonu (₩) için kuruş/ondalık gösterimi kaldırılacak (Örn: `¥1,000.50` yerine `¥1,000`).
- **Ayraç Farkı:** 
  - ABD/İngiltere için: `1,000.50` (Virgül binlik, nokta ondalık)
  - TR/Avrupa için: `1.000,50` (Nokta binlik, virgül ondalık)
- **Simge Konumu:** 
  - ABD: `$100` (Önde ve bitişik)
  - Avrupa: `100 €` (Sonda ve boşluklu)
- **Yöntem:** `CurrencyUtils.dart` dosyası `intl` paketi kullanılarak dile ve kültüre göre dinamik formatlayacak şekilde baştan yazılacak.

---
*Bu plan, geliştirici onayından hemen sonra kodlanmaya başlanacaktır.*
