# Finarcast Profesyonel Widget Rehberi

Bu dosya, `lib/shared/widgets` ve özellik bazlı klasörlerde yer alan profesyonel bileşenlerin işlevlerini, eski adlarını ve projede nerelerde kullanıldıklarını açıklar. Tüm bileşenlerin isimlendirmeleri, pazarlama ve özel marka kelimelerinden arındırılarak doğrudan yaptıkları işe odaklanacak şekilde güncellenmiştir.

---

## 1. Ortak Bileşenler (`lib/shared/widgets/`)

### ClickableAction
- **İşlevi**: Sarmaladığı herhangi bir bileşene tıklanabilirlik özelliği, dokunma anında hafif küçülme (scale down) animasyonu ve haptic (titreşimli) geri bildirim ekleyen temel etkileşim bileşenidir.
- **Eski Adı**: `PrecisionAction` / `PrecisionClickable`
- **Tanım Dosyası**: [clickable_action.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/clickable_action.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/profile/widgets/profile_list_items.dart`
  - `lib/features/profile/widgets/settings/currency_setting.dart`
  - `lib/features/profile/widgets/settings/exchange_rate_setting.dart`
  - `lib/features/profile/widgets/settings/location_setting.dart`
  - `lib/features/profile/widgets/settings/notification_setting.dart`
  - `lib/features/profile/widgets/settings/purge_setting.dart`
  - `lib/features/profile/widgets/settings/retention_setting.dart`
  - `lib/features/profile/widgets/settings/subscription_setting.dart`
  - `lib/features/profile/widgets/settings/sync_setting.dart`
  - `lib/features/subscription/widgets/pro_upgrade_sheet.dart`
  - `lib/features/transactions/widgets/transaction_period_selector.dart`
  - `lib/features/transactions/widgets/transaction_reminder_days_selector.dart`
  - `lib/features/transactions/widgets/transaction_reminder_time_selector.dart`
  - `lib/shared/widgets/custom_button.dart`
  - `lib/shared/widgets/custom_icon_button.dart`

### CustomAnimatedIcon
- **İşlevi**: İki ikon arasında yumuşak bir rotasyon ve ölçeklenme (scale) animasyonuyla geçiş yapılmasını sağlayan özel ikon bileşenidir.
- **Eski Adı**: `PrecisionAnimatedIcon`
- **Tanım Dosyası**: [custom_animated_icon.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/custom_animated_icon.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/optimization/widgets/setup/items_section.dart`
  - `lib/features/profile/widgets/profile_list_items.dart`
  - `lib/features/profile/widgets/settings/location_setting.dart`
  - `lib/features/profile/widgets/settings/notification_setting.dart`
  - `lib/features/profile/widgets/settings/sync_setting.dart`
  - `lib/features/vaults/widgets/detail_sheet.dart`
  - `lib/shared/widgets/custom_switch.dart`

### CustomButton
- **İşlevi**: Minimalist ve degrade renk geçişleriyle parlayan premium ghost-style ve solid buton bileşenidir.
- **Eski Adı**: `PrecisionButton`
- **Tanım Dosyası**: [custom_button.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/custom_button.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/auth/screens/auth_screen.dart`
  - `lib/features/dashboard/widgets/dashboard_widget_manager_sheet.dart`
  - `lib/features/dashboard/widgets/vault_grid.dart`
  - `lib/features/optimization/optimization_screen.dart`
  - `lib/features/optimization/widgets/result/analysis_feedback_section.dart`
  - `lib/features/profile/widgets/settings/currency_setting.dart`
  - `lib/features/profile/widgets/settings/exchange_rate_setting.dart`
  - `lib/features/profile/widgets/settings/language_setting.dart`
  - `lib/features/profile/widgets/settings/subscription_setting.dart`
  - `lib/features/transactions/add_transaction_screen.dart`
  - `lib/features/transactions/widgets/transaction_period_selector.dart`
  - `lib/features/transactions/widgets/transaction_reminder_days_selector.dart`
  - `lib/features/transactions/widgets/transaction_reminder_time_selector.dart`
  - `lib/features/vaults/widgets/add_vault_sheet.dart`
  - `lib/features/vaults/widgets/detail_sheet.dart`
  - `lib/shared/widgets/custom_dialog.dart`

### CustomCard
- **İşlevi**: İnce sınırlı, mat veya cam efektli çok amaçlı ve modern bir kart bileşenidir.
- **Eski Adı**: `PrecisionCard`
- **Tanım Dosyası**: [custom_card.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/custom_card.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/dashboard/widgets/dashboard_widget_manager_sheet.dart`
  - `lib/features/optimization/optimization_screen.dart`
  - `lib/features/optimization/smart_inbox_screen.dart`
  - `lib/features/profile/profile_screen.dart`
  - `lib/features/profile/widgets/settings/currency_setting.dart`
  - `lib/features/profile/widgets/settings/exchange_rate_setting.dart`
  - `lib/features/profile/widgets/settings/subscription_setting.dart`
  - `lib/features/transactions/add_transaction_screen.dart`
  - `lib/features/vaults/widgets/detail_sheet.dart`
  - `lib/features/vaults/widgets/vault_detail_sheet.dart`
  - `lib/shared/widgets/custom_text_field.dart`

### CustomDialog
- **İşlevi**: Ekranın ortasında beliren, cam efektli (blur) ve onay/seçim işlemlerinde kullanılan pencerelerdir. `showCustomDialog` fonksiyonu aracılığıyla çağrılır.
- **Eski Adı**: `PrecisionDialog` / `showPrecisionDialog`
- **Tanım Dosyası**: [custom_dialog.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/custom_dialog.dart)
- **Kullanıldığı Yerler**:
  - Sistem onay pencereleri için genel olarak tetiklenir.

### DynamicSegmentedControl
- **İşlevi**: Seçeneklerin metin uzunluklarına göre dinamik olarak genişleyen ve yumuşak sekme animasyonları sunan segmented control bileşenidir.
- **Eski Adı**: `PrecisionFluidSegmentedControl`
- **Tanım Dosyası**: [dynamic_segmented_control.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/dynamic_segmented_control.dart)
- **Kullanıldığı Yerler**:
  - `lib/shared/widgets/selector_field.dart`

### CustomIconButton
- **İşlevi**: Minimalist tasarımlı, tıklama anında parlayan ve dokunsal geri bildirim sunan ikon butondur.
- **Eski Adı**: `PrecisionIconButton`
- **Tanım Dosyası**: [custom_icon_button.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/custom_icon_button.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/dashboard/widgets/dashboard_widget_manager_sheet.dart`
  - `lib/features/transactions/widgets/transaction_period_selector.dart`
  - `lib/features/vaults/widgets/detail_sheet.dart`
  - `lib/features/vaults/widgets/vault_detail_sheet.dart`

### InlinePicker
- **İşlevi**: Form veya listelerin içerisinde dairesel kaydırma (wheel) yaparak doğrudan seçim yapılmasını sağlayan satır arası picker bileşenidir.
- **Eski Adı**: `PrecisionInlinePicker`
- **Tanım Dosyası**: [inline_picker.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/inline_picker.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/profile/widgets/settings/purge_setting.dart`
  - `lib/features/profile/widgets/settings/retention_setting.dart`
  - `lib/shared/widgets/picker_field.dart`

### CustomTextField
- **İşlevi**: Odaklanıldığında degrade parlayan kenarlık çizgisine sahip, modern ve yarı saydam metin giriş alanıdır.
- **Eski Adı**: `PrecisionInput`
- **Tanım Dosyası**: [custom_text_field.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/custom_text_field.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/auth/screens/auth_screen.dart`
  - `lib/features/transactions/add_transaction_screen.dart`
  - `lib/features/transactions/widgets/transaction_amount_input.dart`
  - `lib/features/vaults/widgets/add_vault_sheet.dart`
  - `lib/features/vaults/widgets/vault_detail_sheet.dart`

### InsetContainer
- **İşlevi**: İçeri doğru gömülmüş (inner shadow/carved) neumorphic gölge efekti sunan derinlikli kapsayıcıdır.
- **Eski Adı**: `PrecisionInset` / `CarvedContainer`
- **Tanım Dosyası**: [inset_container.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/inset_container.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/vaults/vaults_screen.dart`

### KnobSurface
- **İşlevi**: Döner kontrolör (rotary knob) tasarımlarında kullanılmak üzere metalik, 3D gölgeli dairesel yüzey.
- **Eski Adı**: `PrecisionKnobSurface`
- **Tanım Dosyası**: [knob_surface.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/knob_surface.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/dashboard/widgets/animated_currency_selector.dart`

### MembershipOrb
- **İşlevi**: Premium üyelik ekranında kullanılan 3D görünümlü, yumuşak hareket eden ve parlayan animasyonlu küre bileşeni.
- **Eski Adı**: `PrecisionMembershipOrb`
- **Tanım Dosyası**: [membership_orb.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/membership_orb.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/dashboard/main_scaffold.dart`
  - `lib/features/optimization/widgets/setup/persona_header.dart`
  - `lib/features/profile/widgets/settings/subscription_setting.dart`
  - `lib/features/subscription/widgets/pro_upgrade_sheet.dart`

### MiniSegmentedControl
- **İşlevi**: Filtreler veya küçük alanlar için tasarlanmış kompakt, kayan göstergeli sekme seçim bileşenidir.
- **Eski Adı**: `PrecisionMiniSegmentedControl`
- **Tanım Dosyası**: [mini_segmented_control.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/mini_segmented_control.dart)
- **Kullanıldığı Yerler**:
  - Kompakt filtreleme alanlarında tercih edilir.

### MultiToggle
- **İşlevi**: Yan yana dizili butonlardan oluşan ve birden çok seçeneğin aynı anda seçilmesini sağlayan modern toggle düğme grubu.
- **Eski Adı**: `PrecisionMultiToggle`
- **Tanım Dosyası**: [multi_toggle.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/multi_toggle.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/dashboard/widgets/dashboard_widget_manager_sheet.dart`
  - `lib/features/dashboard/widgets/spending_giants_widget.dart`
  - `lib/features/optimization/widgets/setup/items_section.dart`

### CustomNotification
- **İşlevi**: Ekranın en üst kısmından akıcı bir şekilde aşağıya doğru düşen, cam efektli (blur) ve animasyonlu bildirim kartıdır.
- **Eski Adı**: `PrecisionNotification` / `showPrecisionNotification`
- **Tanım Dosyası**: [custom_notification.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/custom_notification.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/auth/screens/auth_screen.dart`
  - `lib/features/dashboard/widgets/dashboard_widget_manager_sheet.dart`
  - `lib/features/optimization/optimization_screen.dart`
  - `lib/features/optimization/smart_inbox_screen.dart`
  - `lib/features/profile/widgets/settings/exchange_rate_setting.dart`
  - `lib/features/profile/widgets/settings/reset_setting.dart`

### WheelPicker
- **İşlevi**: Slot makinesi görünümünde, dairesel kaydırma hareketiyle sayı veya metin seçilmesini sağlayan dairesel seçim bileşeni.
- **Eski Adı**: `PrecisionPicker`
- **Tanım Dosyası**: [wheel_picker.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/wheel_picker.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/optimization/optimization_screen.dart`
  - `lib/features/profile/widgets/settings/currency_setting.dart`
  - `lib/features/profile/widgets/settings/language_setting.dart`
  - `lib/features/transactions/widgets/transaction_period_selector.dart`
  - `lib/features/transactions/widgets/transaction_reminder_days_selector.dart`
  - `lib/features/transactions/widgets/transaction_reminder_time_selector.dart`

### PickerField
- **İşlevi**: Formlarda tıklandığında alt panel veya picker penceresi açan, etiketli ve ikonlu premium veri alanı bileşeni.
- **Eski Adı**: `PrecisionPickerField`
- **Tanım Dosyası**: [picker_field.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/picker_field.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/transactions/widgets/transaction_currency_selector.dart`
  - `lib/features/transactions/widgets/transaction_vault_selector.dart`

### SegmentedControl
- **İşlevi**: Kayan bir arka plan göstergesiyle seçenekler arasında yumuşak geçiş sunan standart sekme seçim çubuğu.
- **Eski Adı**: `PrecisionSegmentedControl`
- **Tanım Dosyası**: [segmented_control.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/segmented_control.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/dashboard/widgets/dashboard_widget_manager_sheet.dart`
  - `lib/features/profile/widgets/settings/subscription_setting.dart`
  - `lib/features/transactions/widgets/transaction_type_toggle.dart`
  - `lib/features/vaults/widgets/vault_detail_sheet.dart`

### SelectorField
- **İşlevi**: İkon, başlık ve segmented control seçimini tek bir form satırında birleştiren bileşik form elemanı.
- **Eski Adı**: `PrecisionSelectorField`
- **Tanım Dosyası**: [selector_field.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/selector_field.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/dashboard/widgets/dashboard_widget_manager_sheet.dart`
  - `lib/shared/widgets/picker_field.dart`

### CustomBottomSheet
- **İşlevi**: Ekranın altından yukarı doğru açılan, klavyeye duyarlı, mat ve katı arka plan rengine sahip alt panel. `showCustomBottomSheet` (veya `CustomBottomSheet.show`) fonksiyonu aracılığıyla tetiklenir.
- **Eski Adı**: `PrecisionSheet` / `showPrecisionSheet`
- **Tanım Dosyası**: [custom_bottom_sheet.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/custom_bottom_sheet.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/dashboard/widgets/vault_grid.dart`
  - `lib/features/optimization/optimization_screen.dart`
  - `lib/features/optimization/smart_inbox_screen.dart`
  - `lib/features/profile/profile_screen.dart`
  - `lib/features/profile/widgets/settings/currency_setting.dart`
  - `lib/features/profile/widgets/settings/language_setting.dart`
  - `lib/features/subscription/widgets/pro_upgrade_sheet.dart`
  - `lib/features/transactions/add_transaction_screen.dart`
  - `lib/features/transactions/widgets/transaction_period_selector.dart`
  - `lib/features/transactions/widgets/transaction_reminder_days_selector.dart`
  - `lib/features/transactions/widgets/transaction_reminder_time_selector.dart`
  - `lib/features/vaults/vaults_screen.dart`
  - `lib/features/vaults/widgets/transaction_card.dart`
  - `lib/shared/widgets/custom_dialog.dart`

### SolidSurface
- **İşlevi**: Cam/blur efekti taşımayan, mat renk geçişli ve Squircle (yuvarlatılmış kare) kavislerine sahip temel arayüz yüzey bileşeni.
- **Eski Adı**: `PrecisionSurface`
- **Tanım Dosyası**: [solid_surface.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/solid_surface.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/auth/screens/auth_screen.dart`
  - `lib/features/dashboard/widgets/dashboard_widget.dart`
  - `lib/features/dashboard/widgets/vault_grid.dart`
  - `lib/features/optimization/widgets/result/analysis_feedback_section.dart`
  - `lib/features/optimization/widgets/result/analysis_optimization_section.dart`
  - `lib/features/optimization/widgets/setup/analysis_cockpit.dart`
  - `lib/features/optimization/widgets/setup/history_section.dart`
  - `lib/features/optimization/widgets/setup/items_section.dart`
  - `lib/features/optimization/widgets/setup/optimization_loading_card.dart`
  - `lib/features/optimization/widgets/setup/persona_header.dart`
  - `lib/features/vaults/widgets/filter_chip.dart`
  - `lib/features/vaults/widgets/integrated_vault_card.dart`
  - `lib/features/vaults/widgets/in_app_notifications_sheet.dart`
  - `lib/features/vaults/widgets/transaction_card.dart`

### ThemeToggle
- **İşlevi**: Tema değişimlerini dairesel bir büyüme (reveal) animasyonuyla gerçekleştiren özel kontrol anahtarı.
- **Eski Adı**: `PrecisionThemeToggle`
- **Tanım Dosyası**: [theme_toggle.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/theme_toggle.dart)
- **Kullanıldığı Yerler**:
  - Tema ayarları sayfasında kullanılır.

### CustomSwitch
- **İşlevi**: "Jelly" (jöle) yay efekti animasyonuyla açılıp kapanan, dokunsal geri bildirimli modern Switch anahtarı.
- **Eski Adı**: `PrecisionToggle`
- **Tanım Dosyası**: [custom_switch.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/custom_switch.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/profile/widgets/profile_list_items.dart`
  - `lib/features/profile/widgets/settings/location_setting.dart`
  - `lib/features/profile/widgets/settings/notification_setting.dart`
  - `lib/features/profile/widgets/settings/sync_setting.dart`
  - `lib/features/transactions/add_transaction_screen.dart`
  - `lib/features/vaults/widgets/detail_sheet.dart`
  - `lib/features/vaults/widgets/vault_detail_sheet.dart`

### GlassSurface
- **İşlevi**: Gerçek cam efekti (BackdropFilter blur ve yarı saydamlık) sunan, projedeki cam tasarımların merkezi bileşeni.
- **Tanım Dosyası**: [glass_surface.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/shared/widgets/glass_surface.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/dashboard/main_scaffold.dart`
  - `lib/shared/widgets/custom_dialog.dart`
  - `lib/shared/widgets/custom_notification.dart`

---

## 2. Özelliğe Özel Bileşenler (`lib/features/`)

### AuthBackground
- **İşlevi**: Giriş/Kayıt ekranlarında arka planda süzülen parçacıklı ve degrade geçişli hareketli arka plan bileşeni.
- **Eski Adı**: `PrecisionBackground`
- **Tanım Dosyası**: [auth_background.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/features/auth/widgets/auth_background.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/auth/screens/auth_screen.dart`
  - `lib/features/dashboard/main_scaffold.dart`
  - `lib/features/optimization/analysis_detail_screen.dart`
  - `lib/features/optimization/smart_inbox_screen.dart`
  - `lib/features/transactions/add_transaction_screen.dart`

### FlipCard
- **İşlevi**: Giriş ve Kayıt formları arasında geçiş yaparken 3D kart dönme efekti uygulayan sarmalayıcı.
- **Eski Adı**: `PrecisionFlipCard`
- **Tanım Dosyası**: [flip_card.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/features/auth/widgets/flip_card.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/auth/screens/auth_screen.dart`

### AuthWave
- **İşlevi**: Giriş ve kasa işlemlerinde arka planda parlayan dinamik dalga/ışık animasyonunu sağlayan bileşen.
- **Eski Adı**: `PrecisionWave`
- **Tanım Dosyası**: [auth_wave.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/features/auth/widgets/auth_wave.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/vaults/widgets/add_vault_sheet.dart`

### VaultGrid
- **İşlevi**: Dashboard üzerinde kasaları ızgara düzeninde yerleştiren ve listeleyen bileşen.
- **Eski Adı**: `PrecisionVaultGrid`
- **Tanım Dosyası**: [vault_grid.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/features/dashboard/widgets/vault_grid.dart)
- **Kullanıldığı Yerler**:
  - Dashboard sayfası ana gövdesi.

### AmbientBlob
- **İşlevi**: Kasa detay sayfalarında arka planda süzülen ve atmosfere derinlik katan renkli bulanık küreler.
- **Eski Adı**: `PrecisionBlob`
- **Tanım Dosyası**: [ambient_blob.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/features/vaults/widgets/ambient_blob.dart)
- **Kullanıldığı Yerler**:
  - Kasa detay ekranları.

### DetailSheet
- **İşlevi**: Kasa detaylarının, grafiklerin ve analizlerin gösterildiği özelleştirilmiş alt panel bileşenidir.
- **Eski Adı**: `PrecisionDetailSheet`
- **Tanım Dosyası**: [detail_sheet.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/features/vaults/widgets/detail_sheet.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/vaults/vaults_screen.dart`
  - `lib/features/vaults/widgets/transaction_card.dart`

### TransactionCard
- **İşlevi**: Kasa hareketlerindeki gelir/gider işlemlerini şık ve minimalist bir şekilde listeleyen kart bileşenidir.
- **Eski Adı**: `PrecisionTransactionCard`
- **Tanım Dosyası**: [transaction_card.dart](file:///c:/Users/Yasir2.Prenses/Finarcast/lib/features/vaults/widgets/transaction_card.dart)
- **Kullanıldığı Yerler**:
  - `lib/features/vaults/vaults_screen.dart`
