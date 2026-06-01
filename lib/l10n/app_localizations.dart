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

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Finarcast'**
  String get appTitle;

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

  /// No description provided for @memberPremium.
  ///
  /// In tr, this message translates to:
  /// **'Finarcast Premium Üyelik'**
  String get memberPremium;

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

  /// No description provided for @aiNotifications.
  ///
  /// In tr, this message translates to:
  /// **'AI Asistan Uyarıları'**
  String get aiNotifications;

  /// No description provided for @dataAndAiSettings.
  ///
  /// In tr, this message translates to:
  /// **'VERİ & AI AYARLARI'**
  String get dataAndAiSettings;

  /// No description provided for @dataRetention.
  ///
  /// In tr, this message translates to:
  /// **'Veri Saklama'**
  String get dataRetention;

  /// No description provided for @dataRetentionDesc.
  ///
  /// In tr, this message translates to:
  /// **'Süresi dolan işlemler arşivlenir.\nAI Persona yalnızca bu süredeki verileri kullanır.'**
  String get dataRetentionDesc;

  /// No description provided for @permanentDataDeletion.
  ///
  /// In tr, this message translates to:
  /// **'Kalıcı Silme'**
  String get permanentDataDeletion;

  /// No description provided for @permanentDataDeletionDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu süreden sonra işlemler veritabanından kalıcı olarak silinir.\nBu işlem geri alınamaz.'**
  String get permanentDataDeletionDesc;

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

  /// No description provided for @dataManagement.
  ///
  /// In tr, this message translates to:
  /// **'VERİ YÖNETİMİ'**
  String get dataManagement;

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

  /// No description provided for @editProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil Düzenleme'**
  String get editProfile;

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
  /// **'Ana Sayfa'**
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

  /// No description provided for @dailySummary.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Özet'**
  String get dailySummary;

  /// No description provided for @todaySpending.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü Harcama'**
  String get todaySpending;

  /// No description provided for @weeklyRemaining.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Kalan'**
  String get weeklyRemaining;

  /// No description provided for @recentTransactions.
  ///
  /// In tr, this message translates to:
  /// **'Son İşlemler'**
  String get recentTransactions;

  /// No description provided for @seeAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Gör'**
  String get seeAll;

  /// No description provided for @myVaults.
  ///
  /// In tr, this message translates to:
  /// **'Kasalarım'**
  String get myVaults;

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

  /// No description provided for @setGoal.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Belirle'**
  String get setGoal;

  /// No description provided for @analyze.
  ///
  /// In tr, this message translates to:
  /// **'Analiz Et'**
  String get analyze;

  /// No description provided for @addTransaction.
  ///
  /// In tr, this message translates to:
  /// **'İşlem Ekle'**
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

  /// No description provided for @selectVault.
  ///
  /// In tr, this message translates to:
  /// **'Kasa Seç'**
  String get selectVault;

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

  /// No description provided for @monthlyIncome.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Gelir'**
  String get monthlyIncome;

  /// No description provided for @monthlyExpense.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Gider'**
  String get monthlyExpense;

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

  /// No description provided for @noTransactions.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bu kategoride işlem yok'**
  String get noTransactions;

  /// No description provided for @period.
  ///
  /// In tr, this message translates to:
  /// **'Periyot'**
  String get period;

  /// No description provided for @remainingTime.
  ///
  /// In tr, this message translates to:
  /// **'Kalan Süre'**
  String get remainingTime;

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

  /// No description provided for @transactionName.
  ///
  /// In tr, this message translates to:
  /// **'İşlem Adı'**
  String get transactionName;

  /// No description provided for @frequency.
  ///
  /// In tr, this message translates to:
  /// **'Sıklık'**
  String get frequency;

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

  /// No description provided for @colorSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get colorSystem;

  /// No description provided for @market.
  ///
  /// In tr, this message translates to:
  /// **'Market'**
  String get market;

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

  /// No description provided for @personalCare.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Bakım'**
  String get personalCare;

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

  /// No description provided for @workspace.
  ///
  /// In tr, this message translates to:
  /// **'Ofis/Çalışma Alanı'**
  String get workspace;

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
  /// **'Maximum'**
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

  /// No description provided for @dayOfYear.
  ///
  /// In tr, this message translates to:
  /// **'Yılın Günü'**
  String get dayOfYear;

  /// No description provided for @dayOf.
  ///
  /// In tr, this message translates to:
  /// **'Günü'**
  String get dayOf;

  /// No description provided for @recurrencePeriod.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Periyodu'**
  String get recurrencePeriod;

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

  /// No description provided for @fastFood.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Yemek'**
  String get fastFood;

  /// No description provided for @cafe.
  ///
  /// In tr, this message translates to:
  /// **'Kafe'**
  String get cafe;

  /// No description provided for @takeout.
  ///
  /// In tr, this message translates to:
  /// **'Paket Servis'**
  String get takeout;

  /// No description provided for @rent.
  ///
  /// In tr, this message translates to:
  /// **'Kira'**
  String get rent;

  /// No description provided for @homeRent.
  ///
  /// In tr, this message translates to:
  /// **'Ev Kirası'**
  String get homeRent;

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

  /// No description provided for @naturalGas.
  ///
  /// In tr, this message translates to:
  /// **'Doğalgaz'**
  String get naturalGas;

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

  /// No description provided for @entertainment.
  ///
  /// In tr, this message translates to:
  /// **'Eğlence'**
  String get entertainment;

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

  /// No description provided for @streaming.
  ///
  /// In tr, this message translates to:
  /// **'Dijital Yayın'**
  String get streaming;

  /// No description provided for @musicSubscription.
  ///
  /// In tr, this message translates to:
  /// **'Müzik'**
  String get musicSubscription;

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

  /// No description provided for @transportation.
  ///
  /// In tr, this message translates to:
  /// **'Ulaşım'**
  String get transportation;

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

  /// No description provided for @clothing.
  ///
  /// In tr, this message translates to:
  /// **'Giyim'**
  String get clothing;

  /// No description provided for @dailyWear.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Giyim'**
  String get dailyWear;

  /// No description provided for @shoes.
  ///
  /// In tr, this message translates to:
  /// **'Ayakkabı'**
  String get shoes;

  /// No description provided for @accessory.
  ///
  /// In tr, this message translates to:
  /// **'Aksesuar'**
  String get accessory;

  /// No description provided for @education.
  ///
  /// In tr, this message translates to:
  /// **'Eğitim'**
  String get education;

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

  /// No description provided for @debtPayment.
  ///
  /// In tr, this message translates to:
  /// **'Borç Ödemesi'**
  String get debtPayment;

  /// No description provided for @creditCard.
  ///
  /// In tr, this message translates to:
  /// **'Kredi Kartı'**
  String get creditCard;

  /// No description provided for @loan.
  ///
  /// In tr, this message translates to:
  /// **'Kredi'**
  String get loan;

  /// No description provided for @personalDebt.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Borç'**
  String get personalDebt;

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

  /// No description provided for @mainSalary.
  ///
  /// In tr, this message translates to:
  /// **'Ana Maaş'**
  String get mainSalary;

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

  /// No description provided for @extraIncome.
  ///
  /// In tr, this message translates to:
  /// **'Ek Gelir'**
  String get extraIncome;

  /// No description provided for @freelance.
  ///
  /// In tr, this message translates to:
  /// **'Serbest Çalışma'**
  String get freelance;

  /// No description provided for @partTime.
  ///
  /// In tr, this message translates to:
  /// **'Yarı Zamanlı'**
  String get partTime;

  /// No description provided for @commission.
  ///
  /// In tr, this message translates to:
  /// **'Komisyon'**
  String get commission;

  /// No description provided for @investmentReturn.
  ///
  /// In tr, this message translates to:
  /// **'Yatırım Getirisi'**
  String get investmentReturn;

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

  /// No description provided for @scholarshipLoan.
  ///
  /// In tr, this message translates to:
  /// **'Burs/Kredi'**
  String get scholarshipLoan;

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

  /// No description provided for @onlineSale.
  ///
  /// In tr, this message translates to:
  /// **'Online Satış'**
  String get onlineSale;

  /// No description provided for @physicalSale.
  ///
  /// In tr, this message translates to:
  /// **'Fiziksel Satış'**
  String get physicalSale;

  /// No description provided for @rentalIncome.
  ///
  /// In tr, this message translates to:
  /// **'Kira Geliri'**
  String get rentalIncome;

  /// No description provided for @officeIncome.
  ///
  /// In tr, this message translates to:
  /// **'Ofis Geliri'**
  String get officeIncome;

  /// No description provided for @gift.
  ///
  /// In tr, this message translates to:
  /// **'Hediye'**
  String get gift;

  /// No description provided for @vaultOrGroup.
  ///
  /// In tr, this message translates to:
  /// **'Kasa veya Grup'**
  String get vaultOrGroup;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @generalBalance.
  ///
  /// In tr, this message translates to:
  /// **'Genel Bakiye'**
  String get generalBalance;

  /// No description provided for @everyDay.
  ///
  /// In tr, this message translates to:
  /// **'Her Gün'**
  String get everyDay;

  /// No description provided for @every2Days.
  ///
  /// In tr, this message translates to:
  /// **'2 Günde Bir'**
  String get every2Days;

  /// No description provided for @every3Days.
  ///
  /// In tr, this message translates to:
  /// **'3 Günde Bir'**
  String get every3Days;

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

  /// No description provided for @twoWeeks.
  ///
  /// In tr, this message translates to:
  /// **'2 Hafta'**
  String get twoWeeks;

  /// No description provided for @threeWeeks.
  ///
  /// In tr, this message translates to:
  /// **'3 Hafta'**
  String get threeWeeks;

  /// No description provided for @flexibleAmount.
  ///
  /// In tr, this message translates to:
  /// **'Esnek Tutar'**
  String get flexibleAmount;

  /// No description provided for @singleAmount.
  ///
  /// In tr, this message translates to:
  /// **'Tek Tutar'**
  String get singleAmount;

  /// No description provided for @advancedOptions.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş Seçenekler'**
  String get advancedOptions;

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

  /// No description provided for @selectDay.
  ///
  /// In tr, this message translates to:
  /// **'Gün Seç'**
  String get selectDay;

  /// No description provided for @financialIdentity.
  ///
  /// In tr, this message translates to:
  /// **'Finansal Kimliğin'**
  String get financialIdentity;

  /// No description provided for @setTarget.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Belirle'**
  String get setTarget;

  /// No description provided for @allVaults.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Kasalar'**
  String get allVaults;

  /// No description provided for @hidePreselect.
  ///
  /// In tr, this message translates to:
  /// **'Ön seçimi gizle'**
  String get hidePreselect;

  /// No description provided for @showPreselect.
  ///
  /// In tr, this message translates to:
  /// **'Ön seçimi göster'**
  String get showPreselect;

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

  /// No description provided for @doNotTouch.
  ///
  /// In tr, this message translates to:
  /// **'Dokunulmasın'**
  String get doNotTouch;

  /// No description provided for @changeable.
  ///
  /// In tr, this message translates to:
  /// **'Değiştirilebilir'**
  String get changeable;

  /// No description provided for @excellent.
  ///
  /// In tr, this message translates to:
  /// **'MÜKEMMEL'**
  String get excellent;

  /// No description provided for @analysisResult.
  ///
  /// In tr, this message translates to:
  /// **'ANALİZ SONUCU'**
  String get analysisResult;

  /// No description provided for @onTrackMessage.
  ///
  /// In tr, this message translates to:
  /// **'Hedefe Ulaşıyorsun'**
  String get onTrackMessage;

  /// No description provided for @savingsNeeded.
  ///
  /// In tr, this message translates to:
  /// **'Tasarruf Gerekli'**
  String get savingsNeeded;

  /// No description provided for @currentBalance.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Bakiye'**
  String get currentBalance;

  /// No description provided for @targetGap.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Açığı'**
  String get targetGap;

  /// No description provided for @currentSurplus.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Fazlan'**
  String get currentSurplus;

  /// No description provided for @requiredMonthlySavings.
  ///
  /// In tr, this message translates to:
  /// **'Gereken Aylık Tasarruf'**
  String get requiredMonthlySavings;

  /// No description provided for @score.
  ///
  /// In tr, this message translates to:
  /// **'SKOR'**
  String get score;

  /// No description provided for @currentSavings.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Birikimlerin'**
  String get currentSavings;

  /// No description provided for @aiSavingsTarget.
  ///
  /// In tr, this message translates to:
  /// **'AI Tasarruf Hedefi'**
  String get aiSavingsTarget;

  /// No description provided for @remainingGap.
  ///
  /// In tr, this message translates to:
  /// **'Kalan Açık'**
  String get remainingGap;

  /// No description provided for @dailyAiQuotaFull.
  ///
  /// In tr, this message translates to:
  /// **'Günlük AI kotası doldu'**
  String get dailyAiQuotaFull;

  /// No description provided for @noInternetConnection.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok'**
  String get noInternetConnection;

  /// No description provided for @aiApiError.
  ///
  /// In tr, this message translates to:
  /// **'AI API hatası'**
  String get aiApiError;

  /// No description provided for @aiCoachSuggestion.
  ///
  /// In tr, this message translates to:
  /// **'AI KOÇUNUN ÖNERİSİ'**
  String get aiCoachSuggestion;

  /// No description provided for @cutbackPlan.
  ///
  /// In tr, this message translates to:
  /// **'KISINTI PLANI'**
  String get cutbackPlan;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @recentAnalyses.
  ///
  /// In tr, this message translates to:
  /// **'Son Analizler'**
  String get recentAnalyses;

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

  /// No description provided for @managePanel.
  ///
  /// In tr, this message translates to:
  /// **'Paneli Yönet'**
  String get managePanel;

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

  /// No description provided for @averageMonthlyLoad.
  ///
  /// In tr, this message translates to:
  /// **'AYLIK ORTALAMA YÜK'**
  String get averageMonthlyLoad;

  /// No description provided for @noTransactionsInVault.
  ///
  /// In tr, this message translates to:
  /// **'Bu kasada işlem bulunmuyor.'**
  String get noTransactionsInVault;

  /// No description provided for @manageTransactionsInVault.
  ///
  /// In tr, this message translates to:
  /// **'Kasadaki İşlemleri Yönet'**
  String get manageTransactionsInVault;

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

  /// No description provided for @every2WeeksDetailed.
  ///
  /// In tr, this message translates to:
  /// **'2 haftada bir'**
  String get every2WeeksDetailed;

  /// No description provided for @every3WeeksDetailed.
  ///
  /// In tr, this message translates to:
  /// **'3 haftada bir'**
  String get every3WeeksDetailed;

  /// No description provided for @every3MonthsDetailed.
  ///
  /// In tr, this message translates to:
  /// **'3 ayda bir'**
  String get every3MonthsDetailed;

  /// No description provided for @every6MonthsDetailed.
  ///
  /// In tr, this message translates to:
  /// **'6 ayda bir'**
  String get every6MonthsDetailed;

  /// No description provided for @everyDayDetailed.
  ///
  /// In tr, this message translates to:
  /// **'Her gün'**
  String get everyDayDetailed;

  /// No description provided for @every2DaysDetailed.
  ///
  /// In tr, this message translates to:
  /// **'2 günde bir'**
  String get every2DaysDetailed;

  /// No description provided for @every3DaysDetailed.
  ///
  /// In tr, this message translates to:
  /// **'3 günde bir'**
  String get every3DaysDetailed;

  /// No description provided for @allLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hepsi'**
  String get allLabel;

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

  /// No description provided for @approved.
  ///
  /// In tr, this message translates to:
  /// **'Onaylandı'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In tr, this message translates to:
  /// **'Reddedildi'**
  String get rejected;

  /// No description provided for @pending.
  ///
  /// In tr, this message translates to:
  /// **'Bekliyor'**
  String get pending;

  /// No description provided for @visibilityManagement.
  ///
  /// In tr, this message translates to:
  /// **'Görünürlük Yönetimi'**
  String get visibilityManagement;

  /// No description provided for @editTransaction.
  ///
  /// In tr, this message translates to:
  /// **'İşlem bilgilerini güncelle'**
  String get editTransaction;

  /// No description provided for @removeFromVault.
  ///
  /// In tr, this message translates to:
  /// **'Kasadan Çıkar'**
  String get removeFromVault;

  /// No description provided for @removeFromVaultDesc.
  ///
  /// In tr, this message translates to:
  /// **'İşlem ana kasaya geri döner, silinmez'**
  String get removeFromVaultDesc;

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

  /// No description provided for @groupNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Grup adı...'**
  String get groupNameHint;

  /// No description provided for @transactionCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 işlem} other{{count} işlem}}'**
  String transactionCount(num count);

  /// No description provided for @noRemainingTransactions.
  ///
  /// In tr, this message translates to:
  /// **'Eklenebilecek boş işlem kalmadı.'**
  String get noRemainingTransactions;

  /// No description provided for @editTransactionDesc.
  ///
  /// In tr, this message translates to:
  /// **'İşlem bilgilerini güncelle'**
  String get editTransactionDesc;

  /// No description provided for @visibilityDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ana sayfada hangi grup veya işlemlerin görüneceğini seçin.'**
  String get visibilityDesc;

  /// No description provided for @vaultsAndGroups.
  ///
  /// In tr, this message translates to:
  /// **'Kasalar & Gruplar'**
  String get vaultsAndGroups;

  /// No description provided for @individualTransactions.
  ///
  /// In tr, this message translates to:
  /// **'Tekil İşlemler'**
  String get individualTransactions;

  /// No description provided for @analyzingFinancialIdentity.
  ///
  /// In tr, this message translates to:
  /// **'Finansal kimliğin analiz ediliyor...'**
  String get analyzingFinancialIdentity;

  /// No description provided for @financialIdentityHint.
  ///
  /// In tr, this message translates to:
  /// **'Analiz yaptığında finansal kimliğin burada belirecek.'**
  String get financialIdentityHint;

  /// No description provided for @targetDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Tarihi:'**
  String get targetDateLabel;

  /// No description provided for @scopeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kapsam:'**
  String get scopeLabel;

  /// No description provided for @preselectHint.
  ///
  /// In tr, this message translates to:
  /// **'Kalemler üzerinde ön seçim yap (isteğe bağlı)'**
  String get preselectHint;

  /// No description provided for @noItemsToAnalyze.
  ///
  /// In tr, this message translates to:
  /// **'Seçilen tarihe kadar etki edecek işlem bulunamadı.'**
  String get noItemsToAnalyze;

  /// No description provided for @itemsToAnalyze.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{Hedef tarihe ({months} ay) kadar etki edecek 1 kalem.} other{Hedef tarihe ({months} ay) kadar etki edecek {count} kalem.}}'**
  String itemsToAnalyze(num count, Object months);

  /// No description provided for @budgetNotFeasible.
  ///
  /// In tr, this message translates to:
  /// **'Bu hedef mevcut esnek bütçenle tam karşılanamıyor. Süreyi uzatmayı veya geliri artırmayı düşünebilirsin.'**
  String get budgetNotFeasible;

  /// No description provided for @financialIdentityUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Harika! Finansal kimliğin güncellendi ve analiz kaydedildi.'**
  String get financialIdentityUpdated;

  /// No description provided for @feedbackMemoized.
  ///
  /// In tr, this message translates to:
  /// **'Tamam, bu tercihler hafızaya alındı. Bir sonraki analizde farklı öneriler sunulacak.'**
  String get feedbackMemoized;

  /// No description provided for @excludedCategories.
  ///
  /// In tr, this message translates to:
  /// **'Hariç Tutulanlar:'**
  String get excludedCategories;

  /// No description provided for @newFrequency.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Sıklık: {frequency}'**
  String newFrequency(Object frequency);

  /// No description provided for @doYouLikeThisSuggestion.
  ///
  /// In tr, this message translates to:
  /// **'Bu öneriyi beğendin mi?'**
  String get doYouLikeThisSuggestion;

  /// No description provided for @yesILikeIt.
  ///
  /// In tr, this message translates to:
  /// **'Evet, Beğendim'**
  String get yesILikeIt;

  /// No description provided for @targetAmountLabel.
  ///
  /// In tr, this message translates to:
  /// **'{amount} Hedef'**
  String targetAmountLabel(Object amount);

  /// No description provided for @weeksToTargetLabel.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 Hafta} other{{count} Hafta}}'**
  String weeksToTargetLabel(num count);

  /// No description provided for @monthsToTargetLabel.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 Ay} other{{count} Ay}}'**
  String monthsToTargetLabel(num count);

  /// No description provided for @yearsToTargetLabel.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 Yıl} other{{count} Yıl}}'**
  String yearsToTargetLabel(num count);

  /// No description provided for @minAmount.
  ///
  /// In tr, this message translates to:
  /// **'Min.'**
  String get minAmount;

  /// No description provided for @maxAmount.
  ///
  /// In tr, this message translates to:
  /// **'Max.'**
  String get maxAmount;

  /// No description provided for @limitedTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get limitedTotal;

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

  /// No description provided for @layoutAndSorting.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm ve Sıralama'**
  String get layoutAndSorting;

  /// No description provided for @layout1.
  ///
  /// In tr, this message translates to:
  /// **'1\'li'**
  String get layout1;

  /// No description provided for @layout2.
  ///
  /// In tr, this message translates to:
  /// **'2\'li'**
  String get layout2;

  /// No description provided for @layout3.
  ///
  /// In tr, this message translates to:
  /// **'3\'lü'**
  String get layout3;

  /// No description provided for @layout4.
  ///
  /// In tr, this message translates to:
  /// **'4\'lü'**
  String get layout4;

  /// No description provided for @moveForward.
  ///
  /// In tr, this message translates to:
  /// **'Öne Taşı'**
  String get moveForward;

  /// No description provided for @moveBackward.
  ///
  /// In tr, this message translates to:
  /// **'Arkaya Taşı'**
  String get moveBackward;

  /// No description provided for @selectCurrency.
  ///
  /// In tr, this message translates to:
  /// **'Para Birimi Seçin'**
  String get selectCurrency;

  /// No description provided for @membershipPlan.
  ///
  /// In tr, this message translates to:
  /// **'Üyelik Planı'**
  String get membershipPlan;

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

  /// No description provided for @aiMode.
  ///
  /// In tr, this message translates to:
  /// **'AI Modu'**
  String get aiMode;

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

  /// No description provided for @dashboardEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Dashboard şu an boş.'**
  String get dashboardEmpty;

  /// No description provided for @libraryEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphane şu an boş.'**
  String get libraryEmpty;

  /// No description provided for @pageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa'**
  String get pageLabel;

  /// No description provided for @sizeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Boyut'**
  String get sizeLabel;

  /// No description provided for @widgetAdded.
  ///
  /// In tr, this message translates to:
  /// **'{name} panoya eklendi!'**
  String widgetAdded(String name);

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

  /// No description provided for @quickActionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı İşlem'**
  String get quickActionTitle;

  /// No description provided for @vaultStatusTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kasa Durumları'**
  String get vaultStatusTitle;

  /// No description provided for @dailyBudgetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Bütçe'**
  String get dailyBudgetTitle;

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
  /// **'İşlem Geçmişi Henüz Boş'**
  String get historyEmpty;

  /// No description provided for @upcomingPaymentsNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan Ödeme Bulunmadı'**
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

  /// No description provided for @currentPlan.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Plan'**
  String get currentPlan;

  /// No description provided for @manageSubscription.
  ///
  /// In tr, this message translates to:
  /// **'Üyeliği Yönet'**
  String get manageSubscription;

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

  /// No description provided for @proPlan.
  ///
  /// In tr, this message translates to:
  /// **'Finarcast Premium'**
  String get proPlan;

  /// No description provided for @upgradeToPro.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a Yükselt'**
  String get upgradeToPro;

  /// No description provided for @proFeatures.
  ///
  /// In tr, this message translates to:
  /// **'Premium Özellikleri'**
  String get proFeatures;

  /// No description provided for @unlimitedVaults.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız Kasa'**
  String get unlimitedVaults;

  /// No description provided for @aiInsights.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş AI Analizleri'**
  String get aiInsights;

  /// No description provided for @prioritySupport.
  ///
  /// In tr, this message translates to:
  /// **'Öncelikli Destek'**
  String get prioritySupport;

  /// No description provided for @subscriptionStatus.
  ///
  /// In tr, this message translates to:
  /// **'Üyelik Durumu'**
  String get subscriptionStatus;

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

  /// No description provided for @financialOverview.
  ///
  /// In tr, this message translates to:
  /// **'FİNANSAL ÖZET'**
  String get financialOverview;

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

  /// No description provided for @noRecurring.
  ///
  /// In tr, this message translates to:
  /// **'Tekrarlayan işlem yok'**
  String get noRecurring;

  /// No description provided for @perMonth.
  ///
  /// In tr, this message translates to:
  /// **'/ay'**
  String get perMonth;

  /// No description provided for @perYear.
  ///
  /// In tr, this message translates to:
  /// **'/yıl'**
  String get perYear;

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

  /// No description provided for @authOtpExpired.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama kodunun süresi dolmuş. Lütfen yeni bir kod isteyin.'**
  String get authOtpExpired;

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
  /// **'Lütfen gelen doğrulama kodunu (6 veya 8 haneli) girin.'**
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
