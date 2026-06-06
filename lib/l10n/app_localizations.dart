import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @preferences.
  ///
  /// In tr, this message translates to:
  /// **'TERCİHLER & UYGULAMA'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @dataRetention.
  ///
  /// In tr, this message translates to:
  /// **'Veri Saklama'**
  String get dataRetention;

  /// No description provided for @permanentDataDeletion.
  ///
  /// In tr, this message translates to:
  /// **'Kalıcı Silme'**
  String get permanentDataDeletion;

  /// No description provided for @oneMonth.
  ///
  /// In tr, this message translates to:
  /// **'1 Ay'**
  String get oneMonth;

  /// No description provided for @threeMonths.
  ///
  /// In tr, this message translates to:
  /// **'3 Ay'**
  String get threeMonths;

  /// No description provided for @sixMonths.
  ///
  /// In tr, this message translates to:
  /// **'6 Ay'**
  String get sixMonths;

  /// No description provided for @oneYear.
  ///
  /// In tr, this message translates to:
  /// **'1 Yıl'**
  String get oneYear;

  /// No description provided for @infinite.
  ///
  /// In tr, this message translates to:
  /// **'Sonsuz'**
  String get infinite;

  /// No description provided for @driveBackup.
  ///
  /// In tr, this message translates to:
  /// **'Drive Yedekleme'**
  String get driveBackup;

  /// No description provided for @exportExcel.
  ///
  /// In tr, this message translates to:
  /// **'Excel\'e Aktar'**
  String get exportExcel;

  /// No description provided for @support.
  ///
  /// In tr, this message translates to:
  /// **'DESTEK'**
  String get support;

  /// No description provided for @contact.
  ///
  /// In tr, this message translates to:
  /// **'İletişim'**
  String get contact;

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// No description provided for @aboutFinarcast.
  ///
  /// In tr, this message translates to:
  /// **'Finarcast, AI destekli finansal asistanınızdır. Harcamalarınızı analiz eder, tasarruf hedefleri belirlemenize yardımcı olur ve finansal geleceğinizi optimize eder.'**
  String get aboutFinarcast;

  /// No description provided for @comingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Bu özellik yakında gelecek!'**
  String get comingSoon;

  /// No description provided for @selectLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Dili Seçin'**
  String get selectLanguage;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// No description provided for @home.
  ///
  /// In tr, this message translates to:
  /// **'Panel'**
  String get home;

  /// No description provided for @vaults.
  ///
  /// In tr, this message translates to:
  /// **'Kasalar'**
  String get vaults;

  /// No description provided for @analysis.
  ///
  /// In tr, this message translates to:
  /// **'Analiz'**
  String get analysis;

  /// No description provided for @totalBalance.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Bakiye'**
  String get totalBalance;

  /// No description provided for @addNewVault.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kasa Ekle'**
  String get addNewVault;

  /// No description provided for @addTransaction.
  ///
  /// In tr, this message translates to:
  /// **'Yeni İşlem'**
  String get addTransaction;

  /// No description provided for @income.
  ///
  /// In tr, this message translates to:
  /// **'Gelir'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In tr, this message translates to:
  /// **'Gider'**
  String get expense;

  /// No description provided for @amount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar'**
  String get amount;

  /// No description provided for @currency.
  ///
  /// In tr, this message translates to:
  /// **'Para Birimi'**
  String get currency;

  /// No description provided for @description.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get description;

  /// No description provided for @done.
  ///
  /// In tr, this message translates to:
  /// **'Bitti'**
  String get done;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @mainVault.
  ///
  /// In tr, this message translates to:
  /// **'Ana Kasa'**
  String get mainVault;

  /// No description provided for @newVault.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kasa'**
  String get newVault;

  /// No description provided for @all.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get all;

  /// No description provided for @allTime.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Zamanlar'**
  String get allTime;

  /// No description provided for @oneTime.
  ///
  /// In tr, this message translates to:
  /// **'Tek Seferlik'**
  String get oneTime;

  /// No description provided for @weekly.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık'**
  String get weekly;

  /// No description provided for @every2Weeks.
  ///
  /// In tr, this message translates to:
  /// **'2 Haftada Bir'**
  String get every2Weeks;

  /// No description provided for @every3Weeks.
  ///
  /// In tr, this message translates to:
  /// **'3 Haftada Bir'**
  String get every3Weeks;

  /// No description provided for @monthly.
  ///
  /// In tr, this message translates to:
  /// **'Aylık'**
  String get monthly;

  /// No description provided for @every3Months.
  ///
  /// In tr, this message translates to:
  /// **'3 Ayda Bir'**
  String get every3Months;

  /// No description provided for @every6Months.
  ///
  /// In tr, this message translates to:
  /// **'6 Ayda Bir'**
  String get every6Months;

  /// No description provided for @yearly.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık'**
  String get yearly;

  /// No description provided for @period.
  ///
  /// In tr, this message translates to:
  /// **'Periyot'**
  String get period;

  /// No description provided for @week.
  ///
  /// In tr, this message translates to:
  /// **'Hafta'**
  String get week;

  /// No description provided for @month.
  ///
  /// In tr, this message translates to:
  /// **'Ay'**
  String get month;

  /// No description provided for @year.
  ///
  /// In tr, this message translates to:
  /// **'Yıl'**
  String get year;

  /// No description provided for @targetDate.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Tarih'**
  String get targetDate;

  /// No description provided for @category.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get category;

  /// No description provided for @themeMode.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In tr, this message translates to:
  /// **'Aydınlık'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık'**
  String get themeDark;

  /// No description provided for @colorTheme.
  ///
  /// In tr, this message translates to:
  /// **'Renk'**
  String get colorTheme;

  /// No description provided for @food.
  ///
  /// In tr, this message translates to:
  /// **'Gıda'**
  String get food;

  /// No description provided for @cleaning.
  ///
  /// In tr, this message translates to:
  /// **'Temizlik'**
  String get cleaning;

  /// No description provided for @grocery.
  ///
  /// In tr, this message translates to:
  /// **'Market/Gıda'**
  String get grocery;

  /// No description provided for @delivery.
  ///
  /// In tr, this message translates to:
  /// **'Paket Servis'**
  String get delivery;

  /// No description provided for @gas.
  ///
  /// In tr, this message translates to:
  /// **'Doğalgaz/Yakıt'**
  String get gas;

  /// No description provided for @duration.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş Süresi'**
  String get duration;

  /// No description provided for @repeatsIndefinitely.
  ///
  /// In tr, this message translates to:
  /// **'Sürekli Tekrar Eder'**
  String get repeatsIndefinitely;

  /// No description provided for @endsAfter.
  ///
  /// In tr, this message translates to:
  /// **'Sonra Biter'**
  String get endsAfter;

  /// No description provided for @minimum.
  ///
  /// In tr, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @maximum.
  ///
  /// In tr, this message translates to:
  /// **'Maksimum'**
  String get maximum;

  /// No description provided for @dayOfWeek.
  ///
  /// In tr, this message translates to:
  /// **'Haftanın Günü'**
  String get dayOfWeek;

  /// No description provided for @dayOfMonth.
  ///
  /// In tr, this message translates to:
  /// **'Ayın Günü'**
  String get dayOfMonth;

  /// No description provided for @dayOf.
  ///
  /// In tr, this message translates to:
  /// **'Günü'**
  String get dayOf;

  /// No description provided for @dining.
  ///
  /// In tr, this message translates to:
  /// **'Yemek'**
  String get dining;

  /// No description provided for @restaurant.
  ///
  /// In tr, this message translates to:
  /// **'Restoran'**
  String get restaurant;

  /// No description provided for @cafe.
  ///
  /// In tr, this message translates to:
  /// **'Kafe'**
  String get cafe;

  /// No description provided for @rent.
  ///
  /// In tr, this message translates to:
  /// **'Kira'**
  String get rent;

  /// No description provided for @office.
  ///
  /// In tr, this message translates to:
  /// **'Ofis'**
  String get office;

  /// No description provided for @storage.
  ///
  /// In tr, this message translates to:
  /// **'Depo'**
  String get storage;

  /// No description provided for @bill.
  ///
  /// In tr, this message translates to:
  /// **'Fatura'**
  String get bill;

  /// No description provided for @electricity.
  ///
  /// In tr, this message translates to:
  /// **'Elektrik'**
  String get electricity;

  /// No description provided for @water.
  ///
  /// In tr, this message translates to:
  /// **'Su'**
  String get water;

  /// No description provided for @internet.
  ///
  /// In tr, this message translates to:
  /// **'İnternet'**
  String get internet;

  /// No description provided for @phone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get phone;

  /// No description provided for @cinema.
  ///
  /// In tr, this message translates to:
  /// **'Sinema'**
  String get cinema;

  /// No description provided for @concert.
  ///
  /// In tr, this message translates to:
  /// **'Konser'**
  String get concert;

  /// No description provided for @game.
  ///
  /// In tr, this message translates to:
  /// **'Oyun'**
  String get game;

  /// No description provided for @event.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik'**
  String get event;

  /// No description provided for @subscription.
  ///
  /// In tr, this message translates to:
  /// **'Abonelik'**
  String get subscription;

  /// No description provided for @software.
  ///
  /// In tr, this message translates to:
  /// **'Yazılım'**
  String get software;

  /// No description provided for @gym.
  ///
  /// In tr, this message translates to:
  /// **'Spor Salonu'**
  String get gym;

  /// No description provided for @health.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık'**
  String get health;

  /// No description provided for @doctor.
  ///
  /// In tr, this message translates to:
  /// **'Doktor'**
  String get doctor;

  /// No description provided for @medicine.
  ///
  /// In tr, this message translates to:
  /// **'İlaç'**
  String get medicine;

  /// No description provided for @surgery.
  ///
  /// In tr, this message translates to:
  /// **'Ameliyat'**
  String get surgery;

  /// No description provided for @dentist.
  ///
  /// In tr, this message translates to:
  /// **'Diş Hekimi'**
  String get dentist;

  /// No description provided for @taxi.
  ///
  /// In tr, this message translates to:
  /// **'Taksi'**
  String get taxi;

  /// No description provided for @bus.
  ///
  /// In tr, this message translates to:
  /// **'Otobüs'**
  String get bus;

  /// No description provided for @train.
  ///
  /// In tr, this message translates to:
  /// **'Tren'**
  String get train;

  /// No description provided for @flight.
  ///
  /// In tr, this message translates to:
  /// **'Uçak'**
  String get flight;

  /// No description provided for @fuel.
  ///
  /// In tr, this message translates to:
  /// **'Yakıt'**
  String get fuel;

  /// No description provided for @shoes.
  ///
  /// In tr, this message translates to:
  /// **'Ayakkabı'**
  String get shoes;

  /// No description provided for @course.
  ///
  /// In tr, this message translates to:
  /// **'Kurs'**
  String get course;

  /// No description provided for @book.
  ///
  /// In tr, this message translates to:
  /// **'Kitap'**
  String get book;

  /// No description provided for @school.
  ///
  /// In tr, this message translates to:
  /// **'Okul'**
  String get school;

  /// No description provided for @loan.
  ///
  /// In tr, this message translates to:
  /// **'Kredi'**
  String get loan;

  /// No description provided for @credit.
  ///
  /// In tr, this message translates to:
  /// **'Kredi/Borç'**
  String get credit;

  /// No description provided for @other.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get other;

  /// No description provided for @balanceAdjustment.
  ///
  /// In tr, this message translates to:
  /// **'Bakiye Düzeltme'**
  String get balanceAdjustment;

  /// No description provided for @balanceAdjustmentNote.
  ///
  /// In tr, this message translates to:
  /// **'Kasa bakiyesi {oldVal} değerinden {newVal} değerine eşitlendi.'**
  String balanceAdjustmentNote(Object newVal, Object oldVal);

  /// No description provided for @salary.
  ///
  /// In tr, this message translates to:
  /// **'Maaş'**
  String get salary;

  /// No description provided for @bonus.
  ///
  /// In tr, this message translates to:
  /// **'Prim/Bonus'**
  String get bonus;

  /// No description provided for @dividend.
  ///
  /// In tr, this message translates to:
  /// **'Temettü'**
  String get dividend;

  /// No description provided for @freelance.
  ///
  /// In tr, this message translates to:
  /// **'Serbest Çalışma'**
  String get freelance;

  /// No description provided for @commission.
  ///
  /// In tr, this message translates to:
  /// **'Komisyon'**
  String get commission;

  /// No description provided for @stock.
  ///
  /// In tr, this message translates to:
  /// **'Hisse Senedi'**
  String get stock;

  /// No description provided for @crypto.
  ///
  /// In tr, this message translates to:
  /// **'Kripto Para'**
  String get crypto;

  /// No description provided for @interest.
  ///
  /// In tr, this message translates to:
  /// **'Faiz'**
  String get interest;

  /// No description provided for @scholarship.
  ///
  /// In tr, this message translates to:
  /// **'Burs'**
  String get scholarship;

  /// No description provided for @sale.
  ///
  /// In tr, this message translates to:
  /// **'Satış'**
  String get sale;

  /// No description provided for @gift.
  ///
  /// In tr, this message translates to:
  /// **'Hediye'**
  String get gift;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @everyDay.
  ///
  /// In tr, this message translates to:
  /// **'Her Gün'**
  String get everyDay;

  /// No description provided for @everyWeek.
  ///
  /// In tr, this message translates to:
  /// **'Her Hafta'**
  String get everyWeek;

  /// No description provided for @everyMonth.
  ///
  /// In tr, this message translates to:
  /// **'Her Ay'**
  String get everyMonth;

  /// No description provided for @day.
  ///
  /// In tr, this message translates to:
  /// **'Gün'**
  String get day;

  /// No description provided for @twoDays.
  ///
  /// In tr, this message translates to:
  /// **'2 Gün'**
  String get twoDays;

  /// No description provided for @threeDays.
  ///
  /// In tr, this message translates to:
  /// **'3 Gün'**
  String get threeDays;

  /// No description provided for @flexibleAmount.
  ///
  /// In tr, this message translates to:
  /// **'Esnek Tutar'**
  String get flexibleAmount;

  /// No description provided for @monday.
  ///
  /// In tr, this message translates to:
  /// **'Pazartesi'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In tr, this message translates to:
  /// **'Salı'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In tr, this message translates to:
  /// **'Çarşamba'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In tr, this message translates to:
  /// **'Perşembe'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In tr, this message translates to:
  /// **'Cuma'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In tr, this message translates to:
  /// **'Cumartesi'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In tr, this message translates to:
  /// **'Pazar'**
  String get sunday;

  /// No description provided for @january.
  ///
  /// In tr, this message translates to:
  /// **'Ocak'**
  String get january;

  /// No description provided for @february.
  ///
  /// In tr, this message translates to:
  /// **'Şubat'**
  String get february;

  /// No description provided for @march.
  ///
  /// In tr, this message translates to:
  /// **'Mart'**
  String get march;

  /// No description provided for @april.
  ///
  /// In tr, this message translates to:
  /// **'Nisan'**
  String get april;

  /// No description provided for @may.
  ///
  /// In tr, this message translates to:
  /// **'Mayıs'**
  String get may;

  /// No description provided for @june.
  ///
  /// In tr, this message translates to:
  /// **'Haziran'**
  String get june;

  /// No description provided for @july.
  ///
  /// In tr, this message translates to:
  /// **'Temmuz'**
  String get july;

  /// No description provided for @august.
  ///
  /// In tr, this message translates to:
  /// **'Ağustos'**
  String get august;

  /// No description provided for @september.
  ///
  /// In tr, this message translates to:
  /// **'Eylül'**
  String get september;

  /// No description provided for @october.
  ///
  /// In tr, this message translates to:
  /// **'Ekim'**
  String get october;

  /// No description provided for @november.
  ///
  /// In tr, this message translates to:
  /// **'Kasım'**
  String get november;

  /// No description provided for @december.
  ///
  /// In tr, this message translates to:
  /// **'Aralık'**
  String get december;

  /// No description provided for @selectDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Seç'**
  String get selectDate;

  /// No description provided for @allVaults.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Kasalar'**
  String get allVaults;

  /// No description provided for @items.
  ///
  /// In tr, this message translates to:
  /// **'Kalemler'**
  String get items;

  /// No description provided for @expenses.
  ///
  /// In tr, this message translates to:
  /// **'GİDERLER'**
  String get expenses;

  /// No description provided for @incomes.
  ///
  /// In tr, this message translates to:
  /// **'GELİRLER'**
  String get incomes;

  /// No description provided for @currentBalance.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Bakiye'**
  String get currentBalance;

  /// No description provided for @score.
  ///
  /// In tr, this message translates to:
  /// **'SKOR'**
  String get score;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @vault.
  ///
  /// In tr, this message translates to:
  /// **'Kasa'**
  String get vault;

  /// No description provided for @vaultDetail.
  ///
  /// In tr, this message translates to:
  /// **'Kasa Detayı'**
  String get vaultDetail;

  /// No description provided for @vaultNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Kasa Adı (örn. Birikim)'**
  String get vaultNameHint;

  /// No description provided for @initialBalance.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Bakiyesi'**
  String get initialBalance;

  /// No description provided for @createVault.
  ///
  /// In tr, this message translates to:
  /// **'Kasa Oluştur'**
  String get createVault;

  /// No description provided for @transactions.
  ///
  /// In tr, this message translates to:
  /// **'İşlemler'**
  String get transactions;

  /// No description provided for @manage.
  ///
  /// In tr, this message translates to:
  /// **'Yönet'**
  String get manage;

  /// No description provided for @deleteVault.
  ///
  /// In tr, this message translates to:
  /// **'Kasayı Sil'**
  String get deleteVault;

  /// No description provided for @deleteVaultConfirm.
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" kasasını silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'**
  String deleteVaultConfirm(String name);

  /// No description provided for @gold.
  ///
  /// In tr, this message translates to:
  /// **'ALTIN'**
  String get gold;

  /// No description provided for @amountNotEntered.
  ///
  /// In tr, this message translates to:
  /// **'TUTAR GİRİLMEDİ'**
  String get amountNotEntered;

  /// No description provided for @addAmountByEditing.
  ///
  /// In tr, this message translates to:
  /// **'Düzenleyerek tutar ekleyin'**
  String get addAmountByEditing;

  /// No description provided for @added.
  ///
  /// In tr, this message translates to:
  /// **'Eklendi'**
  String get added;

  /// No description provided for @endDate.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş Tarihi'**
  String get endDate;

  /// No description provided for @occurred.
  ///
  /// In tr, this message translates to:
  /// **'Gerçekleşen'**
  String get occurred;

  /// No description provided for @remainingCount.
  ///
  /// In tr, this message translates to:
  /// **'Kalan Sayısı'**
  String get remainingCount;

  /// No description provided for @times.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 Kez} other{{count} Kez}}'**
  String times(num count);

  /// No description provided for @note.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get note;

  /// No description provided for @indefinitely.
  ///
  /// In tr, this message translates to:
  /// **'Sürekli'**
  String get indefinitely;

  /// No description provided for @dayOfMonthOrdinal.
  ///
  /// In tr, this message translates to:
  /// **'Ayın {day}\'i'**
  String dayOfMonthOrdinal(Object day);

  /// No description provided for @everyWeekDetailed.
  ///
  /// In tr, this message translates to:
  /// **'Her hafta'**
  String get everyWeekDetailed;

  /// No description provided for @everyMonthDetailed.
  ///
  /// In tr, this message translates to:
  /// **'Her ay'**
  String get everyMonthDetailed;

  /// No description provided for @everyYearDetailed.
  ///
  /// In tr, this message translates to:
  /// **'Her yıl'**
  String get everyYearDetailed;

  /// No description provided for @everyDayDetailed.
  ///
  /// In tr, this message translates to:
  /// **'Her gün'**
  String get everyDayDetailed;

  /// No description provided for @custom.
  ///
  /// In tr, this message translates to:
  /// **'Özel'**
  String get custom;

  /// No description provided for @status.
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get status;

  /// No description provided for @pending.
  ///
  /// In tr, this message translates to:
  /// **'Bekliyor'**
  String get pending;

  /// No description provided for @removeFromVault.
  ///
  /// In tr, this message translates to:
  /// **'Kasadan Çıkar'**
  String get removeFromVault;

  /// No description provided for @permanentDelete.
  ///
  /// In tr, this message translates to:
  /// **'Kalıcı Sil'**
  String get permanentDelete;

  /// No description provided for @permanentDeleteDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem kalıcı olarak silinecek'**
  String get permanentDeleteDesc;

  /// No description provided for @yes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No description provided for @minAmount.
  ///
  /// In tr, this message translates to:
  /// **'Min.'**
  String get minAmount;

  /// No description provided for @maxAmount.
  ///
  /// In tr, this message translates to:
  /// **'Maks.'**
  String get maxAmount;

  /// No description provided for @netBalance.
  ///
  /// In tr, this message translates to:
  /// **'Net Bakiye'**
  String get netBalance;

  /// No description provided for @bestCase.
  ///
  /// In tr, this message translates to:
  /// **'En İyi Senaryo'**
  String get bestCase;

  /// No description provided for @worstCase.
  ///
  /// In tr, this message translates to:
  /// **'En Kötü Senaryo'**
  String get worstCase;

  /// No description provided for @selectCurrency.
  ///
  /// In tr, this message translates to:
  /// **'Para Birimi Seçin'**
  String get selectCurrency;

  /// No description provided for @upgrade.
  ///
  /// In tr, this message translates to:
  /// **'Yükselt'**
  String get upgrade;

  /// No description provided for @auto.
  ///
  /// In tr, this message translates to:
  /// **'OTOMATİK'**
  String get auto;

  /// No description provided for @max.
  ///
  /// In tr, this message translates to:
  /// **'MAX'**
  String get max;

  /// No description provided for @zero.
  ///
  /// In tr, this message translates to:
  /// **'0'**
  String get zero;

  /// No description provided for @addCustomCategory.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Ekle'**
  String get addCustomCategory;

  /// No description provided for @customCategoryHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Baharat, Deterjan...'**
  String get customCategoryHint;

  /// No description provided for @deleteCustomCategory.
  ///
  /// In tr, this message translates to:
  /// **'Özel Kategoriyi Sil'**
  String get deleteCustomCategory;

  /// No description provided for @deleteCustomCategoryConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu özel kategoriyi silmek istediğinize emin misiniz?'**
  String get deleteCustomCategoryConfirm;

  /// No description provided for @dashboard.
  ///
  /// In tr, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @library.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphane'**
  String get library;

  /// No description provided for @pageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa'**
  String get pageLabel;

  /// No description provided for @historyTitle.
  ///
  /// In tr, this message translates to:
  /// **'İşlem Geçmişi'**
  String get historyTitle;

  /// No description provided for @radarTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Radarı'**
  String get radarTitle;

  /// No description provided for @giantsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Devleri'**
  String get giantsTitle;

  /// No description provided for @dailyLimit.
  ///
  /// In tr, this message translates to:
  /// **'GÜNLÜK LİMİT'**
  String get dailyLimit;

  /// No description provided for @spendableRemaining.
  ///
  /// In tr, this message translates to:
  /// **'Harcanabilir Kalan'**
  String get spendableRemaining;

  /// No description provided for @giantsWait.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Dağılımı Bekleniyor'**
  String get giantsWait;

  /// No description provided for @weeklyShort.
  ///
  /// In tr, this message translates to:
  /// **'H'**
  String get weeklyShort;

  /// No description provided for @monthlyShort.
  ///
  /// In tr, this message translates to:
  /// **'A'**
  String get monthlyShort;

  /// No description provided for @yearlyShort.
  ///
  /// In tr, this message translates to:
  /// **'Y'**
  String get yearlyShort;

  /// No description provided for @newLabel.
  ///
  /// In tr, this message translates to:
  /// **'YENİ'**
  String get newLabel;

  /// No description provided for @today.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In tr, this message translates to:
  /// **'Yarın'**
  String get tomorrow;

  /// No description provided for @daysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count} Gün Önce'**
  String daysAgo(int count);

  /// No description provided for @weeksAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count} Hafta Önce'**
  String weeksAgo(int count);

  /// No description provided for @monthsAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count} Ay Önce'**
  String monthsAgo(int count);

  /// No description provided for @historyEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz işlem geçmişi yok'**
  String get historyEmpty;

  /// No description provided for @upcomingPaymentsNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan ödeme bulunamadı'**
  String get upcomingPaymentsNotFound;

  /// No description provided for @transaction.
  ///
  /// In tr, this message translates to:
  /// **'İşlem'**
  String get transaction;

  /// No description provided for @membership.
  ///
  /// In tr, this message translates to:
  /// **'ÜYELİK'**
  String get membership;

  /// No description provided for @restorePurchases.
  ///
  /// In tr, this message translates to:
  /// **'Satın Almaları Geri Yükle'**
  String get restorePurchases;

  /// No description provided for @freePlan.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz Plan'**
  String get freePlan;

  /// No description provided for @upgradeToPro.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a Yükselt'**
  String get upgradeToPro;

  /// No description provided for @unlimitedVaults.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız Kasa'**
  String get unlimitedVaults;

  /// No description provided for @active.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif Değil'**
  String get inactive;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @disabled.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get disabled;

  /// No description provided for @monthlyNetBalance.
  ///
  /// In tr, this message translates to:
  /// **'AYLIK NET BAKİYE'**
  String get monthlyNetBalance;

  /// No description provided for @savingsRate.
  ///
  /// In tr, this message translates to:
  /// **'TASARRUF ORANI'**
  String get savingsRate;

  /// No description provided for @yearlyProjection.
  ///
  /// In tr, this message translates to:
  /// **'YILLIK PROJEKSİYON'**
  String get yearlyProjection;

  /// No description provided for @topExpense.
  ///
  /// In tr, this message translates to:
  /// **'EN BÜYÜK GİDER'**
  String get topExpense;

  /// No description provided for @topIncome.
  ///
  /// In tr, this message translates to:
  /// **'EN BÜYÜK GELİR'**
  String get topIncome;

  /// No description provided for @transactionBreakdown.
  ///
  /// In tr, this message translates to:
  /// **'İŞLEM DAĞILIMI'**
  String get transactionBreakdown;

  /// No description provided for @incomeCount.
  ///
  /// In tr, this message translates to:
  /// **'Gelir'**
  String get incomeCount;

  /// No description provided for @expenseCount.
  ///
  /// In tr, this message translates to:
  /// **'Gider'**
  String get expenseCount;

  /// No description provided for @scenarioAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'SENARYO ANALİZİ'**
  String get scenarioAnalysis;

  /// No description provided for @monthlyBest.
  ///
  /// In tr, this message translates to:
  /// **'AYLIK EN İYİ'**
  String get monthlyBest;

  /// No description provided for @monthlyWorst.
  ///
  /// In tr, this message translates to:
  /// **'AYLIK EN KÖTÜ'**
  String get monthlyWorst;

  /// No description provided for @yearlyBest.
  ///
  /// In tr, this message translates to:
  /// **'YILLIK EN İYİ'**
  String get yearlyBest;

  /// No description provided for @yearlyWorst.
  ///
  /// In tr, this message translates to:
  /// **'YILLIK EN KÖTÜ'**
  String get yearlyWorst;

  /// No description provided for @perMonth.
  ///
  /// In tr, this message translates to:
  /// **'/ay'**
  String get perMonth;

  /// No description provided for @itemCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Kalem'**
  String itemCount(int count);

  /// No description provided for @authEmailRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen e-posta adresinizi girin.'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir e-posta adresi girin.'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen şifrenizi girin.'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Şifreniz en az 6 karakterden oluşmalıdır.'**
  String get authPasswordTooShort;

  /// No description provided for @authConfirmPasswordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen şifrenizi tekrar girin.'**
  String get authConfirmPasswordRequired;

  /// No description provided for @authPasswordsDoNotMatch.
  ///
  /// In tr, this message translates to:
  /// **'Girdiğiniz şifreler birbiriyle eşleşmiyor.'**
  String get authPasswordsDoNotMatch;

  /// No description provided for @authUsernameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir kullanıcı adı belirleyin.'**
  String get authUsernameRequired;

  /// No description provided for @authUsernameTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı en az 3 karakterden oluşmalıdır.'**
  String get authUsernameTooShort;

  /// No description provided for @authUsernameInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı yalnızca harf, rakam ve alt çizgi (_) içerebilir.'**
  String get authUsernameInvalid;

  /// No description provided for @authUsernameTaken.
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcı adı zaten alınmış.'**
  String get authUsernameTaken;

  /// No description provided for @authEmailNotConfirmed.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresiniz henüz doğrulanmamış. Lütfen e-postanıza gönderilen doğrulama kodunu girin veya tekrar kod isteyin.'**
  String get authEmailNotConfirmed;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresiniz veya şifreniz hatalı.'**
  String get authInvalidCredentials;

  /// No description provided for @authEmailExists.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresiyle zaten bir kayıtlı hesap bulunuyor.'**
  String get authEmailExists;

  /// No description provided for @authWeakPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreniz çok zayıf. Lütfen en az 6 karakterli daha güçlü bir şifre girin.'**
  String get authWeakPassword;

  /// No description provided for @authBadCode.
  ///
  /// In tr, this message translates to:
  /// **'Girdiğiniz doğrulama kodu hatalı veya geçersiz.'**
  String get authBadCode;

  /// No description provided for @authSignupDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Yeni kullanıcı kaydı şu anda devre dışıdır. Lütfen yöneticiyle iletişime geçin.'**
  String get authSignupDisabled;

  /// No description provided for @authRateLimitExceeded.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla istek gönderildi. E-posta limitini aştınız, lütfen bir süre bekleyip tekrar deneyin.'**
  String get authRateLimitExceeded;

  /// No description provided for @authOtpRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen gelen 6 haneli doğrulama kodunu girin.'**
  String get authOtpRequired;

  /// No description provided for @authOtpSent.
  ///
  /// In tr, this message translates to:
  /// **'Yeni doğrulama kodu e-postanıza gönderildi.'**
  String get authOtpSent;

  /// No description provided for @authRegistrationSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarılı! Lütfen e-postanıza gelen doğrulama kodunu girin.'**
  String get authRegistrationSuccess;

  /// No description provided for @authVerificationCode.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama Kodu'**
  String get authVerificationCode;

  /// No description provided for @authVerificationDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt işlemini tamamlamak için {email} adresine gönderilen doğrulama kodunu girin.'**
  String authVerificationDesc(String email);

  /// No description provided for @authVerifyCode.
  ///
  /// In tr, this message translates to:
  /// **'Kodu Doğrula'**
  String get authVerifyCode;

  /// No description provided for @authResendCodeCountdown.
  ///
  /// In tr, this message translates to:
  /// **'Kodu Tekrar Gönder ({seconds} sn)'**
  String authResendCodeCountdown(int seconds);

  /// No description provided for @authResendCode.
  ///
  /// In tr, this message translates to:
  /// **'Kodu Tekrar Gönder'**
  String get authResendCode;

  /// No description provided for @authGoBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri Dön'**
  String get authGoBack;

  /// No description provided for @authWelcome.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz'**
  String get authWelcome;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınıza giriş yaparak finanslarınıza hükmedin.'**
  String get authLoginSubtitle;

  /// No description provided for @authEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get authPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get authForgotPassword;

  /// No description provided for @authLogin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get authLogin;

  /// No description provided for @authOr.
  ///
  /// In tr, this message translates to:
  /// **'Veya'**
  String get authOr;

  /// No description provided for @authGoogleSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Devam Et'**
  String get authGoogleSignIn;

  /// No description provided for @authNewAccount.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Hesap'**
  String get authNewAccount;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Finarcast dünyasına katılarak limitlerinizi belirleyin.'**
  String get authRegisterSubtitle;

  /// No description provided for @authUsername.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Adı'**
  String get authUsername;

  /// No description provided for @authConfirmPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Tekrar'**
  String get authConfirmPassword;

  /// No description provided for @authRegister.
  ///
  /// In tr, this message translates to:
  /// **'Hemen Katıl'**
  String get authRegister;

  /// No description provided for @authNoAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız yok mu?'**
  String get authNoAccount;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabınız var mı?'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authRegisterAction.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get authRegisterAction;

  /// No description provided for @authLoginAction.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get authLoginAction;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In tr, this message translates to:
  /// **'Misafir Olarak Devam Et'**
  String get authContinueAsGuest;

  /// No description provided for @authPasswordReset.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Sıfırlama'**
  String get authPasswordReset;

  /// No description provided for @authForgotPasswordDesc.
  ///
  /// In tr, this message translates to:
  /// **'Şifrenizi sıfırlamak için e-posta adresinizi girin. Size 6 haneli geçici bir kod göndereceğiz.'**
  String get authForgotPasswordDesc;

  /// No description provided for @authSendCode.
  ///
  /// In tr, this message translates to:
  /// **'Kod Gönder'**
  String get authSendCode;

  /// No description provided for @authBackToLogin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Ekranına Dön'**
  String get authBackToLogin;

  /// No description provided for @authVerificationCodeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Onay Kodu'**
  String get authVerificationCodeTitle;

  /// No description provided for @authForgotPasswordOtpDesc.
  ///
  /// In tr, this message translates to:
  /// **'{email} adresine gönderilen 6 haneli doğrulama kodunu girin.'**
  String authForgotPasswordOtpDesc(String email);

  /// No description provided for @authChangeEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Değiştir'**
  String get authChangeEmail;

  /// No description provided for @authNewPasswordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre'**
  String get authNewPasswordTitle;

  /// No description provided for @authNewPasswordDesc.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız için en az 6 karakterli güvenli bir şifre belirleyin.'**
  String get authNewPasswordDesc;

  /// No description provided for @authNewPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre'**
  String get authNewPassword;

  /// No description provided for @authConfirmNewPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre Tekrar'**
  String get authConfirmNewPassword;

  /// No description provided for @authUpdatePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Güncelle'**
  String get authUpdatePassword;

  /// No description provided for @authPasswordResetSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Şifreniz başarıyla sıfırlandı ve giriş yapıldı.'**
  String get authPasswordResetSuccess;

  /// No description provided for @authGoogleError.
  ///
  /// In tr, this message translates to:
  /// **'Google Giriş Hatası'**
  String get authGoogleError;

  /// No description provided for @authPasswordDifferentError.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifreniz mevcut şifrenizden farklı olmalıdır.'**
  String get authPasswordDifferentError;

  /// No description provided for @authUserNotFoundError.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresine kayıtlı bir kullanıcı bulunamadı.'**
  String get authUserNotFoundError;

  /// No description provided for @dataRetentionDetail.
  ///
  /// In tr, this message translates to:
  /// **'Bu süre sonunda işlemleriniz ana listeden gizlenerek arşive taşınır. Arşivlenen veriler bakiyenizi etkilemez ve Dashboard\'u temiz tutar.'**
  String get dataRetentionDetail;

  /// No description provided for @retentionPeriodLabel.
  ///
  /// In tr, this message translates to:
  /// **'Saklama Süresi:'**
  String get retentionPeriodLabel;

  /// No description provided for @premiumRequired.
  ///
  /// In tr, this message translates to:
  /// **'Premium Gerekli'**
  String get premiumRequired;

  /// No description provided for @premiumRetentionDesc.
  ///
  /// In tr, this message translates to:
  /// **'Veri saklama, arşivleme ve otomatik temizleme kuralları sadece Premium üyelerin erişimine açıktır.'**
  String get premiumRetentionDesc;

  /// No description provided for @later.
  ///
  /// In tr, this message translates to:
  /// **'Daha Sonra'**
  String get later;

  /// No description provided for @permanentDeletionDetail.
  ///
  /// In tr, this message translates to:
  /// **'Dikkat: Bu süre sonunda verileriniz cihazınızdan tamamen silinir ve bir daha geri getirilemez.'**
  String get permanentDeletionDetail;

  /// No description provided for @purgePeriodLabel.
  ///
  /// In tr, this message translates to:
  /// **'Temizleme Süresi:'**
  String get purgePeriodLabel;

  /// No description provided for @cloudSync.
  ///
  /// In tr, this message translates to:
  /// **'Bulut Eşitleme'**
  String get cloudSync;

  /// No description provided for @loginRequiredLabel.
  ///
  /// In tr, this message translates to:
  /// **'Giriş gerekli'**
  String get loginRequiredLabel;

  /// No description provided for @syncToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün {time}'**
  String syncToday(String time);

  /// No description provided for @syncYesterday.
  ///
  /// In tr, this message translates to:
  /// **'Dün {time}'**
  String syncYesterday(String time);

  /// No description provided for @noSyncYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz eşitleme yapılmadı'**
  String get noSyncYet;

  /// No description provided for @syncStatus.
  ///
  /// In tr, this message translates to:
  /// **'Senkronizasyon Durumu'**
  String get syncStatus;

  /// No description provided for @lastSyncLabel.
  ///
  /// In tr, this message translates to:
  /// **'Son Eşitleme: {time}'**
  String lastSyncLabel(String time);

  /// No description provided for @syncBackgroundDesc.
  ///
  /// In tr, this message translates to:
  /// **'Verileriniz arka planda otomatik olarak buluta yedeklenmektedir.'**
  String get syncBackgroundDesc;

  /// No description provided for @syncCloudDesc.
  ///
  /// In tr, this message translates to:
  /// **'Verileriniz Supabase bulut altyapısı ile anlık olarak yedeklenir. Uygulamayı silseniz bile hesabınıza giriş yaparak verilerinizi geri getirebilirsiniz.'**
  String get syncCloudDesc;

  /// No description provided for @syncNow.
  ///
  /// In tr, this message translates to:
  /// **'ŞİMDİ SENKRONİZE ET'**
  String get syncNow;

  /// No description provided for @syncing.
  ///
  /// In tr, this message translates to:
  /// **'VERİLER EŞİTLENİYOR...'**
  String get syncing;

  /// No description provided for @syncPartialSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kısmi başarı: {summary}'**
  String syncPartialSuccess(String summary);

  /// No description provided for @syncFailed.
  ///
  /// In tr, this message translates to:
  /// **'Eşitleme başarısız oldu. {error}'**
  String syncFailed(String error);

  /// No description provided for @syncConnectionError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen internetinizi veya giriş bilgilerinizi kontrol edin.'**
  String get syncConnectionError;

  /// No description provided for @loginRequiredTitle.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Gerekli'**
  String get loginRequiredTitle;

  /// No description provided for @loginRequiredSyncDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bulut senkronizasyonunu aktifleştirerek verilerinizi yedeklemek için giriş yapmanız gerekmektedir.'**
  String get loginRequiredSyncDesc;

  /// No description provided for @premiumSyncDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama ayarlarınız ücretsiz olarak otomatik eşitlenmektedir. Kasa ve işlem verilerinizin buluta yedeklenmesi ise Premium üyelere özeldir.'**
  String get premiumSyncDesc;

  /// No description provided for @showOnPhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefonda Göster'**
  String get showOnPhone;

  /// No description provided for @appOnly.
  ///
  /// In tr, this message translates to:
  /// **'Sadece Uygulama İçi'**
  String get appOnly;

  /// No description provided for @notificationDesc.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcıların sadece uygulama içinde mi saklanacağını yoksa telefonunuzun bildirim panelinde de gösterilip gösterilmeyeceğini belirler. Kapalıyken hatırlatıcılar sessizce uygulama içinde kalır.'**
  String get notificationDesc;

  /// No description provided for @selectMainCurrency.
  ///
  /// In tr, this message translates to:
  /// **'Ana uygulama birimini seçin.'**
  String get selectMainCurrency;

  /// No description provided for @currencyDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu birim tüm uygulama genelinde (Dashboard, Kasalar ve İstatistikler) ana para birimi olarak kullanılır. Tüm varlıklarınız bu birime göre hesaplanır.'**
  String get currencyDesc;

  /// No description provided for @changeCurrency.
  ///
  /// In tr, this message translates to:
  /// **'Birimi Değiştir'**
  String get changeCurrency;

  /// No description provided for @exchangeRateNotFoundError.
  ///
  /// In tr, this message translates to:
  /// **'Seçilen para birimi için döviz kuru bulunamadı. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.'**
  String get exchangeRateNotFoundError;

  /// No description provided for @exchangeRatesDownloadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Döviz kurları indirilemedi. İnternet bağlantınızı kontrol edin.'**
  String get exchangeRatesDownloadFailed;

  /// No description provided for @exchangeRatesCheckError.
  ///
  /// In tr, this message translates to:
  /// **'Kurlar kontrol edilirken hata oluştu. Lütfen tekrar deneyin.'**
  String get exchangeRatesCheckError;

  /// No description provided for @exchangeRates.
  ///
  /// In tr, this message translates to:
  /// **'Döviz Kurları'**
  String get exchangeRates;

  /// No description provided for @baseUnitLira.
  ///
  /// In tr, this message translates to:
  /// **'Baz Birim: Türk Lirası'**
  String get baseUnitLira;

  /// No description provided for @baseUnitLabel.
  ///
  /// In tr, this message translates to:
  /// **'Baz Birim: {currency}'**
  String baseUnitLabel(String currency);

  /// No description provided for @lastSyncShort.
  ///
  /// In tr, this message translates to:
  /// **'SON: {time}'**
  String lastSyncShort(String time);

  /// No description provided for @updateRatesNow.
  ///
  /// In tr, this message translates to:
  /// **'KURLARI ŞİMDİ GÜNCELLE'**
  String get updateRatesNow;

  /// No description provided for @updatingRates.
  ///
  /// In tr, this message translates to:
  /// **'GÜNCELLENİYOR...'**
  String get updatingRates;

  /// No description provided for @exchangeRatesUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Kurlar başarıyla güncellendi.'**
  String get exchangeRatesUpdated;

  /// No description provided for @exchangeRatesUpdateFailed.
  ///
  /// In tr, this message translates to:
  /// **'Güncelleme başarısız. İnternet bağlantınızı kontrol edin.'**
  String get exchangeRatesUpdateFailed;

  /// No description provided for @showLess.
  ///
  /// In tr, this message translates to:
  /// **'Daha Az Göster'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In tr, this message translates to:
  /// **'Daha Fazla Göster'**
  String get showMore;

  /// No description provided for @styleLabel.
  ///
  /// In tr, this message translates to:
  /// **'Stil'**
  String get styleLabel;

  /// No description provided for @styleDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kartların ve arka planın görünüm stilini seçin'**
  String get styleDesc;

  /// No description provided for @styleColor.
  ///
  /// In tr, this message translates to:
  /// **'Renkli'**
  String get styleColor;

  /// No description provided for @styleColorDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uyumlu renkler'**
  String get styleColorDesc;

  /// No description provided for @styleSimple.
  ///
  /// In tr, this message translates to:
  /// **'Sade'**
  String get styleSimple;

  /// No description provided for @styleSimpleDesc.
  ///
  /// In tr, this message translates to:
  /// **'Düz tasarım'**
  String get styleSimpleDesc;

  /// No description provided for @premiumStyleDesc.
  ///
  /// In tr, this message translates to:
  /// **'Renkli görünüm stili sadece Premium üyelerin erişimine açıktır.'**
  String get premiumStyleDesc;

  /// No description provided for @premiumColorDesc.
  ///
  /// In tr, this message translates to:
  /// **'Özel renk temaları ve gelişmiş gradyanlar sadece Premium üyelerin erişimine açıktır.'**
  String get premiumColorDesc;

  /// No description provided for @paletteArctic.
  ///
  /// In tr, this message translates to:
  /// **'Kutup'**
  String get paletteArctic;

  /// No description provided for @paletteMint.
  ///
  /// In tr, this message translates to:
  /// **'Nane'**
  String get paletteMint;

  /// No description provided for @paletteRose.
  ///
  /// In tr, this message translates to:
  /// **'Rose'**
  String get paletteRose;

  /// No description provided for @paletteLavender.
  ///
  /// In tr, this message translates to:
  /// **'Lavanta'**
  String get paletteLavender;

  /// No description provided for @paletteSahara.
  ///
  /// In tr, this message translates to:
  /// **'Sahra'**
  String get paletteSahara;

  /// No description provided for @paletteSapphire.
  ///
  /// In tr, this message translates to:
  /// **'Safir'**
  String get paletteSapphire;

  /// No description provided for @paletteBurgundy.
  ///
  /// In tr, this message translates to:
  /// **'Bordo'**
  String get paletteBurgundy;

  /// No description provided for @palettePlatinum.
  ///
  /// In tr, this message translates to:
  /// **'Platin'**
  String get palettePlatinum;

  /// No description provided for @yearlyDiscount.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık (-%33)'**
  String get yearlyDiscount;

  /// No description provided for @comparisonTitle.
  ///
  /// In tr, this message translates to:
  /// **'KARŞILAŞTIRMA'**
  String get comparisonTitle;

  /// No description provided for @limitVaults.
  ///
  /// In tr, this message translates to:
  /// **'Kasa Sayısı'**
  String get limitVaults;

  /// No description provided for @limitAiAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'AI İşlem Asistanı'**
  String get limitAiAnalysis;

  /// No description provided for @limitCloudSync.
  ///
  /// In tr, this message translates to:
  /// **'Bulut Eşitleme'**
  String get limitCloudSync;

  /// No description provided for @limitDataRetention.
  ///
  /// In tr, this message translates to:
  /// **'Veri Saklama & Silme'**
  String get limitDataRetention;

  /// No description provided for @limitCustomThemes.
  ///
  /// In tr, this message translates to:
  /// **'Özel Temalar'**
  String get limitCustomThemes;

  /// No description provided for @limitAdFree.
  ///
  /// In tr, this message translates to:
  /// **'Reklamsız Deneyim'**
  String get limitAdFree;

  /// No description provided for @limitVaultsFree.
  ///
  /// In tr, this message translates to:
  /// **'2 Kasa'**
  String get limitVaultsFree;

  /// No description provided for @limitVaultsPro.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız'**
  String get limitVaultsPro;

  /// No description provided for @basicAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'Standart'**
  String get basicAnalysis;

  /// No description provided for @advancedAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'Genişletilmiş'**
  String get advancedAnalysis;

  /// No description provided for @limitDataRetentionPro.
  ///
  /// In tr, this message translates to:
  /// **'Özelleştirilebilir'**
  String get limitDataRetentionPro;

  /// No description provided for @cancelSubscriptionTest.
  ///
  /// In tr, this message translates to:
  /// **'Aboneliği İptal Et (Test)'**
  String get cancelSubscriptionTest;

  /// No description provided for @yearlyAccess.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık Erişim'**
  String get yearlyAccess;

  /// No description provided for @monthlyAccess.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Erişim'**
  String get monthlyAccess;

  /// No description provided for @yearlyPriceDetail.
  ///
  /// In tr, this message translates to:
  /// **'Ayda ₺99\'ye gelir'**
  String get yearlyPriceDetail;

  /// No description provided for @monthlyPriceDetail.
  ///
  /// In tr, this message translates to:
  /// **'Her ay yenilenir'**
  String get monthlyPriceDetail;

  /// No description provided for @loginRequiredPurchaseDesc.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma işlemini tamamlamak için lütfen giriş yapın veya ücretsiz bir hesap oluşturun.'**
  String get loginRequiredPurchaseDesc;

  /// No description provided for @loginOrRegister.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap / Üye Ol'**
  String get loginOrRegister;

  /// No description provided for @privilegesActive.
  ///
  /// In tr, this message translates to:
  /// **'Ayrıcalıklar aktif'**
  String get privilegesActive;

  /// No description provided for @tapToUnlock.
  ///
  /// In tr, this message translates to:
  /// **'Sınırları kaldırmak için dokunun'**
  String get tapToUnlock;

  /// No description provided for @sectionMembershipAccount.
  ///
  /// In tr, this message translates to:
  /// **'Üyelik ve Hesap'**
  String get sectionMembershipAccount;

  /// No description provided for @sectionAppearanceStyle.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm ve Stil'**
  String get sectionAppearanceStyle;

  /// No description provided for @sectionDataCloud.
  ///
  /// In tr, this message translates to:
  /// **'Veri ve Bulut'**
  String get sectionDataCloud;

  /// No description provided for @sectionSessionSecurity.
  ///
  /// In tr, this message translates to:
  /// **'Oturum ve Güvenlik'**
  String get sectionSessionSecurity;

  /// No description provided for @guestUser.
  ///
  /// In tr, this message translates to:
  /// **'Misafir Kullanıcı'**
  String get guestUser;

  /// No description provided for @tapToLogin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapmak veya kayıt olmak için dokunun'**
  String get tapToLogin;

  /// No description provided for @changePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Değiştir'**
  String get changePassword;

  /// No description provided for @changePasswordDesc.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut şifrenizi doğrulayarak yeni bir şifre belirleyin. Şifreniz en az 6 karakter olmalıdır.'**
  String get changePasswordDesc;

  /// No description provided for @currentPasswordHint.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Şifre'**
  String get currentPasswordHint;

  /// No description provided for @newPasswordHint.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre'**
  String get newPasswordHint;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre Tekrar'**
  String get confirmNewPasswordHint;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut şifrenizi girmeniz gerekir.'**
  String get currentPasswordRequired;

  /// No description provided for @updatePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Güncelle'**
  String get updatePassword;

  /// No description provided for @signOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get signOut;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Oturumu Kapat'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Oturumu kapatmak istediğinize emin misiniz?'**
  String get logoutConfirm;

  /// No description provided for @deleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabımı Sil'**
  String get deleteAccount;

  /// No description provided for @deleteAccountPermanently.
  ///
  /// In tr, this message translates to:
  /// **'Hesabımı Kalıcı Olarak Sil'**
  String get deleteAccountPermanently;

  /// No description provided for @deleteAccountConfirmDesc.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı ve buluttaki tüm verilerinizi kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'**
  String get deleteAccountConfirmDesc;

  /// No description provided for @reset.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırla'**
  String get reset;

  /// No description provided for @resetDataTitle.
  ///
  /// In tr, this message translates to:
  /// **'Verileri Sıfırla?'**
  String get resetDataTitle;

  /// No description provided for @resetDataDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tüm finansal verileriniz ve ayarlarınız kalıcı olarak silinecek. Bu işlem geri alınamaz.'**
  String get resetDataDesc;

  /// No description provided for @deleteAll.
  ///
  /// In tr, this message translates to:
  /// **'Hepsini Sil'**
  String get deleteAll;

  /// No description provided for @resetSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Tüm veriler ve ayarlar başarıyla sıfırlandı.'**
  String get resetSuccess;

  /// No description provided for @supportEmailCopied.
  ///
  /// In tr, this message translates to:
  /// **'E-posta uygulaması açılamadı. Destek adresi (finarcast.support@gmail.com) kopyalandı.'**
  String get supportEmailCopied;

  /// No description provided for @signInMethod.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yöntemi'**
  String get signInMethod;

  /// No description provided for @errorGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Hata: {error}'**
  String errorGeneric(Object error);

  /// No description provided for @resetFailed.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama başarısız oldu: {error}'**
  String resetFailed(Object error);

  /// No description provided for @criticalDatabaseError.
  ///
  /// In tr, this message translates to:
  /// **'Kritik Veritabanı Hatası'**
  String get criticalDatabaseError;

  /// No description provided for @criticalDatabaseErrorDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama veritabanında okunamayan/bozuk veriler tespit edildi. Aşağıdaki butona basarak veritabanını temizleyip uygulamayı sıfırdan başlatabilirsiniz.'**
  String get criticalDatabaseErrorDesc;

  /// No description provided for @resetDatabaseAndRestart.
  ///
  /// In tr, this message translates to:
  /// **'Veritabanını Sıfırla ve Yeniden Başlat'**
  String get resetDatabaseAndRestart;

  /// No description provided for @errorDetail.
  ///
  /// In tr, this message translates to:
  /// **'Hata Ayrıntısı:'**
  String get errorDetail;

  /// No description provided for @unlimitedAccessLimit.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız Erişim Limiti'**
  String get unlimitedAccessLimit;

  /// No description provided for @unlimitedAccessLimitDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sistem güvenliği gereği adil kullanım limitine ulaştınız. Lütfen daha sonra tekrar deneyin veya desteğe başvurun.'**
  String get unlimitedAccessLimitDesc;

  /// No description provided for @standardAccessLimit.
  ///
  /// In tr, this message translates to:
  /// **'Standart Erişim Limiti'**
  String get standardAccessLimit;

  /// No description provided for @standardAccessLimitDesc.
  ///
  /// In tr, this message translates to:
  /// **'Günlük standart yapay zeka analiz kotanızı doldurdunuz. Sınırları kaldırmak için Premium\'a yükseltebilirsiniz.'**
  String get standardAccessLimitDesc;

  /// No description provided for @upgradeToExtendedAccess.
  ///
  /// In tr, this message translates to:
  /// **'Genişletilmiş Erişime Geç'**
  String get upgradeToExtendedAccess;

  /// No description provided for @loginRequired.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yapılması Gerekiyor'**
  String get loginRequired;

  /// No description provided for @loginRequiredDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yapay zeka asistanını ve harcama sepetini kullanabilmek için giriş yapmanız veya hesap oluşturmanız gerekmektedir.'**
  String get loginRequiredDesc;

  /// No description provided for @loginOrSignUp.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap / Üye Ol'**
  String get loginOrSignUp;

  /// No description provided for @aiAnalyzingExpense.
  ///
  /// In tr, this message translates to:
  /// **'Yapay zeka harcamanızı çözümlüyor...'**
  String get aiAnalyzingExpense;

  /// No description provided for @draftAddedToInbox.
  ///
  /// In tr, this message translates to:
  /// **'Taslak harcama gelen kutusuna eklendi.'**
  String get draftAddedToInbox;

  /// No description provided for @analysisError.
  ///
  /// In tr, this message translates to:
  /// **'İşlem analiz edilirken bir hata oluştu.'**
  String get analysisError;

  /// No description provided for @scanningReceipt.
  ///
  /// In tr, this message translates to:
  /// **'Fiş taranıyor, bilgiler çıkartılıyor...'**
  String get scanningReceipt;

  /// No description provided for @receiptUnreadable.
  ///
  /// In tr, this message translates to:
  /// **'Fiş Okunamadı'**
  String get receiptUnreadable;

  /// No description provided for @receiptUnreadableDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yüklenen görselde herhangi bir fiş veya fatura bilgisi tespit edilemedi.'**
  String get receiptUnreadableDesc;

  /// No description provided for @receiptAddedToInbox.
  ///
  /// In tr, this message translates to:
  /// **'Fiş verileri başarıyla gelen kutusuna eklendi.'**
  String get receiptAddedToInbox;

  /// No description provided for @receiptReadError.
  ///
  /// In tr, this message translates to:
  /// **'Fiş okunamadı. Lütfen bilgileri el ile girin veya daha net bir fotoğraf çekin.'**
  String get receiptReadError;

  /// No description provided for @imageUploadError.
  ///
  /// In tr, this message translates to:
  /// **'Görsel yüklenirken bir hata oluştu.'**
  String get imageUploadError;

  /// No description provided for @draftDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Taslak harcama silindi.'**
  String get draftDeleted;

  /// No description provided for @transactionProcessedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'İşlem kasaya başarıyla işlendi!'**
  String get transactionProcessedSuccess;

  /// No description provided for @transactionApprovalError.
  ///
  /// In tr, this message translates to:
  /// **'İşlem onaylanırken bir hata oluştu.'**
  String get transactionApprovalError;

  /// No description provided for @smartScanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Smart Scan'**
  String get smartScanTitle;

  /// No description provided for @pendingApprovalCount.
  ///
  /// In tr, this message translates to:
  /// **'ONAY BEKLEYEN İŞLEMLER ({count})'**
  String pendingApprovalCount(int count);

  /// No description provided for @clearAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Temizle'**
  String get clearAll;

  /// No description provided for @smartInputHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Dün Starbucks filtre kahve 120 TL'**
  String get smartInputHint;

  /// No description provided for @camera.
  ///
  /// In tr, this message translates to:
  /// **'Kamera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeri'**
  String get gallery;

  /// No description provided for @inboxEmpty.
  ///
  /// In tr, this message translates to:
  /// **'GELEN KUTUNUZ BOŞ'**
  String get inboxEmpty;

  /// No description provided for @otherCategory.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get otherCategory;

  /// No description provided for @add.
  ///
  /// In tr, this message translates to:
  /// **'EKLE'**
  String get add;

  /// No description provided for @todayUpper.
  ///
  /// In tr, this message translates to:
  /// **'BUGÜN'**
  String get todayUpper;

  /// No description provided for @tomorrowUpper.
  ///
  /// In tr, this message translates to:
  /// **'YARIN'**
  String get tomorrowUpper;

  /// No description provided for @daysWithName.
  ///
  /// In tr, this message translates to:
  /// **'{count} GÜN - {dayName}'**
  String daysWithName(int count, String dayName);

  /// No description provided for @weeksLater.
  ///
  /// In tr, this message translates to:
  /// **'{count} HAFTA SONRA'**
  String weeksLater(int count);

  /// No description provided for @daysCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 Gün} other{{count} Gün}}'**
  String daysCount(num count);

  /// No description provided for @weeksCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 Hafta} other{{count} Hafta}}'**
  String weeksCount(num count);

  /// No description provided for @monthsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 Ay} other{{count} Ay}}'**
  String monthsCount(num count);

  /// No description provided for @yearsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 Yıl} other{{count} Yıl}}'**
  String yearsCount(num count);

  /// No description provided for @sharedExpenseAnalyzed.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşılan harcama analiz edildi ve sepete eklendi!'**
  String get sharedExpenseAnalyzed;

  /// No description provided for @limitExceeded.
  ///
  /// In tr, this message translates to:
  /// **'Limit Aşıldı'**
  String get limitExceeded;

  /// No description provided for @selectIcon.
  ///
  /// In tr, this message translates to:
  /// **'İKON SEÇİN'**
  String get selectIcon;

  /// No description provided for @optionsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} SEÇENEK'**
  String optionsCount(int count);

  /// No description provided for @invalidAmountError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir tutar girin.'**
  String get invalidAmountError;

  /// No description provided for @maxAmountMustBePositive.
  ///
  /// In tr, this message translates to:
  /// **'Maksimum tutar 0\'dan büyük olmalıdır.'**
  String get maxAmountMustBePositive;

  /// No description provided for @minMustBeLessThanMax.
  ///
  /// In tr, this message translates to:
  /// **'Minimum tutar maksimumdan küçük olmalıdır.'**
  String get minMustBeLessThanMax;

  /// No description provided for @selectAtLeastOneVault.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen işlem için en az bir kasa seçin...'**
  String get selectAtLeastOneVault;

  /// No description provided for @exchangeRatesNotLoaded.
  ///
  /// In tr, this message translates to:
  /// **'Döviz kurları yüklü değil. Farklı para biriminde işlem eklemek/güncellemek için kurları güncellemeniz gerekir.'**
  String get exchangeRatesNotLoaded;

  /// No description provided for @vaultCurrencyRateNotLoaded.
  ///
  /// In tr, this message translates to:
  /// **'Seçili kasanın para birimi ({currency}) için döviz kurları yüklü değil. Kurları güncellemeniz gerekir.'**
  String vaultCurrencyRateNotLoaded(String currency);

  /// No description provided for @transactionSaveError.
  ///
  /// In tr, this message translates to:
  /// **'İşlem kaydedilirken bir hata oluştu: {error}'**
  String transactionSaveError(String error);

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izni verilmedi. Lütfen ayarlardan açın.'**
  String get notificationPermissionDenied;

  /// No description provided for @defaultUser.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı'**
  String get defaultUser;

  /// No description provided for @premiumBadge.
  ///
  /// In tr, this message translates to:
  /// **'Premium'**
  String get premiumBadge;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @errorOccurred.
  ///
  /// In tr, this message translates to:
  /// **'Hata oluştu: {error}'**
  String errorOccurred(String error);

  /// No description provided for @aboutVersion.
  ///
  /// In tr, this message translates to:
  /// **'{version} • Made with ❤️'**
  String aboutVersion(String version);

  /// No description provided for @comingSoonDesc.
  ///
  /// In tr, this message translates to:
  /// **'{feature} özelliği çok yakında sizlerle olacak.'**
  String comingSoonDesc(String feature);

  /// No description provided for @noVaultTransactions.
  ///
  /// In tr, this message translates to:
  /// **'Kasa İşlemi Bulunmadı'**
  String get noVaultTransactions;

  /// No description provided for @recurring.
  ///
  /// In tr, this message translates to:
  /// **'Abonelikler'**
  String get recurring;

  /// No description provided for @thisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu Hafta'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu Ay'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In tr, this message translates to:
  /// **'Bu Yıl'**
  String get thisYear;

  /// No description provided for @vaultLimitReachedDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz planda en fazla {count} kasa oluşturabilirsiniz. Sınırları kaldırmak için Premium\'a geçebilirsiniz.'**
  String vaultLimitReachedDesc(int count);

  /// No description provided for @inAppNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama İçi Bildirimler'**
  String get inAppNotifications;

  /// No description provided for @exchangeRatesNotLoadedVault.
  ///
  /// In tr, this message translates to:
  /// **'Döviz kurları yüklü değil. Kasa para birimi değiştirilemedi.'**
  String get exchangeRatesNotLoadedVault;

  /// No description provided for @cannotDeleteVault.
  ///
  /// In tr, this message translates to:
  /// **'Kasa Silinemez'**
  String get cannotDeleteVault;

  /// No description provided for @cannotDeleteVaultDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamada en az bir aktif kasa bulunmalıdır. Başka kasa oluşturup bunu sonra silebilirsiniz.'**
  String get cannotDeleteVaultDesc;

  /// No description provided for @exchangeRatesNotLoadedNewVault.
  ///
  /// In tr, this message translates to:
  /// **'Döviz kurları yüklü değil. Farklı para biriminde kasa oluşturmak için kurları güncellemeniz gerekir.'**
  String get exchangeRatesNotLoadedNewVault;

  /// No description provided for @systemNotificationsDisabled.
  ///
  /// In tr, this message translates to:
  /// **'SİSTEM BİLDİRİM İZİNLERİ KAPALI!\nLütfen telefon ayarlarınızdan bildirim izinlerini etkinleştirin.'**
  String get systemNotificationsDisabled;

  /// No description provided for @noNotificationHistory.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş Bildirim Yok'**
  String get noNotificationHistory;

  /// No description provided for @noNotificationHistoryDesc.
  ///
  /// In tr, this message translates to:
  /// **'Daha önce tetiklenmiş herhangi bir işlem alarmı geçmişi bulunmuyor.'**
  String get noNotificationHistoryDesc;

  /// No description provided for @paymentDate.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme: {date}'**
  String paymentDate(String date);

  /// No description provided for @loginRequiredForPurchase.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma işlemini tamamlamak için lütfen giriş yapın veya ücretsiz bir hesap oluşturun.'**
  String get loginRequiredForPurchase;

  /// No description provided for @unlockFinancialPotential.
  ///
  /// In tr, this message translates to:
  /// **'Finansal potansiyelinizi %100 açığa çıkarın.'**
  String get unlockFinancialPotential;

  /// No description provided for @aiAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'AI Analizleri'**
  String get aiAnalysis;

  /// No description provided for @aiAnalysisDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız ve derin yapay zeka analizleri.'**
  String get aiAnalysisDesc;

  /// No description provided for @unlimitedVaultsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Dilediğiniz kadar kasa ve cüzdan oluşturun.'**
  String get unlimitedVaultsDesc;

  /// No description provided for @cloudSyncDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlarınızı ve verilerinizi güvenle yedekleyin ve senkronize edin.'**
  String get cloudSyncDesc;

  /// No description provided for @customThemes.
  ///
  /// In tr, this message translates to:
  /// **'Özel Temalar'**
  String get customThemes;

  /// No description provided for @customThemesDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ayrıcalıklı renk paletleri ve arka plan stilleri.'**
  String get customThemesDesc;

  /// No description provided for @zeroAds.
  ///
  /// In tr, this message translates to:
  /// **'Sıfır Reklam'**
  String get zeroAds;

  /// No description provided for @zeroAdsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kesintisiz ve reklamsız premium deneyim.'**
  String get zeroAdsDesc;

  /// No description provided for @availablePlans.
  ///
  /// In tr, this message translates to:
  /// **'MEVCUT PLANLAR'**
  String get availablePlans;

  /// No description provided for @yearlyPremium.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık Premium'**
  String get yearlyPremium;

  /// No description provided for @monthlyPremium.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Premium'**
  String get monthlyPremium;

  /// No description provided for @bestValueFreeTrialSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'En iyi değer • 7 gün ücretsiz'**
  String get bestValueFreeTrialSubtitle;

  /// No description provided for @cancelAnytime.
  ///
  /// In tr, this message translates to:
  /// **'İstediğin zaman iptal et'**
  String get cancelAnytime;

  /// No description provided for @bestValue.
  ///
  /// In tr, this message translates to:
  /// **'AVANTAJLI'**
  String get bestValue;

  /// No description provided for @yearlyPremiumSimulated.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık Premium (Simüle)'**
  String get yearlyPremiumSimulated;

  /// No description provided for @monthlyPremiumSimulated.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Premium (Simüle)'**
  String get monthlyPremiumSimulated;

  /// No description provided for @subscriptionAutoRenewalNote.
  ///
  /// In tr, this message translates to:
  /// **'Abonelik otomatik olarak yenilenir. İstediğiniz zaman iptal edebilirsiniz.'**
  String get subscriptionAutoRenewalNote;

  /// No description provided for @sessionNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.'**
  String get sessionNotFound;

  /// No description provided for @upgradeToPremiumTitle.
  ///
  /// In tr, this message translates to:
  /// **'Finarcast Premium\'a Geçin'**
  String get upgradeToPremiumTitle;

  /// No description provided for @yearlyPremiumSimulatedPrice.
  ///
  /// In tr, this message translates to:
  /// **'₺1.190 / yıl'**
  String get yearlyPremiumSimulatedPrice;

  /// No description provided for @yearlyPremiumSimulatedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Aylık ₺99 • 7 gün ücretsiz'**
  String get yearlyPremiumSimulatedSubtitle;

  /// No description provided for @monthlyPremiumSimulatedPrice.
  ///
  /// In tr, this message translates to:
  /// **'₺149 / ay'**
  String get monthlyPremiumSimulatedPrice;

  /// No description provided for @currencyTRY.
  ///
  /// In tr, this message translates to:
  /// **'Türk Lirası'**
  String get currencyTRY;

  /// No description provided for @currencyUSD.
  ///
  /// In tr, this message translates to:
  /// **'Amerikan Doları'**
  String get currencyUSD;

  /// No description provided for @currencyEUR.
  ///
  /// In tr, this message translates to:
  /// **'Euro'**
  String get currencyEUR;

  /// No description provided for @currencyGBP.
  ///
  /// In tr, this message translates to:
  /// **'İngiliz Sterlini'**
  String get currencyGBP;

  /// No description provided for @currencyJPY.
  ///
  /// In tr, this message translates to:
  /// **'Japon Yeni'**
  String get currencyJPY;

  /// No description provided for @currencyKRW.
  ///
  /// In tr, this message translates to:
  /// **'Kore Wonu'**
  String get currencyKRW;

  /// No description provided for @currencyCNY.
  ///
  /// In tr, this message translates to:
  /// **'Çin Yuanı'**
  String get currencyCNY;

  /// No description provided for @currencyBRL.
  ///
  /// In tr, this message translates to:
  /// **'Brezilya Reali'**
  String get currencyBRL;

  /// No description provided for @currencyCHF.
  ///
  /// In tr, this message translates to:
  /// **'İsviçre Frangı'**
  String get currencyCHF;

  /// No description provided for @currencyGOLD.
  ///
  /// In tr, this message translates to:
  /// **'Gram Altın'**
  String get currencyGOLD;

  /// No description provided for @currencyGOLDOunce.
  ///
  /// In tr, this message translates to:
  /// **'Ons Altın'**
  String get currencyGOLDOunce;

  /// No description provided for @currencySILVER.
  ///
  /// In tr, this message translates to:
  /// **'Gümüş (Gram)'**
  String get currencySILVER;

  /// No description provided for @currencySILVEROunce.
  ///
  /// In tr, this message translates to:
  /// **'Gümüş (Ons)'**
  String get currencySILVEROunce;

  /// No description provided for @currencySAR.
  ///
  /// In tr, this message translates to:
  /// **'Suudi Riyali'**
  String get currencySAR;

  /// No description provided for @currencyKWD.
  ///
  /// In tr, this message translates to:
  /// **'Kuveyt Dinarı'**
  String get currencyKWD;

  /// No description provided for @vaultGuideTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kasa Rehberi'**
  String get vaultGuideTitle;

  /// No description provided for @vaultGuideContent.
  ///
  /// In tr, this message translates to:
  /// **'📊 Karttaki Veriler Ne Anlama Geliyor?\n\n• Kasa Bakiyesi (Wallet): Kasadaki tüm zamanların kümülatif net bakiyesidir. Kasa başlangıç bakiyesi ve geçmişten bugüne gerçekleşen tüm gelir/gider hareketlerinin toplamıdır.\n\n• Gelir (Bu Ay): Sadece içinde bulunulan cari ay için tahmin edilen toplam geliri gösterir.\n\n• Gider (Bu Ay): Sadece içinde bulunulan cari ay için tahmin edilen toplam gideri gösterir.\n\n💡 Önemli Not:\nKasa Bakiyesi kümülatif (tüm zamanlar) olduğundan, o ayki Gelir ve Gider farkından farklı çıkması tamamen normaldir.'**
  String get vaultGuideContent;

  /// No description provided for @gotIt.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get gotIt;

  /// No description provided for @startDate.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Tarihi'**
  String get startDate;

  /// No description provided for @daily.
  ///
  /// In tr, this message translates to:
  /// **'Günlük'**
  String get daily;

  /// No description provided for @weekdays.
  ///
  /// In tr, this message translates to:
  /// **'Hafta İçi'**
  String get weekdays;

  /// No description provided for @weekends.
  ///
  /// In tr, this message translates to:
  /// **'Hafta Sonu'**
  String get weekends;

  /// No description provided for @everyXDays.
  ///
  /// In tr, this message translates to:
  /// **'{count} günde bir'**
  String everyXDays(Object count);

  /// No description provided for @everyXWeeks.
  ///
  /// In tr, this message translates to:
  /// **'{count} haftada bir'**
  String everyXWeeks(Object count);

  /// No description provided for @everyXMonths.
  ///
  /// In tr, this message translates to:
  /// **'{count} ayda bir'**
  String everyXMonths(Object count);

  /// No description provided for @everyXYears.
  ///
  /// In tr, this message translates to:
  /// **'{count} yılda bir'**
  String everyXYears(Object count);

  /// No description provided for @incomePerMonthLabel.
  ///
  /// In tr, this message translates to:
  /// **'GELİR / AY'**
  String get incomePerMonthLabel;

  /// No description provided for @expensePerMonthLabel.
  ///
  /// In tr, this message translates to:
  /// **'GİDER / AY'**
  String get expensePerMonthLabel;

  /// No description provided for @transactionNoteHint.
  ///
  /// In tr, this message translates to:
  /// **'İşleme dair not bırakın...'**
  String get transactionNoteHint;

  /// No description provided for @weekdaysShort.
  ///
  /// In tr, this message translates to:
  /// **'İçi'**
  String get weekdaysShort;

  /// No description provided for @weekendsShort.
  ///
  /// In tr, this message translates to:
  /// **'Sonu'**
  String get weekendsShort;

  /// No description provided for @reminderDay.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma Günü'**
  String get reminderDay;

  /// No description provided for @reminderTime.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma Saati'**
  String get reminderTime;

  /// No description provided for @reminder.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcı'**
  String get reminder;

  /// No description provided for @sameDay.
  ///
  /// In tr, this message translates to:
  /// **'Aynı Gün'**
  String get sameDay;

  /// No description provided for @oneDayBefore.
  ///
  /// In tr, this message translates to:
  /// **'1 Gün Önce'**
  String get oneDayBefore;

  /// No description provided for @twoDaysBefore.
  ///
  /// In tr, this message translates to:
  /// **'2 Gün Önce'**
  String get twoDaysBefore;

  /// No description provided for @threeDaysBefore.
  ///
  /// In tr, this message translates to:
  /// **'3 Gün Önce'**
  String get threeDaysBefore;

  /// No description provided for @oneWeekBefore.
  ///
  /// In tr, this message translates to:
  /// **'1 Hafta Önce'**
  String get oneWeekBefore;

  /// No description provided for @unknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmiyor'**
  String get unknown;

  /// No description provided for @syncErrorDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Eşitleme ayarı kapalı.'**
  String get syncErrorDisabled;

  /// No description provided for @syncErrorPremiumRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bulut eşitleme özelliği sadece Premium üyeler içindir.'**
  String get syncErrorPremiumRequired;

  /// No description provided for @syncSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Senkronizasyon tamamlandı.'**
  String get syncSuccess;

  /// No description provided for @syncSuccessWithErrors.
  ///
  /// In tr, this message translates to:
  /// **'Senkronizasyon sırasında {errorCount} hata oluştu.'**
  String syncSuccessWithErrors(num errorCount);

  /// No description provided for @syncErrorProjectPaused.
  ///
  /// In tr, this message translates to:
  /// **'Bulut veritabanı projesi duraklatılmış (Project Paused). Lütfen Supabase panelinizden projeyi tekrar aktifleştirin.'**
  String get syncErrorProjectPaused;

  /// No description provided for @syncErrorSessionExpired.
  ///
  /// In tr, this message translates to:
  /// **'Oturum süreniz dolmuş olabilir. Lütfen Ayarlar > Oturumu Kapat seçeneğiyle çıkış yapıp tekrar giriş yapın.'**
  String get syncErrorSessionExpired;

  /// No description provided for @syncErrorNoInternet.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı kurulamadı. Lütfen internet bağlantınızı kontrol edin.'**
  String get syncErrorNoInternet;

  /// No description provided for @syncErrorTablesMissing.
  ///
  /// In tr, this message translates to:
  /// **'Veritabanı tabloları bulunamadı. Lütfen Supabase SQL Editor\'da setup.sql betiğini çalıştırın.'**
  String get syncErrorTablesMissing;

  /// No description provided for @syncErrorPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'Veritabanı erişim yetki hatası (RLS). Lütfen Supabase tablolarında RLS politikalarını doğru yapılandırdığınızdan emin olun.'**
  String get syncErrorPermissionDenied;

  /// No description provided for @syncErrorUnexpected.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmeyen hata: {error}'**
  String syncErrorUnexpected(Object error);

  /// No description provided for @syncErrorPostgrest.
  ///
  /// In tr, this message translates to:
  /// **'Bulut Hatası ({code}): {message}'**
  String syncErrorPostgrest(Object code, Object message);

  /// No description provided for @syncErrorAuth.
  ///
  /// In tr, this message translates to:
  /// **'Kimlik Doğrulama Hatası ({code}): {message}'**
  String syncErrorAuth(Object code, Object message);

  /// No description provided for @activeVaults.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{Aktif Kasa} other{Aktif Kasa}}'**
  String activeVaults(num count);

  /// No description provided for @vaultsUpper.
  ///
  /// In tr, this message translates to:
  /// **'KASALAR'**
  String get vaultsUpper;

  /// No description provided for @receiptExpense.
  ///
  /// In tr, this message translates to:
  /// **'Fiş Harcaması'**
  String get receiptExpense;

  /// No description provided for @reasonSmartInput.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Metin Girişi'**
  String get reasonSmartInput;

  /// No description provided for @reasonReceiptScan.
  ///
  /// In tr, this message translates to:
  /// **'Fiş Fotoğrafı'**
  String get reasonReceiptScan;

  /// No description provided for @reasonClipboard.
  ///
  /// In tr, this message translates to:
  /// **'Pano Bildirimi'**
  String get reasonClipboard;

  /// No description provided for @noteCapturedFromClipboard.
  ///
  /// In tr, this message translates to:
  /// **'Kopyalanan Metinden Yakalandı'**
  String get noteCapturedFromClipboard;

  /// No description provided for @notificationChannelName.
  ///
  /// In tr, this message translates to:
  /// **'İşlem Hatırlatıcıları'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDesc.
  ///
  /// In tr, this message translates to:
  /// **'Periyodik ödemeler ve gelirler için hatırlatıcılar'**
  String get notificationChannelDesc;

  /// No description provided for @notificationTestChannelName.
  ///
  /// In tr, this message translates to:
  /// **'Test Bildirimleri'**
  String get notificationTestChannelName;

  /// No description provided for @notificationTestChannelDesc.
  ///
  /// In tr, this message translates to:
  /// **'Finarcast bildirim test kanalı'**
  String get notificationTestChannelDesc;

  /// No description provided for @notificationTestTitle.
  ///
  /// In tr, this message translates to:
  /// **'Finarcast Test Bildirimi'**
  String get notificationTestTitle;

  /// No description provided for @notificationTestBody.
  ///
  /// In tr, this message translates to:
  /// **'Harika! Uygulama içi (foreground) bildirimleriniz sorunsuz çalışıyor.'**
  String get notificationTestBody;

  /// No description provided for @notificationTestDelayedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Finarcast Gecikmeli Test'**
  String get notificationTestDelayedTitle;

  /// No description provided for @notificationTestDelayedBody.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama dışı (background) bildirim testi başarıyla tamamlandı!'**
  String get notificationTestDelayedBody;

  /// No description provided for @notificationIncomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelir Hatırlatıcısı: {title}'**
  String notificationIncomeTitle(Object title);

  /// No description provided for @notificationExpenseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Hatırlatıcısı: {title}'**
  String notificationExpenseTitle(Object title);

  /// No description provided for @notificationBodyAmount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar: {amount}'**
  String notificationBodyAmount(Object amount);

  /// No description provided for @notificationBodyDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih: {date}'**
  String notificationBodyDate(Object date);

  /// No description provided for @notificationBodyNote.
  ///
  /// In tr, this message translates to:
  /// **'Not: {note}'**
  String notificationBodyNote(Object note);

  /// No description provided for @aiErrorRateLimit.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Yapay Zeka analiz limitinizi doldurdunuz. Lütfen Premium plana yükseltin veya yarın tekrar deneyin.'**
  String get aiErrorRateLimit;

  /// No description provided for @aiErrorUnauthorized.
  ///
  /// In tr, this message translates to:
  /// **'Yetkisiz erişim. Lütfen tekrar giriş yapın.'**
  String get aiErrorUnauthorized;

  /// No description provided for @aiErrorQuota.
  ///
  /// In tr, this message translates to:
  /// **'Yapay Zeka kullanım limitiniz (kota) doldu. Lütfen biraz bekleyip tekrar deneyin.'**
  String get aiErrorQuota;

  /// No description provided for @aiErrorBusy.
  ///
  /// In tr, this message translates to:
  /// **'Yapay Zeka sunucusu şu an çok yoğun. Lütfen birkaç saniye sonra tekrar deneyin.'**
  String get aiErrorBusy;

  /// No description provided for @aiErrorApiKey.
  ///
  /// In tr, this message translates to:
  /// **'Yapay Zeka API Anahtarı geçersiz veya bulunamadı. Lütfen ayarlarınızı kontrol edin.'**
  String get aiErrorApiKey;

  /// No description provided for @aiErrorTimeout.
  ///
  /// In tr, this message translates to:
  /// **'İstek zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.'**
  String get aiErrorTimeout;

  /// No description provided for @aiErrorGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Yapay Zeka analizi başarısız oldu: {error}'**
  String aiErrorGeneric(Object error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pt',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
