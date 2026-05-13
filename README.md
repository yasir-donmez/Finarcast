<div align="center">
  <h1>🚀 Finarcast</h1>
  <p><strong>Finansal Zaman Makinesi & Akıllı Servet Yönetimi</strong></p>

  <p>
    <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Isar_Database-Hot_Pink?style=for-the-badge&logo=databricks&logoColor=white" alt="Isar" />
    <img src="https://img.shields.io/badge/Design-Dark_Neumorphism-black?style=for-the-badge" alt="Design" />
    <img src="https://img.shields.io/badge/Architecture-Feature_First-success?style=for-the-badge" alt="Feature-First" />
  </p>
</div>

---

## 🌟 Uygulama Vizyonu ve Farkımız

**Finarcast**, kullanıcıları her gün kuruş kuruş veri girmeye zorlayan, geçmiş odaklı ve geleneksel bütçe uygulamalarından tamamen farklıdır. 

Uygulamamız bir **"Finansal Zaman Makinesi"** vizyonuyla çalışır. Geçmiş verileri listelemek yerine; **matematiksel modeller** ve **kısıtlı optimizasyon (Constrained Optimization)** algoritmaları kullanarak kullanıcının gelecekteki bakiyesini simüle eder, finansal hedeflerine ulaşması için stratejiler ve akıllı rotalar sunar.

---

## ✨ Temel Özellikler (Core Features)

- **📊 Esnek Bütçeleme (Min-Max):** Harcamalarınıza tek bir katı rakam girmek yerine esnek aralıklar belirlersiniz (Örn: *Haftalık market 200 TL - 450 TL*). Sistem bu aralıklara göre kısıtlı optimizasyon hesaplamaları yapar.
- **🔒 Kilit Mekanizması (Kırmızı Çizgi):** Yurt aidatı, eğitim, sağlık veya spor/supplement gibi vazgeçilmez temel giderlerinizi "Kilitlersiniz" (Lock). Sistem, tasarruf rotası oluştururken bu kilitli giderlere asla dokunmaz, tasarruf yükünü esnek harcamalara optimal şekilde dağıtır.
- **⏳ Zaman Makinesi (Gelecek Projeksiyonu):** Ekranda yer alan yenilikçi bir kaydırıcı (slider) ile aylar veya yıllar sonraki tahmini bakiyenizi anında simüle edebilirsiniz.
- **💼 Çoklu Varlık Kasaları (Vaults):** Sadece TL (Türk Lirası) değil; Altın, Dolar vb. farklı varlık kasaları oluşturabilirsiniz. Çevrimdışı öncelikli (offline-first) çalışarak toplam servetinizi anında ve internete bağlı kalmadan takip edebilirsiniz.
- **📸 Geçmiş Veri Snapshot'ları:** Her gün veri girmeseniz bile, sistem ay sonlarında bakiyenizin ve ayarlarınızın fotoğrafını (snapshot) çeker. Bu sayede geçmişe dönük tarihsel trend grafikleri (Bar charts) oluşturulur.

---

## 🛠 Teknik Mimari (Tech Stack & Architecture)

Finarcast, modern, hızlı ve tamamen gizlilik odaklı bir mimariyle inşa edilmiştir:

- **Frontend (Flutter):** Saniyede 120 FPS akıcılığa sahip sıvı animasyonlar (fluid animations) ve pürüzsüz bir arayüz deneyimi sunar.
- **Local Database (Isar):** Çevrimdışı öncelikli (offline-first) mimari üzerine kuruludur. İlişkisel NoSQL yapısıyla sıfır gecikme (zero-latency) sağlar. Uygulama internet olmadan %100 işlevsel çalışır.
- **Cloud Sync (Opsiyonel):** Firebase veya Google Drive üzerinden arka planda sessiz veri yedekleme olanağı bulunur. Ağır bir custom backend (.NET/PostgreSQL sunucusu vb.) kullanılmaz.
- **Yapay Zeka & Algoritma:** Yavaş LLM'ler (sohbet botları) yerine, cihaz üzerinde anında çalışan (on-device) kısıtlı optimizasyon algoritmaları kullanır. Gelecekte, başarı olasılığı hesaplayan özel **TFLite** tabanlı ML (Makine Öğrenimi) modelleri entegre edilecektir.

---

## 🎨 UI/UX Tasarım Dili

Finarcast, kullanıcıya premium ve dokunsal (tactile) bir his verir:

- **Tema (Dark Mode First):** Karanlık tema önceliklidir. Zemin rengi olarak obsidyen siyahı ve mat antrasit gri tercih edilmiştir.
- **Stil (Dark Neumorphism):** Karanlık Kabartma (Dark Neumorphism) stili kullanılmıştır. Ekranda yer alan kartlar ve butonlar fiziksel olarak ekrana gömülü (debossed) veya dışarı kabartılmış (embossed) gibi durarak mat ve premium bir hissiyat sunar.
- **Vurgu Renkleri:** Fütüristik dokunuşlar için **Elektrik Mavisi (Cyan)** ve **Neon Mor** parlamalar (glow) kullanılmıştır.

---

## 📂 Klasör Mimarisi (Architecture)

Proje, sürdürülebilir ve temiz kod prensiplerine uygun olarak **Feature-First (Özellik Odaklı)** mimaride kurgulanmıştır:

```plaintext
lib/
├── core/               # Konfigürasyon, Neumorphic temalar, Isar DB motoru ve sabitler
├── features/           # Uygulamanın bağımsız özellikleri (Modüler yapı)
│   ├── dashboard/      # Ana ekran, Zaman Makinesi UI (Slider ve projeksiyonlar)
│   ├── budget/         # Min-Max bütçeleme kuralları ve Kilit mekanizması
│   └── vaults/         # Çoklu varlık kasaları (Altın, Döviz vb.) yönetimi
├── shared/             # Ortak Neumorphic butonlar ve widget'lar
└── main.dart           # Uygulama başlatıcısı 
```

---

## 🚀 Kurulum (Getting Started)

Finarcast'i kendi ortamınızda derlemek ve deneyimlemek için aşağıdaki adımları takip edebilirsiniz:

1. **Repoyu Klonlayın:**
   ```bash
   git clone https://github.com/yasir-donmez/Finarcast.git
   cd Finarcast
   ```

2. **Bağımlılıkları Yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Kod Üretimini Başlatın (Isar veri modelleri için):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Uygulamayı Çalıştırın:**
   ```bash
   flutter run
   ```

---

<div align="center">
  <p><i>Finarcast — Gelecekteki Servetinizi Bugünden Optimizasyonla İnşa Edin.</i></p>
</div>
