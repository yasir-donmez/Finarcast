<div align="center">
  <img src="https://via.placeholder.com/800x200/1A1A1A/FFFFFF?text=FinCast+Banner" alt="FinCast Banner" width="100%">

  <br />
  <br />

  <h1>FinCast 💸</h1>
  <p><strong>Flutter tabanlı, Yapay Zeka destekli yeni nesil finans ve abonelik yönetim uygulaması.</strong></p>

  <a href="#indir">
    <img src="https://img.shields.io/badge/Google_Play-414141?style=for-the-badge&logo=google-play&logoColor=white" alt="Google Play" />
  </a>
  <a href="#indir">
    <img src="https://img.shields.io/badge/App_Store-0D0D0D?style=for-the-badge&logo=apple&logoColor=white" alt="App Store" />
  </a>

  <br />
  <br />

  <img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey" alt="Platform" />
  <img src="https://img.shields.io/badge/framework-Flutter%203.x-blue" alt="Flutter" />
  <img src="https://img.shields.io/badge/state-Riverpod-orange" alt="Riverpod" />
  <img src="https://img.shields.io/badge/database-Isar%20%7C%20Supabase-green" alt="Database" />
</div>

<br />

> **Not:** FinCast, standart bütçe takibinin ötesine geçerek; harcamalarınızı özel **Kasalar (Vaults)** içinde izole etmenizi, **Gemini AI** destekli "Smart Inbox" (Akıllı Gelen Kutusu) üzerinden finansal optimizasyon yapmanızı sağlayan premium bir mobil uygulamadır.

---

## 📱 Ekran Görüntüleri

*Geliştirme aşaması tamamlandıkça, uygulamanın özel cam efektli (GlassSurface) ve neumorphic (InsetContainer) tasarımlarına sahip ekran görüntüleri buraya eklenecektir.*

<p align="center">
  <img src="https://via.placeholder.com/250x500/1e1e1e/ffffff?text=Dashboard+Mockup" width="30%">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://via.placeholder.com/250x500/1e1e1e/ffffff?text=Vaults+Mockup" width="30%">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://via.placeholder.com/250x500/1e1e1e/ffffff?text=AI+Optimization+Mockup" width="30%">
</p>

---

## ✨ Gerçek Özellikler (Uygulamada Olanlar)

<table>
  <tr>
    <td align="center" width="50%">
      <h3>🛡️ Kasa (Vault) Mimarisi</h3>
      <p>Nakit, Kredi Kartı gibi varlıklarınızı ayrı kasalara bölün. <code>VaultGrid</code> ve <code>IntegratedVaultCard</code> bileşenleriyle tüm bakiyelerinizi tek panelden yönetin.</p>
    </td>
    <td align="center" width="50%">
      <h3>🤖 Gemini AI Optimizasyonu</h3>
      <p><code>google_generative_ai</code> entegrasyonu ile harcama geçmişiniz analiz edilir. "Smart Inbox" (Akıllı Kutu) üzerinden size özel bütçe optimizasyon tavsiyeleri sunulur.</p>
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <h3>💎 Premium Cam Tasarım</h3>
      <p>Özel <code>GlassSurface</code>, <code>SolidSurface</code> ve sıvı animasyonlara sahip <code>DynamicSegmentedControl</code> bileşenleri ile üst düzey, akıcı bir arayüz deneyimi.</p>
    </td>
    <td align="center" width="50%">
      <h3>🔁 Akıllı İşlem ve Abonelikler</h3>
      <p>Tekrarlayan gelir ve giderlerinizi takip edin, uygulama içi özel hatırlatıcılar ile yaklaşan ödemelerinizi asla kaçırmayın.</p>
    </td>
  </tr>
</table>

---

## 🛠 Kullanılan Teknolojiler (Tech Stack)

FinCast, en güncel Flutter paketleri ve modern mobil mimari standartlarıyla inşa edilmiştir:

*   **SDK & UI:** <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" /> (Material & Özel Bileşenler)
*   **State Management:** `flutter_riverpod` (Reaktif durum yönetimi)
*   **Veritabanı (Lokal & Uzak):** 
    *   `isar`: Işık hızında yerel veri depolama
    *   `supabase_flutter`: Uzak sunucu, senkronizasyon ve kimlik doğrulama
*   **Yapay Zeka:** `google_generative_ai` (Gemini API)
*   **Abonelikler (Premium):** `purchases_flutter` (RevenueCat entegrasyonu)
*   **Grafikler:** `fl_chart` (Veri görselleştirme)

---

## 🏗 Proje Klasör Yapısı

Proje özellikleri bağımsız modüller (Feature-based architecture) olarak ayrılmıştır:

```text
lib/
├── core/         # Temel yapılandırmalar (Tema, Rotalar, Ortam Değişkenleri)
├── features/     # İş modülleri
│   ├── auth/         # Giriş / Kayıt
│   ├── dashboard/    # Ana Panel ve Widget Yöneticisi
│   ├── optimization/ # AI Asistan, Smart Inbox
│   ├── profile/      # Ayarlar ve Abonelik (Premium Orb)
│   ├── transactions/ # İşlem Ekleme, Periyot ve Hatırlatıcılar
│   └── vaults/       # Kasa Yönetimi
├── l10n/         # Çoklu Dil Destekleri
└── shared/       # Ortak Bileşenler (Custom Widgets)
```

---

## 🚀 Geliştiriciler İçin Başlangıç

Projeyi lokal ortamınızda derlemek için aşağıdaki adımları izleyin.

### Kurulum

1. **Flutter SDK'yı yükleyin:** Cihazınızda Flutter `^3.9.2` ve üzeri kurulu olmalıdır.
2. **Repoyu indirin:**
   ```bash
   git clone <repository-url>
   cd FinCast
   ```
3. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```
4. **Kod Üretimini (Isar/Riverpod) Çalıştırın:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
5. **Ortam Değişkenlerini Ayarlayın:** Proje dizininde bir `.env` dosyası oluşturun ve gerekli Supabase / Gemini API anahtarlarını ekleyin.
6. **Projeyi Başlatın:**
   ```bash
   flutter run
   ```
