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
├── core/         # Temel yapılandırmalar (Tema, Veritabanı, Servisler)
├── features/     # İş modülleri
│   ├── auth/         # Giriş / Kayıt / Supabase Auth
│   ├── home/         # Dashboard, Özet Kartlar ve Ana Navigasyon
│   ├── smart_inbox/  # AI Asistan ve Akıllı Tarama (Gemini API)
│   ├── settings/     # Uygulama Tercihleri ve Profil
│   ├── subscription/ # Premium Abonelik Yönetimi (RevenueCat)
│   ├── transactions/ # İşlem Kayıtları, Şablonlar ve Periyotlar
│   └── vaults/       # Kasa/Cüzdan Yönetimi ve Transferler
├── l10n/         # Çoklu Dil Destekleri (ARB dosyaları)
└── shared/       # Ortak Bileşenler ve Yardımcı Araçlar (Widgets, Utils)
```

## 💾 Veritabanı ve Senkronizasyon Yapısı (Database & Sync)

FinCast, **çevrimdışı öncelikli (offline-first)** veri mimarisi üzerine kurulmuştur. Veriler önce yerel veritabanında (**Isar**) saklanır ve internet bağlantısı sağlandığında arka planda bulut veritabanı (**Supabase**) ile çift yönlü olarak senkronize edilir.

### 1. Veritabanı Mimarisi

*   **Yerel Veritabanı (Isar DB):** Flutter için optimize edilmiş, NoSQL benzeri çalışan yüksek performanslı yerel nesne deposudur.
*   **Bulut Veritabanı (Supabase):** PostgreSQL tabanlı, kullanıcı verilerinin güvenli yedeği ve cihazlar arası eşitleme için kullanılır. **Row Level Security (RLS)** ile her kullanıcı sadece kendi verisine erişebilir.

### 2. Ayrıntılı Tablo Şemaları ve Veri Tipleri

#### A. Kasalar/Hesaplar (`vaults`)
Kullanıcının nakit, banka, kredi kartı veya altın gibi varlıklarını yönettiği cüzdan yapılarıdır.
*   `id` (UUID, PK): Bulut anahtarı.
*   `name` (Text): Kasa adı (örn: "Ana Cüzdan", "Yatırım Hesabı").
*   `currency` (Text): Kasanın para birimi (TRY, USD, EUR vb.).
*   `balance` (Double): Mevcut bakiye.
*   `updated_at` (Timestamptz): Son güncelleme zamanı.

#### B. Tekrarlayan İşlem Şablonları (`recurring_templates`)
Abonelikler, maaşlar veya kira gibi düzenli işlemlerin kural setidir. `TransactionRecord` üretmek için temel teşkil eder.
*   `title` / `amount` / `currency`: İşlemin temel bilgileri.
*   `min_amount` / `max_amount`: Esnek bütçeleme aralıkları.
*   `period_type` (Integer): Periyot kodlaması (Bkz. Periyot Yapısı).
*   `recurrence_day` / `recurrence_date`: Tekrarlama günü veya özel tarihi.
*   `total_installments`: Toplam taksit sayısı (Sınırsız ise null).
*   `is_paused` (Boolean): Şablonun aktiflik durumu.
*   `vault_id` (UUID, FK): İşlemin gerçekleşeceği kasa.

#### C. İşlem Kayıtları (`transaction_records`)
Gerçekleşmiş veya planlanmış bireysel finansal hareketlerdir.
*   `is_income` (Boolean): Gelir mi, gider mi?
*   `title` / `amount` / `currency`: İşlem detayları.
*   `occurrence_key` (Text, Unique): Mükerrer kaydı önlemek için üretilen benzersiz anahtar (Şablon ID + Tarih).
*   `template_id` (UUID, FK, Opsiyonel): Bağlı olduğu şablonun ID'si.
*   `status` (Integer): İşlem durumu (0: Onaylı, 2: Atlandı).
*   `vault_id` / `target_vault_id`: Kaynak ve (transfer ise) hedef kasa.
*   `is_reviewed` (Boolean): Kullanıcının işlemi görüp onayladığı bilgisi.

#### D. Uygulama Ayarları (`app_settings`)
Kullanıcı başına tek bir satır olarak tutulan tercihler.
*   `language_code` (Text): Uygulama dili.
*   `theme_mode_index` (Integer): 0: Sistem, 1: Aydınlık, 2: Karanlık.
*   `data_retention_days` (Integer): Otomatik arşivleme sınırı.
*   `permanent_deletion_days` (Integer): Kalıcı silme sınırı.
*   `is_sync_enabled` (Boolean): Bulut eşitleme anahtarı.
*   `currency_symbol` (Text): Uygulamanın varsayılan para birimi.

#### E. Döviz Kurları (`exchange_rates` - Sadece Yerel)
Uygulama içi para birimi dönüşümleri için kullanılan anlık kur verileri.
*   `currencyCode`: Para birimi kodu (USD, EUR vb.).
*   `rate`: Baz birime (TRY) göre oranı.
*   `lastUpdated`: Kurun son çekilme zamanı.

---

### 3. Periyot Kodlama Yapısı (`periodType`)

Sorgu performansı için kullanılan formül: `(Birim * 100) + Sıklık (Interval)`

| Birim Değeri | Sıklık (X) | Örnek | Karşılığı |
| :--- | :--- | :--- | :--- |
| **`0`** | `0` | `0` | Tek Seferlik |
| **`100`** (Gün) | `X` | `101` | Her gün |
| **`200`** (Hafta) | `X` | `201` | Haftalık |
| **`300`** (Ay) | `X` | `301` | Aylık |
| **`400`** (Yıl) | `X` | `401` | Yıllık |
| **Özel** | — | `250` / `251` | Hafta İçi / Hafta Sonu |

---

### 4. Senkronizasyon ve Çakışma Yönetimi

*   **Senkronizasyon Durumları:**
    *   `0`: Synced (Bulutla eşit).
    *   `1`: Pending (Yerelde yeni/güncellenmiş).
    *   `2`: Deleted (Yerelde silinmiş, buluttan silinmeyi bekliyor).
*   **Çakışma Çözümü:** `updated_at` zaman damgası üzerinden **Last-Write-Wins (Son Yazan Kazanır)** stratejisi uygulanır.
*   **FK Güvenliği:** İşlemler buluta gönderilmeden önce, bağlı oldukları Kasaların (Vaults) bulutta mevcut olduğu doğrulanır.

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
