# Plan: Esnek ve Onay Mekanizmalı Periyodik İşlemler (Hibrit Model)

Bu plan, periyodik harcamaların (Netflix, Kira, Fatura vb.) "matematiksel bir simülasyon" olmaktan çıkarılıp, arayüzde (Kasalar ekranında) tek tek gerçekleşen/onay bekleyen somut işlemlere dönüştürülmesini amaçlar.

Uygulama, geçmiş ve bugün vadeli periyodik işlemleri varsayılan olarak "ödenmiş/onaylanmış" kabul ederek bakiyeyi güncel tutar (iyimser bakiye). Ancak kullanıcıya arayüzde bu işlemleri kesikli kenarlıklarla göstererek onaylama, atlama veya o güne özel tutar değiştirme esnekliği sunar.

---

## Kullanıcı İncelemesi Gereken Konular

> [!IMPORTANT]
> **Isar Veritabanı Değişikliği ve Kod Üretimi (Build Runner)**
> Veritabanı şemasına yeni alanlar ekleyeceğimiz için projedeki `build_runner` aracını çalıştırıp `transaction_record.g.dart` dosyasını yeniden üretmemiz gerekecektir.

> [!NOTE]
> **Varsayılan Davranış**
> Kullanıcı işlem üzerinde hiçbir işlem yapmazsa, işlem **iyimser (optimistic) olarak onaylı** sayılır ve kasadan düşülür. Böylece bakiye her zaman gerçekçi kalır. Arayüzde ise kullanıcı onaylayana kadar kesikli çizgili görünmeye devam eder.

---

## Önerilen Değişiklikler

### 1. Veritabanı Modeli (Veri Katmanı)

#### [MODIFY] [transaction_record.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/core/database/models/transaction_record.dart)
* `TransactionRecord` sınıfına aşağıdaki alanlar eklenecektir:
  * `int? parentRecurringId`: Bu kaydın hangi periyodik şablona (ID) ait olduğunu belirtir.
  * `bool isSkipped = false`: Kullanıcının bu gerçekleşmeyi pas geçip geçmediğini (atlayıp atlamadığını) belirtir.
* Şema güncellendiği için `build_runner` komutu çalıştırılacaktır:
  `flutter pub run build_runner build --delete-conflicting-outputs`

---

### 2. State & Veri Yönetimi (Providers)

#### [MODIFY] [vaults_providers.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/features/vaults/vaults_providers.dart)
* `TransactionUI` sınıfına şu alanlar eklenecektir:
  * `final bool isPending;` (Eğer bugün veya geçmiş bir tarihteyse ve henüz veritabanında somut bir gerçekleşme/atlama kaydı yoksa `true` olur. Arayüzde kesikli çizgi tetikler.)
  * `final bool isSkipped;` (Veritabanında atlandı olarak işaretlenmişse `true` olur.)
  * `final int? parentRecurringId;`
* `vaultTransactionsProvider` güncellenecektir:
  * Veritabanından gelen tüm normal işlemleri çeker.
  * Aktif periyodik işlem şablonlarını tespit eder.
  * Bu şablonlar için başlangıç tarihinden itibaren (en fazla içinde bulunulan ayın sonuna kadar) gerçekleşmesi gereken tüm tarihleri (occurrence dates) hesaplar.
  * Her hesaplanan tarih için veritabanında `parentRecurringId == template.id` olan ve o tarihe denk gelen gerçek bir kayıt olup olmadığını kontrol eder:
    * **Kayıt varsa:** O gerçek kaydı listede döndürür (Tutar değiştirilmişse yeni tutar, atlanmışsa `isSkipped = true` olarak gelir).
    * **Kayıt yoksa:** Sanal bir `TransactionUI` üretir (`isPending = true`, `dbId = null`, `date = hesaplananTarih`, `amount = şablonTutarı`).
* `vaultCardDataProvider` (Bakiye ve İstatistik Hesaplayıcı) güncellenecektir:
  * Dinamik tarih formülleri yerine, `vaultTransactionsProvider`'dan dönen zenginleştirilmiş işlem listesini kullanacaktır.
  * `isSkipped = true` olan işlemler hesaba katılmaz (0 TL).
  * `isPending = true` (sanal) olan işlemler iyimser yaklaşımla varsayılan tutarlarıyla bakiyeden düşülür.

---

### 3. Arayüz Tasarımı ve Bileşenler (UI / UX)

#### [MODIFY] [transaction_card.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/features/vaults/widgets/transaction_card.dart)
* Kart çizilirken `isPending` durumu kontrol edilecektir:
  * Eğer `isPending == true` ise:
    * Kartın kenarlığı kesikli çizgili (dashed border) yapılacaktır.
    * Sağ üst köşeye ufak bir "Onay Bekliyor" ikonu/etiketi veya checkmark konulacaktır.
  * Eğer `isSkipped == true` ise:
    * Kart hafif soluklaştırılacak (opacity 0.4) ve başlık/tutar üzeri çizili (line-through) olarak gösterilecektir. Sağ üstte "Atlandı" yazacaktır.

#### [NEW] [pending_transaction_sheet.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/features/vaults/widgets/pending_transaction_sheet.dart)
* Onay bekleyen kesikli kartlara tıklandığında açılacak özel bottom sheet:
  * **"Evet, Ödendi / Yapıldı" Butonu:** Basıldığında veritabanına `parentRecurringId` ve o günün tarihiyle somut bir işlem kaydeder.
  * **"Hayır, Yapılmadı" Butonu:** Basıldığında bir alt menü açar:
    * **"Bu Seferlik Pas Geç / Atla":** Veritabanına `isSkipped = true` olan bir somut işlem kaydeder.
    * **"Tutarı Değiştir":** Hızlıca yeni tutar yazdırır. Tutar yazıldıktan sonra:
      * **"Sadece Bu Seferlik":** Girilen tutarla somut bir işlem kaydeder.
      * **"Bundan Böyle":** Ana şablonun tutarını veritabanında günceller ve bu gerçekleşmeyi de yeni tutarla kaydeder.

#### [MODIFY] [vaults_screen.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/features/vaults/vaults_screen.dart)
* Kart tıklama metodu `_showTransactionActions` güncellenecektir:
  * Eğer tıklanan kart sanal ise (`isPending == true`), normal detay sayfası yerine yeni oluşturulan `PendingTransactionSheet` bottom sheet'i açılacaktır.

---

## Doğrulama Planı

### Otomatik Testler
* Riverpod provider testi yazılabilir ya da manuel doğrulama ile test edilebilir.

### Manuel Doğrulama
1. **Periyodik İşlem Oluşturma:** Aylık 100 TL'lik bir Netflix gideri oluşturun.
2. **Onay Bekleme Aşaması:** Kasalar ekranındaki listede Netflix'in kesikli kenarlıkla göründüğünü doğrulayın. Kasa bakiyesinin 100 TL düşmüş olduğunu doğrulayın (iyimser onay).
3. **Tutarı Değiştirerek Onaylama:** Karta dokunun, "Hayır, yapılmadı -> Tutarı Değiştir -> Sadece bu seferlik" yolunu izleyip 120 TL yapın. Kartın normal görünüşe geçtiğini, tutarın 120 TL olduğunu ve kasa bakiyesinin 120 TL olarak güncellendiğini doğrulayın.
4. **Pas Geçme / Atlama:** Başka bir periyodik işlem oluşturup "Hayır -> Bu seferlik atla" deyin. Kartın listede soluk ve üzeri çizili olarak kaldığını, kasa bakiyesine etki etmediğini (bakiyenin geri yükseldiğini) doğrulayın.
