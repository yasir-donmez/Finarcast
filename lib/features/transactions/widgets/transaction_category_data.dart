import 'package:flutter/material.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../l10n/app_localizations.dart';

class TransactionCategoryData {
  /// Özel alt kategorileri built-in kategori listesine merge eder.
  /// Her özel alt kategori, parent kategorisinin ikonunu kullanır.
  /// [categories] — Built-in kategori listesi (deep copy yapılır, orijinal değişmez)
  /// [customSubs] — CustomCategoryService'den gelen özel alt kategoriler
  static List<Map<String, dynamic>> mergeCustomSubcategories(
    List<Map<String, dynamic>> categories,
    List<Map<String, String>> customSubs,
  ) {
    if (customSubs.isEmpty) return categories;

    // Deep copy: orijinal listeyi bozmamak için
    final merged = categories.map((cat) {
      final copy = Map<String, dynamic>.from(cat);
      copy['subModels'] = List<Map<String, dynamic>>.from(
        (cat['subModels'] as List).map((s) => Map<String, dynamic>.from(s)),
      );
      return copy;
    }).toList();

    for (final custom in customSubs) {
      final parentId = custom['parentId'] ?? '';
      final parentIndex = merged.indexWhere((c) => c['id'] == parentId);
      if (parentIndex == -1) continue;

      final parent = merged[parentIndex];
      final subs = parent['subModels'] as List<Map<String, dynamic>>;

      // Zaten eklenmişse tekrar ekleme
      if (subs.any((s) => s['id'] == custom['id'])) continue;

      final int? iconCode = int.tryParse(custom['iconCode'] ?? '');
      subs.add({
        'id': custom['id'] ?? '',
        'name': custom['name'] ?? '',
        'icon': iconCode != null 
            ? IconData(iconCode, fontFamily: 'MaterialIcons') 
            : parent['icon'] as IconData, 
        'isCustom': true,
      });
    }

    return merged;
  }

  static String getCategoryName(BuildContext context, String id) {
    final locale = Localizations.localeOf(context).languageCode;
    final isTr = locale == 'tr';
    
    final Map<String, Map<String, String>> names = {
      // ==========================================
      // GİDERLER (EXPENSES)
      // ==========================================
      // Barınma
      'exp_rent': {'tr': 'Barınma', 'en': 'Housing'},
      'exp_rent_home': {'tr': 'Ev Kirası', 'en': 'Home Rent'},
      'exp_rent_office': {'tr': 'Ofis Kirası', 'en': 'Office Rent'},
      'exp_rent_mortgage': {'tr': 'Konut Kredisi', 'en': 'Mortgage'},
      'exp_rent_maintenance': {'tr': 'Tadilat', 'en': 'Maintenance'},
      'exp_rent_storage': {'tr': 'Depolama', 'en': 'Storage'},
      'exp_rent_insurance': {'tr': 'Konut Sigortası', 'en': 'Home Insurance'},
      'exp_rent_moving': {'tr': 'Taşınma', 'en': 'Moving'},
      'exp_rent_dorm': {'tr': 'Yurt', 'en': 'Dormitory'},
      'exp_rent_room': {'tr': 'Oda Kirası', 'en': 'Room Rent'},
      
      // Faturalar
      'exp_bill': {'tr': 'Faturalar', 'en': 'Bills'},
      'exp_bill_electricity': {'tr': 'Elektrik', 'en': 'Electricity'},
      'exp_bill_water': {'tr': 'Su', 'en': 'Water'},
      'exp_bill_gas': {'tr': 'Doğalgaz', 'en': 'Gas'},
      'exp_bill_internet': {'tr': 'İnternet', 'en': 'Internet'},
      'exp_bill_phone': {'tr': 'Telefon', 'en': 'Phone'},
      'exp_bill_dues': {'tr': 'Aidat', 'en': 'Dues'},
      'exp_bill_tv': {'tr': 'Televizyon', 'en': 'TV'},
      
      // Market
      'exp_grocery': {'tr': 'Market', 'en': 'Grocery'},
      'exp_grocery_food': {'tr': 'Gıda', 'en': 'Food'},
      'exp_grocery_cleaning': {'tr': 'Temizlik', 'en': 'Cleaning'},
      'exp_grocery_drink': {'tr': 'İçecek', 'en': 'Drink'},
      'exp_grocery_pet': {'tr': 'Evcil Hayvan', 'en': 'Pet Care'},
      'exp_grocery_hygiene': {'tr': 'Kişisel Hijyen', 'en': 'Personal Hygiene'},
      'exp_grocery_tobacco': {'tr': 'Tütün', 'en': 'Tobacco'},
      'exp_grocery_alcohol': {'tr': 'Alkol', 'en': 'Alcohol'},
      
      // Yemek
      'exp_dining': {'tr': 'Yemek', 'en': 'Dining'},
      'exp_dining_restaurant': {'tr': 'Restoran', 'en': 'Restaurant'},
      'exp_dining_cafe': {'tr': 'Kafe', 'en': 'Cafe'},
      'exp_dining_fastfood': {'tr': 'Hızlı Yemek', 'en': 'Fast Food'},
      'exp_dining_delivery': {'tr': 'Eve Sipariş', 'en': 'Delivery'},
      'exp_dining_canteen': {'tr': 'Kantin', 'en': 'Canteen'},
      
      // Ulaşım
      'exp_trans': {'tr': 'Ulaşım', 'en': 'Transportation'},
      'exp_trans_bus': {'tr': 'Toplu Taşıma', 'en': 'Public Transit'},
      'exp_trans_taxi': {'tr': 'Taksi', 'en': 'Taxi'},
      'exp_trans_intercity': {'tr': 'Şehirlerarası Ulaşım', 'en': 'Intercity Transit'},
      'exp_trans_scooter': {'tr': 'Mikromobilite', 'en': 'Micromobility'},
      
      // Araç
      'exp_car': {'tr': 'Araç', 'en': 'Vehicle'},
      'exp_car_fuel': {'tr': 'Akaryakıt', 'en': 'Fuel'},
      'exp_car_maintenance': {'tr': 'Bakım', 'en': 'Maintenance'},
      'exp_car_parking': {'tr': 'Otopark', 'en': 'Parking'},
      'exp_car_wash': {'tr': 'Oto Yıkama', 'en': 'Car Wash'},
      'exp_car_toll': {'tr': 'Geçiş Ücreti', 'en': 'Tolls'},
      'exp_car_insurance': {'tr': 'Araç Sigortası', 'en': 'Car Insurance'},
      'exp_car_tax': {'tr': 'Araç Vergisi', 'en': 'Car Tax'},
      'exp_car_rental': {'tr': 'Araç Kiralama', 'en': 'Car Rental'},
      
      // Giyim
      'exp_cloth': {'tr': 'Giyim', 'en': 'Clothing'},
      'exp_cloth_daily': {'tr': 'Günlük Giyim', 'en': 'Daily Wear'},
      'exp_cloth_shoes': {'tr': 'Ayakkabı', 'en': 'Shoes'},
      'exp_cloth_acc': {'tr': 'Aksesuar', 'en': 'Accessory'},
      'exp_cloth_tailor': {'tr': 'Terzi', 'en': 'Tailor'},
      
      // Kişisel Bakım
      'exp_beauty': {'tr': 'Kişisel Bakım', 'en': 'Personal Care'},
      'exp_beauty_salon': {'tr': 'Kuaför', 'en': 'Hairdresser'},
      'exp_beauty_cosmetics': {'tr': 'Kozmetik', 'en': 'Cosmetics'},
      'exp_beauty_spa': {'tr': 'Spa', 'en': 'Spa'},
      'exp_beauty_esthetics': {'tr': 'Estetik', 'en': 'Esthetics'},
      
      // Sağlık
      'exp_health': {'tr': 'Sağlık', 'en': 'Health'},
      'exp_health_doctor': {'tr': 'Muayene', 'en': 'Doctor'},
      'exp_health_medicine': {'tr': 'İlaç', 'en': 'Medicine'},
      'exp_health_dentist': {'tr': 'Diş', 'en': 'Dentist'},
      'exp_health_surgery': {'tr': 'Ameliyat', 'en': 'Surgery'},
      'exp_health_optics': {'tr': 'Gözlük', 'en': 'Optics'},
      'exp_health_veterinary': {'tr': 'Veteriner', 'en': 'Veterinary'},
      'exp_health_therapy': {'tr': 'Terapi', 'en': 'Therapy'},
      'exp_health_supplements': {'tr': 'Destek Gıda', 'en': 'Supplements'},
      'exp_health_insurance': {'tr': 'Sağlık Sigortası', 'en': 'Health Insurance'},
      
      // Abonelikler
      'exp_sub': {'tr': 'Abonelikler', 'en': 'Subscriptions'},
      'exp_sub_stream': {'tr': 'Dizi', 'en': 'Streaming'},
      'exp_sub_music': {'tr': 'Müzik', 'en': 'Music'},
      'exp_sub_gym': {'tr': 'Spor Salonu', 'en': 'Gym'},
      'exp_sub_software': {'tr': 'Yazılım', 'en': 'Software'},
      'exp_sub_publishing': {'tr': 'Yayın', 'en': 'Publishing'},
      'exp_sub_cloud': {'tr': 'Bulut Depolama', 'en': 'Cloud Storage'},
      
      // Eğlence
      'exp_fun': {'tr': 'Eğlence', 'en': 'Entertainment'},
      'exp_fun_cinema': {'tr': 'Sinema', 'en': 'Cinema'},
      'exp_fun_concert': {'tr': 'Konser', 'en': 'Concert'},
      'exp_fun_event': {'tr': 'Etkinlik', 'en': 'Event'},
      'exp_fun_game': {'tr': 'Oyun', 'en': 'Gaming'},
      'exp_fun_hobby': {'tr': 'Hobi', 'en': 'Hobby'},
      'exp_fun_gambling': {'tr': 'Şans Oyunları', 'en': 'Gambling'},
      
      // Eğitim
      'exp_edu': {'tr': 'Eğitim', 'en': 'Education'},
      'exp_edu_school': {'tr': 'Okul', 'en': 'School'},
      'exp_edu_course': {'tr': 'Kurs', 'en': 'Course'},
      'exp_edu_book': {'tr': 'Kitap', 'en': 'Book'},
      'exp_edu_stationery': {'tr': 'Kırtasiye', 'en': 'Stationery'},
      'exp_edu_exams': {'tr': 'Sınavlar', 'en': 'Exams'},
      
      // Aile
      'exp_family': {'tr': 'Aile', 'en': 'Family'},
      'exp_family_baby': {'tr': 'Bebek', 'en': 'Baby'},
      'exp_family_toy': {'tr': 'Oyuncak', 'en': 'Toy'},
      'exp_family_allowance': {'tr': 'Harçlık', 'en': 'Allowance'},
      'exp_family_daycare': {'tr': 'Kreş', 'en': 'Daycare'},
      'exp_family_support': {'tr': 'Aile Desteği', 'en': 'Family Support'},
      'exp_family_care': {'tr': 'Bakıcı', 'en': 'Caregiver'},
      'exp_family_alimony': {'tr': 'Nafaka', 'en': 'Alimony'},
      
      // Alışveriş
      'exp_shopping': {'tr': 'Alışveriş', 'en': 'Shopping'},
      'exp_shopping_tech': {'tr': 'Teknoloji', 'en': 'Tech'},
      'exp_shopping_furniture': {'tr': 'Mobilya', 'en': 'Furniture'},
      'exp_shopping_decor': {'tr': 'Ev Tekstili', 'en': 'Decor'},
      'exp_shopping_kitchen': {'tr': 'Mutfak', 'en': 'Kitchenware'},
      'exp_shopping_gift': {'tr': 'Hediye', 'en': 'Gift'},
      'exp_shopping_general': {'tr': 'Genel', 'en': 'General'},
      'exp_shopping_sports': {'tr': 'Spor Ekipmanı', 'en': 'Sports Equipment'},
      'exp_shopping_shipping': {'tr': 'Kargo', 'en': 'Shipping'},
      
      // Seyahat
      'exp_travel': {'tr': 'Seyahat', 'en': 'Travel'},
      'exp_travel_hotel': {'tr': 'Konaklama', 'en': 'Hotel'},
      'exp_travel_flight': {'tr': 'Ulaşım Bileti', 'en': 'Tickets'},
      'exp_travel_tour': {'tr': 'Turistik Gezi', 'en': 'Tour'},
      'exp_travel_visa': {'tr': 'Vize', 'en': 'Visa'},
      
      // Borç
      'exp_debt': {'tr': 'Borç', 'en': 'Debt'},
      'exp_debt_credit_card': {'tr': 'Kredi Kartı', 'en': 'Credit Card'},
      'exp_debt_loan': {'tr': 'Kredi', 'en': 'Loan'},
      'exp_debt_personal': {'tr': 'Borç Ödeme', 'en': 'Personal Debt'},
      'exp_debt_lending': {'tr': 'Borç Verme', 'en': 'Lending'},
      
      // Birikim ve Yatırım
      'exp_invest': {'tr': 'Yatırım', 'en': 'Investment'},
      'exp_invest_stocks': {'tr': 'Hisse Senedi', 'en': 'Stocks'},
      'exp_invest_gold': {'tr': 'Altın', 'en': 'Gold'},
      'exp_invest_crypto': {'tr': 'Kripto', 'en': 'Crypto'},
      'exp_invest_pension': {'tr': 'Bireysel Emeklilik', 'en': 'Pension Savings'},
      
      // Vergiler
      'exp_tax': {'tr': 'Vergiler', 'en': 'Taxes'},
      'exp_tax_income': {'tr': 'Gelir Vergisi', 'en': 'Income Tax'},
      'exp_tax_fine': {'tr': 'Cezalar', 'en': 'Fines'},
      'exp_tax_fee': {'tr': 'Harçlar', 'en': 'Fees'},
      
      // Diğer Giderler
      'exp_other': {'tr': 'Diğer Giderler', 'en': 'Other Expenses'},
      'exp_other_general': {'tr': 'Genel Gider', 'en': 'General'},
      'exp_other_donation': {'tr': 'Bağış', 'en': 'Donation'},
      'exp_other_tip': {'tr': 'Bahşiş', 'en': 'Tip'},
      'exp_other_bank_fee': {'tr': 'Banka Ücreti', 'en': 'Bank Fee'},

      // ==========================================
      // GELİRLER (INCOMES)
      // ==========================================
      // Maaş
      'inc_salary': {'tr': 'Maaş', 'en': 'Salary'},
      'inc_salary_main': {'tr': 'Ana Maaş', 'en': 'Main Salary'},
      'inc_salary_bonus': {'tr': 'Prim', 'en': 'Bonus'},
      'inc_salary_dividend': {'tr': 'Kâr Payı', 'en': 'Dividend'},
      'inc_salary_pension': {'tr': 'Emeklilik', 'en': 'Pension'},
      'inc_salary_severance': {'tr': 'Tazminat', 'en': 'Severance'},
      
      // Ek Gelir
      'inc_extra': {'tr': 'Ek Gelir', 'en': 'Side Income'},
      'inc_extra_freelance': {'tr': 'Freelance', 'en': 'Freelance'},
      'inc_extra_parttime': {'tr': 'Yarı Zamanlı', 'en': 'Part Time'},
      'inc_extra_commission': {'tr': 'Komisyon', 'en': 'Commission'},
      'inc_extra_content': {'tr': 'İçerik Üreticiliği', 'en': 'Content Creation'},
      'inc_extra_affiliate': {'tr': 'Satış Ortaklığı', 'en': 'Affiliate'},
      
      // Yatırım Geliri
      'inc_invest': {'tr': 'Yatırım Geliri', 'en': 'Investment Income'},
      'inc_invest_stock': {'tr': 'Hisse Senedi', 'en': 'Stock'},
      'inc_invest_crypto': {'tr': 'Kripto', 'en': 'Crypto'},
      'inc_invest_interest': {'tr': 'Faiz', 'en': 'Interest'},
      'inc_invest_gold': {'tr': 'Altın', 'en': 'Gold'},
      'inc_invest_forex': {'tr': 'Döviz Kârı', 'en': 'Forex'},
      'inc_invest_bond': {'tr': 'Tahvil', 'en': 'Bond'},
      
      // Kira Geliri
      'inc_rent': {'tr': 'Kira Geliri', 'en': 'Rental Income'},
      'inc_rent_home': {'tr': 'Konut Kirası', 'en': 'Home Rent'},
      'inc_rent_office': {'tr': 'İş Yeri Kirası', 'en': 'Office Rent'},
      'inc_rent_car': {'tr': 'Araç Kirası', 'en': 'Car Rent'},
      'inc_rent_equipment': {'tr': 'Ekipman Kirası', 'en': 'Equipment Rent'},
      
      // Burs
      'inc_scholarship': {'tr': 'Burs', 'en': 'Scholarship'},
      'inc_scholarship_award': {'tr': 'Öğrenim Bursu', 'en': 'Scholarship'},
      'inc_scholarship_loan': {'tr': 'Öğrenim Kredisi', 'en': 'Student Loan'},
      'inc_scholarship_gov': {'tr': 'Sosyal Yardım', 'en': 'Support'},
      'inc_scholarship_grant': {'tr': 'Proje Desteği', 'en': 'Project Grant'},
      
      // Satış
      'inc_sale': {'tr': 'Satış', 'en': 'Sales'},
      'inc_sale_online': {'tr': 'Online Satış', 'en': 'Online Sale'},
      'inc_sale_physical': {'tr': 'İkinci El Satış', 'en': 'Second Hand'},
      'inc_sale_vehicle': {'tr': 'Araç Satışı', 'en': 'Vehicle Sale'},
      'inc_sale_property': {'tr': 'Gayrimenkul Satışı', 'en': 'Real Estate Sale'},
      
      // Hediye
      'inc_gift': {'tr': 'Hediye', 'en': 'Gift'},
      'inc_gift_general': {'tr': 'Nakit Hediye', 'en': 'Gift'},
      'inc_gift_award': {'tr': 'Ödül', 'en': 'Award'},
      'inc_gift_inheritance': {'tr': 'Miras', 'en': 'Inheritance'},
      'inc_gift_alimony': {'tr': 'Nafaka', 'en': 'Alimony'},
      'inc_gift_allowance': {'tr': 'Harçlık', 'en': 'Allowance'},
      
      // Diğer Gelirler
      'inc_other': {'tr': 'Diğer Gelirler', 'en': 'Other Incomes'},
      'inc_other_general': {'tr': 'Genel Gelir', 'en': 'Other'},
      'inc_other_refund': {'tr': 'İade', 'en': 'Refund'},
      'inc_other_lottery': {'tr': 'Şans Oyunları', 'en': 'Lottery'},
      'inc_other_collection': {'tr': 'Borç Tahsilatı', 'en': 'Debt Collection'},
      'inc_other_cashback': {'tr': 'Cashback', 'en': 'Cashback'},
      'inc_other_tax_refund': {'tr': 'Vergi İadesi', 'en': 'Tax Refund'},
    };
    
    final localized = names[id];
    if (localized != null) {
      return isTr ? (localized['tr'] ?? '') : (localized['en'] ?? '');
    }
    return '';
  }

  static List<Map<String, dynamic>> getExpenseCategories(BuildContext context, AppLocalizations l10n) => [
    {
      'id': 'exp_rent',
      'name': getCategoryName(context, 'exp_rent'),
      'icon': IconUtils.getIcon('exp_rent'),
      'color': IconUtils.getColor('exp_rent'),
      'subModels': [
        {
          'id': 'exp_rent_home',
          'name': getCategoryName(context, 'exp_rent_home'),
          'icon': IconUtils.getIcon('exp_rent_home'),
        },
        {
          'id': 'exp_rent_office',
          'name': getCategoryName(context, 'exp_rent_office'),
          'icon': IconUtils.getIcon('exp_rent_office'),
        },
        {
          'id': 'exp_rent_mortgage',
          'name': getCategoryName(context, 'exp_rent_mortgage'),
          'icon': IconUtils.getIcon('exp_rent_mortgage'),
        },
        {
          'id': 'exp_rent_maintenance',
          'name': getCategoryName(context, 'exp_rent_maintenance'),
          'icon': IconUtils.getIcon('exp_rent_maintenance'),
        },
        {
          'id': 'exp_rent_storage',
          'name': getCategoryName(context, 'exp_rent_storage'),
          'icon': IconUtils.getIcon('exp_rent_storage'),
        },
        {
          'id': 'exp_rent_insurance',
          'name': getCategoryName(context, 'exp_rent_insurance'),
          'icon': IconUtils.getIcon('exp_rent_insurance'),
        },
        {
          'id': 'exp_rent_moving',
          'name': getCategoryName(context, 'exp_rent_moving'),
          'icon': IconUtils.getIcon('exp_rent_moving'),
        },
        {
          'id': 'exp_rent_dorm',
          'name': getCategoryName(context, 'exp_rent_dorm'),
          'icon': IconUtils.getIcon('exp_rent_dorm'),
        },
        {
          'id': 'exp_rent_room',
          'name': getCategoryName(context, 'exp_rent_room'),
          'icon': IconUtils.getIcon('exp_rent_room'),
        },
      ],
    },
    {
      'id': 'exp_bill',
      'name': getCategoryName(context, 'exp_bill'),
      'icon': IconUtils.getIcon('exp_bill'),
      'color': IconUtils.getColor('exp_bill'),
      'subModels': [
        {
          'id': 'exp_bill_electricity',
          'name': getCategoryName(context, 'exp_bill_electricity'),
          'icon': IconUtils.getIcon('exp_bill_electricity'),
        },
        {
          'id': 'exp_bill_water',
          'name': getCategoryName(context, 'exp_bill_water'),
          'icon': IconUtils.getIcon('exp_bill_water'),
        },
        {
          'id': 'exp_bill_gas',
          'name': getCategoryName(context, 'exp_bill_gas'),
          'icon': IconUtils.getIcon('exp_bill_gas'),
        },
        {
          'id': 'exp_bill_internet',
          'name': getCategoryName(context, 'exp_bill_internet'),
          'icon': IconUtils.getIcon('exp_bill_internet'),
        },
        {
          'id': 'exp_bill_phone',
          'name': getCategoryName(context, 'exp_bill_phone'),
          'icon': IconUtils.getIcon('exp_bill_phone'),
        },
        {
          'id': 'exp_bill_dues',
          'name': getCategoryName(context, 'exp_bill_dues'),
          'icon': IconUtils.getIcon('exp_bill_dues'),
        },
        {
          'id': 'exp_bill_tv',
          'name': getCategoryName(context, 'exp_bill_tv'),
          'icon': IconUtils.getIcon('exp_bill_tv'),
        },
      ],
    },
    {
      'id': 'exp_grocery',
      'name': getCategoryName(context, 'exp_grocery'),
      'icon': IconUtils.getIcon('exp_grocery'),
      'color': IconUtils.getColor('exp_grocery'),
      'subModels': [
        {
          'id': 'exp_grocery_food',
          'name': getCategoryName(context, 'exp_grocery_food'),
          'icon': IconUtils.getIcon('exp_grocery_food'),
        },
        {
          'id': 'exp_grocery_cleaning',
          'name': getCategoryName(context, 'exp_grocery_cleaning'),
          'icon': IconUtils.getIcon('exp_grocery_cleaning'),
        },
        {
          'id': 'exp_grocery_drink',
          'name': getCategoryName(context, 'exp_grocery_drink'),
          'icon': IconUtils.getIcon('exp_grocery_drink'),
        },
        {
          'id': 'exp_grocery_pet',
          'name': getCategoryName(context, 'exp_grocery_pet'),
          'icon': IconUtils.getIcon('exp_grocery_pet'),
        },
        {
          'id': 'exp_grocery_hygiene',
          'name': getCategoryName(context, 'exp_grocery_hygiene'),
          'icon': IconUtils.getIcon('exp_grocery_hygiene'),
        },
        {
          'id': 'exp_grocery_tobacco',
          'name': getCategoryName(context, 'exp_grocery_tobacco'),
          'icon': IconUtils.getIcon('exp_grocery_tobacco'),
        },
        {
          'id': 'exp_grocery_alcohol',
          'name': getCategoryName(context, 'exp_grocery_alcohol'),
          'icon': IconUtils.getIcon('exp_grocery_alcohol'),
        },
      ],
    },
    {
      'id': 'exp_dining',
      'name': getCategoryName(context, 'exp_dining'),
      'icon': IconUtils.getIcon('exp_dining'),
      'color': IconUtils.getColor('exp_dining'),
      'subModels': [
        {
          'id': 'exp_dining_restaurant',
          'name': getCategoryName(context, 'exp_dining_restaurant'),
          'icon': IconUtils.getIcon('exp_dining_restaurant'),
        },
        {
          'id': 'exp_dining_cafe',
          'name': getCategoryName(context, 'exp_dining_cafe'),
          'icon': IconUtils.getIcon('exp_dining_cafe'),
        },
        {
          'id': 'exp_dining_fastfood',
          'name': getCategoryName(context, 'exp_dining_fastfood'),
          'icon': IconUtils.getIcon('exp_dining_fastfood'),
        },
        {
          'id': 'exp_dining_delivery',
          'name': getCategoryName(context, 'exp_dining_delivery'),
          'icon': IconUtils.getIcon('exp_dining_delivery'),
        },
        {
          'id': 'exp_dining_canteen',
          'name': getCategoryName(context, 'exp_dining_canteen'),
          'icon': IconUtils.getIcon('exp_dining_canteen'),
        },
      ],
    },
    {
      'id': 'exp_trans',
      'name': getCategoryName(context, 'exp_trans'),
      'icon': IconUtils.getIcon('exp_trans'),
      'color': IconUtils.getColor('exp_trans'),
      'subModels': [
        {
          'id': 'exp_trans_bus',
          'name': getCategoryName(context, 'exp_trans_bus'),
          'icon': IconUtils.getIcon('exp_trans_bus'),
        },
        {
          'id': 'exp_trans_taxi',
          'name': getCategoryName(context, 'exp_trans_taxi'),
          'icon': IconUtils.getIcon('exp_trans_taxi'),
        },
        {
          'id': 'exp_trans_intercity',
          'name': getCategoryName(context, 'exp_trans_intercity'),
          'icon': IconUtils.getIcon('exp_trans_intercity'),
        },
        {
          'id': 'exp_trans_scooter',
          'name': getCategoryName(context, 'exp_trans_scooter'),
          'icon': IconUtils.getIcon('exp_trans_scooter'),
        },
      ],
    },
    {
      'id': 'exp_car',
      'name': getCategoryName(context, 'exp_car'),
      'icon': IconUtils.getIcon('exp_car'),
      'color': IconUtils.getColor('exp_car'),
      'subModels': [
        {
          'id': 'exp_car_fuel',
          'name': getCategoryName(context, 'exp_car_fuel'),
          'icon': IconUtils.getIcon('exp_car_fuel'),
        },
        {
          'id': 'exp_car_maintenance',
          'name': getCategoryName(context, 'exp_car_maintenance'),
          'icon': IconUtils.getIcon('exp_car_maintenance'),
        },
        {
          'id': 'exp_car_parking',
          'name': getCategoryName(context, 'exp_car_parking'),
          'icon': IconUtils.getIcon('exp_car_parking'),
        },
        {
          'id': 'exp_car_wash',
          'name': getCategoryName(context, 'exp_car_wash'),
          'icon': IconUtils.getIcon('exp_car_wash'),
        },
        {
          'id': 'exp_car_toll',
          'name': getCategoryName(context, 'exp_car_toll'),
          'icon': IconUtils.getIcon('exp_car_toll'),
        },
        {
          'id': 'exp_car_insurance',
          'name': getCategoryName(context, 'exp_car_insurance'),
          'icon': IconUtils.getIcon('exp_car_insurance'),
        },
        {
          'id': 'exp_car_tax',
          'name': getCategoryName(context, 'exp_car_tax'),
          'icon': IconUtils.getIcon('exp_car_tax'),
        },
        {
          'id': 'exp_car_rental',
          'name': getCategoryName(context, 'exp_car_rental'),
          'icon': IconUtils.getIcon('exp_car_rental'),
        },
      ],
    },
    {
      'id': 'exp_cloth',
      'name': getCategoryName(context, 'exp_cloth'),
      'icon': IconUtils.getIcon('exp_cloth'),
      'color': IconUtils.getColor('exp_cloth'),
      'subModels': [
        {
          'id': 'exp_cloth_daily',
          'name': getCategoryName(context, 'exp_cloth_daily'),
          'icon': IconUtils.getIcon('exp_cloth_daily'),
        },
        {
          'id': 'exp_cloth_shoes',
          'name': getCategoryName(context, 'exp_cloth_shoes'),
          'icon': IconUtils.getIcon('exp_cloth_shoes'),
        },
        {
          'id': 'exp_cloth_acc',
          'name': getCategoryName(context, 'exp_cloth_acc'),
          'icon': IconUtils.getIcon('exp_cloth_acc'),
        },
        {
          'id': 'exp_cloth_tailor',
          'name': getCategoryName(context, 'exp_cloth_tailor'),
          'icon': IconUtils.getIcon('exp_cloth_tailor'),
        },
      ],
    },
    {
      'id': 'exp_beauty',
      'name': getCategoryName(context, 'exp_beauty'),
      'icon': IconUtils.getIcon('exp_beauty'),
      'color': IconUtils.getColor('exp_beauty'),
      'subModels': [
        {
          'id': 'exp_beauty_salon',
          'name': getCategoryName(context, 'exp_beauty_salon'),
          'icon': IconUtils.getIcon('exp_beauty_salon'),
        },
        {
          'id': 'exp_beauty_cosmetics',
          'name': getCategoryName(context, 'exp_beauty_cosmetics'),
          'icon': IconUtils.getIcon('exp_beauty_cosmetics'),
        },
        {
          'id': 'exp_beauty_spa',
          'name': getCategoryName(context, 'exp_beauty_spa'),
          'icon': IconUtils.getIcon('exp_beauty_spa'),
        },
        {
          'id': 'exp_beauty_esthetics',
          'name': getCategoryName(context, 'exp_beauty_esthetics'),
          'icon': IconUtils.getIcon('exp_beauty_esthetics'),
        },
      ],
    },
    {
      'id': 'exp_health',
      'name': getCategoryName(context, 'exp_health'),
      'icon': IconUtils.getIcon('exp_health'),
      'color': IconUtils.getColor('exp_health'),
      'subModels': [
        {
          'id': 'exp_health_doctor',
          'name': getCategoryName(context, 'exp_health_doctor'),
          'icon': IconUtils.getIcon('exp_health_doctor'),
        },
        {
          'id': 'exp_health_medicine',
          'name': getCategoryName(context, 'exp_health_medicine'),
          'icon': IconUtils.getIcon('exp_health_medicine'),
        },
        {
          'id': 'exp_health_dentist',
          'name': getCategoryName(context, 'exp_health_dentist'),
          'icon': IconUtils.getIcon('exp_health_dentist'),
        },
        {
          'id': 'exp_health_surgery',
          'name': getCategoryName(context, 'exp_health_surgery'),
          'icon': IconUtils.getIcon('exp_health_surgery'),
        },
        {
          'id': 'exp_health_optics',
          'name': getCategoryName(context, 'exp_health_optics'),
          'icon': IconUtils.getIcon('exp_health_optics'),
        },
        {
          'id': 'exp_health_veterinary',
          'name': getCategoryName(context, 'exp_health_veterinary'),
          'icon': IconUtils.getIcon('exp_health_veterinary'),
        },
        {
          'id': 'exp_health_therapy',
          'name': getCategoryName(context, 'exp_health_therapy'),
          'icon': IconUtils.getIcon('exp_health_therapy'),
        },
        {
          'id': 'exp_health_supplements',
          'name': getCategoryName(context, 'exp_health_supplements'),
          'icon': IconUtils.getIcon('exp_health_supplements'),
        },
        {
          'id': 'exp_health_insurance',
          'name': getCategoryName(context, 'exp_health_insurance'),
          'icon': IconUtils.getIcon('exp_health_insurance'),
        },
      ],
    },
    {
      'id': 'exp_sub',
      'name': getCategoryName(context, 'exp_sub'),
      'icon': IconUtils.getIcon('exp_sub'),
      'color': IconUtils.getColor('exp_sub'),
      'subModels': [
        {
          'id': 'exp_sub_stream',
          'name': getCategoryName(context, 'exp_sub_stream'),
          'icon': IconUtils.getIcon('exp_sub_stream'),
        },
        {
          'id': 'exp_sub_music',
          'name': getCategoryName(context, 'exp_sub_music'),
          'icon': IconUtils.getIcon('exp_sub_music'),
        },
        {
          'id': 'exp_sub_gym',
          'name': getCategoryName(context, 'exp_sub_gym'),
          'icon': IconUtils.getIcon('exp_sub_gym'),
        },
        {
          'id': 'exp_sub_software',
          'name': getCategoryName(context, 'exp_sub_software'),
          'icon': IconUtils.getIcon('exp_sub_software'),
        },
        {
          'id': 'exp_sub_publishing',
          'name': getCategoryName(context, 'exp_sub_publishing'),
          'icon': IconUtils.getIcon('exp_sub_publishing'),
        },
        {
          'id': 'exp_sub_cloud',
          'name': getCategoryName(context, 'exp_sub_cloud'),
          'icon': IconUtils.getIcon('exp_sub_cloud'),
        },
      ],
    },
    {
      'id': 'exp_fun',
      'name': getCategoryName(context, 'exp_fun'),
      'icon': IconUtils.getIcon('exp_fun'),
      'color': IconUtils.getColor('exp_fun'),
      'subModels': [
        {
          'id': 'exp_fun_cinema',
          'name': getCategoryName(context, 'exp_fun_cinema'),
          'icon': IconUtils.getIcon('exp_fun_cinema'),
        },
        {
          'id': 'exp_fun_concert',
          'name': getCategoryName(context, 'exp_fun_concert'),
          'icon': IconUtils.getIcon('exp_fun_concert'),
        },
        {
          'id': 'exp_fun_event',
          'name': getCategoryName(context, 'exp_fun_event'),
          'icon': IconUtils.getIcon('exp_fun_event'),
        },
        {
          'id': 'exp_fun_game',
          'name': getCategoryName(context, 'exp_fun_game'),
          'icon': IconUtils.getIcon('exp_fun_game'),
        },
        {
          'id': 'exp_fun_hobby',
          'name': getCategoryName(context, 'exp_fun_hobby'),
          'icon': IconUtils.getIcon('exp_fun_hobby'),
        },
        {
          'id': 'exp_fun_gambling',
          'name': getCategoryName(context, 'exp_fun_gambling'),
          'icon': IconUtils.getIcon('exp_fun_gambling'),
        },
      ],
    },
    {
      'id': 'exp_edu',
      'name': getCategoryName(context, 'exp_edu'),
      'icon': IconUtils.getIcon('exp_edu'),
      'color': IconUtils.getColor('exp_edu'),
      'subModels': [
        {
          'id': 'exp_edu_school',
          'name': getCategoryName(context, 'exp_edu_school'),
          'icon': IconUtils.getIcon('exp_edu_school'),
        },
        {
          'id': 'exp_edu_course',
          'name': getCategoryName(context, 'exp_edu_course'),
          'icon': IconUtils.getIcon('exp_edu_course'),
        },
        {
          'id': 'exp_edu_book',
          'name': getCategoryName(context, 'exp_edu_book'),
          'icon': IconUtils.getIcon('exp_edu_book'),
        },
        {
          'id': 'exp_edu_stationery',
          'name': getCategoryName(context, 'exp_edu_stationery'),
          'icon': IconUtils.getIcon('exp_edu_stationery'),
        },
        {
          'id': 'exp_edu_exams',
          'name': getCategoryName(context, 'exp_edu_exams'),
          'icon': IconUtils.getIcon('exp_edu_exams'),
        },
      ],
    },
    {
      'id': 'exp_family',
      'name': getCategoryName(context, 'exp_family'),
      'icon': IconUtils.getIcon('exp_family'),
      'color': IconUtils.getColor('exp_family'),
      'subModels': [
        {
          'id': 'exp_family_baby',
          'name': getCategoryName(context, 'exp_family_baby'),
          'icon': IconUtils.getIcon('exp_family_baby'),
        },
        {
          'id': 'exp_family_toy',
          'name': getCategoryName(context, 'exp_family_toy'),
          'icon': IconUtils.getIcon('exp_family_toy'),
        },
        {
          'id': 'exp_family_allowance',
          'name': getCategoryName(context, 'exp_family_allowance'),
          'icon': IconUtils.getIcon('exp_family_allowance'),
        },
        {
          'id': 'exp_family_daycare',
          'name': getCategoryName(context, 'exp_family_daycare'),
          'icon': IconUtils.getIcon('exp_family_daycare'),
        },
        {
          'id': 'exp_family_support',
          'name': getCategoryName(context, 'exp_family_support'),
          'icon': IconUtils.getIcon('exp_family_support'),
        },
        {
          'id': 'exp_family_care',
          'name': getCategoryName(context, 'exp_family_care'),
          'icon': IconUtils.getIcon('exp_family_care'),
        },
        {
          'id': 'exp_family_alimony',
          'name': getCategoryName(context, 'exp_family_alimony'),
          'icon': IconUtils.getIcon('exp_family_alimony'),
        },
      ],
    },
    {
      'id': 'exp_shopping',
      'name': getCategoryName(context, 'exp_shopping'),
      'icon': IconUtils.getIcon('exp_shopping'),
      'color': IconUtils.getColor('exp_shopping'),
      'subModels': [
        {
          'id': 'exp_shopping_tech',
          'name': getCategoryName(context, 'exp_shopping_tech'),
          'icon': IconUtils.getIcon('exp_shopping_tech'),
        },
        {
          'id': 'exp_shopping_furniture',
          'name': getCategoryName(context, 'exp_shopping_furniture'),
          'icon': IconUtils.getIcon('exp_shopping_furniture'),
        },
        {
          'id': 'exp_shopping_decor',
          'name': getCategoryName(context, 'exp_shopping_decor'),
          'icon': IconUtils.getIcon('exp_shopping_decor'),
        },
        {
          'id': 'exp_shopping_kitchen',
          'name': getCategoryName(context, 'exp_shopping_kitchen'),
          'icon': IconUtils.getIcon('exp_shopping_kitchen'),
        },
        {
          'id': 'exp_shopping_gift',
          'name': getCategoryName(context, 'exp_shopping_gift'),
          'icon': IconUtils.getIcon('exp_shopping_gift'),
        },
        {
          'id': 'exp_shopping_general',
          'name': getCategoryName(context, 'exp_shopping_general'),
          'icon': IconUtils.getIcon('exp_shopping_general'),
        },
        {
          'id': 'exp_shopping_sports',
          'name': getCategoryName(context, 'exp_shopping_sports'),
          'icon': IconUtils.getIcon('exp_shopping_sports'),
        },
        {
          'id': 'exp_shopping_shipping',
          'name': getCategoryName(context, 'exp_shopping_shipping'),
          'icon': IconUtils.getIcon('exp_shopping_shipping'),
        },
      ],
    },
    {
      'id': 'exp_travel',
      'name': getCategoryName(context, 'exp_travel'),
      'icon': IconUtils.getIcon('exp_travel'),
      'color': IconUtils.getColor('exp_travel'),
      'subModels': [
        {
          'id': 'exp_travel_hotel',
          'name': getCategoryName(context, 'exp_travel_hotel'),
          'icon': IconUtils.getIcon('exp_travel_hotel'),
        },
        {
          'id': 'exp_travel_flight',
          'name': getCategoryName(context, 'exp_travel_flight'),
          'icon': IconUtils.getIcon('exp_travel_flight'),
        },
        {
          'id': 'exp_travel_tour',
          'name': getCategoryName(context, 'exp_travel_tour'),
          'icon': IconUtils.getIcon('exp_travel_tour'),
        },
        {
          'id': 'exp_travel_visa',
          'name': getCategoryName(context, 'exp_travel_visa'),
          'icon': IconUtils.getIcon('exp_travel_visa'),
        },
      ],
    },
    {
      'id': 'exp_debt',
      'name': getCategoryName(context, 'exp_debt'),
      'icon': IconUtils.getIcon('exp_debt'),
      'color': IconUtils.getColor('exp_debt'),
      'subModels': [
        {
          'id': 'exp_debt_credit_card',
          'name': getCategoryName(context, 'exp_debt_credit_card'),
          'icon': IconUtils.getIcon('exp_debt_credit_card'),
        },
        {
          'id': 'exp_debt_loan',
          'name': getCategoryName(context, 'exp_debt_loan'),
          'icon': IconUtils.getIcon('exp_debt_loan'),
        },
        {
          'id': 'exp_debt_personal',
          'name': getCategoryName(context, 'exp_debt_personal'),
          'icon': IconUtils.getIcon('exp_debt_personal'),
        },
        {
          'id': 'exp_debt_lending',
          'name': getCategoryName(context, 'exp_debt_lending'),
          'icon': IconUtils.getIcon('exp_debt_lending'),
        },
      ],
    },
    {
      'id': 'exp_invest',
      'name': getCategoryName(context, 'exp_invest'),
      'icon': IconUtils.getIcon('exp_invest'),
      'color': IconUtils.getColor('exp_invest'),
      'subModels': [
        {
          'id': 'exp_invest_stocks',
          'name': getCategoryName(context, 'exp_invest_stocks'),
          'icon': IconUtils.getIcon('exp_invest_stocks'),
        },
        {
          'id': 'exp_invest_gold',
          'name': getCategoryName(context, 'exp_invest_gold'),
          'icon': IconUtils.getIcon('exp_invest_gold'),
        },
        {
          'id': 'exp_invest_crypto',
          'name': getCategoryName(context, 'exp_invest_crypto'),
          'icon': IconUtils.getIcon('exp_invest_crypto'),
        },
        {
          'id': 'exp_invest_pension',
          'name': getCategoryName(context, 'exp_invest_pension'),
          'icon': IconUtils.getIcon('exp_invest_pension'),
        },
      ],
    },
    {
      'id': 'exp_tax',
      'name': getCategoryName(context, 'exp_tax'),
      'icon': IconUtils.getIcon('exp_tax'),
      'color': IconUtils.getColor('exp_tax'),
      'subModels': [
        {
          'id': 'exp_tax_income',
          'name': getCategoryName(context, 'exp_tax_income'),
          'icon': IconUtils.getIcon('exp_tax_income'),
        },
        {
          'id': 'exp_tax_fine',
          'name': getCategoryName(context, 'exp_tax_fine'),
          'icon': IconUtils.getIcon('exp_tax_fine'),
        },
        {
          'id': 'exp_tax_fee',
          'name': getCategoryName(context, 'exp_tax_fee'),
          'icon': IconUtils.getIcon('exp_tax_fee'),
        },
      ],
    },
    {
      'id': 'exp_other',
      'name': getCategoryName(context, 'exp_other'),
      'icon': IconUtils.getIcon('exp_other'),
      'color': IconUtils.getColor('exp_other'),
      'subModels': [
        {
          'id': 'exp_other_general',
          'name': getCategoryName(context, 'exp_other_general'),
          'icon': IconUtils.getIcon('exp_other_general'),
        },
        {
          'id': 'exp_other_donation',
          'name': getCategoryName(context, 'exp_other_donation'),
          'icon': IconUtils.getIcon('exp_other_donation'),
        },
        {
          'id': 'exp_other_tip',
          'name': getCategoryName(context, 'exp_other_tip'),
          'icon': IconUtils.getIcon('exp_other_tip'),
        },
        {
          'id': 'exp_other_bank_fee',
          'name': getCategoryName(context, 'exp_other_bank_fee'),
          'icon': IconUtils.getIcon('exp_other_bank_fee'),
        },
      ],
    },
  ];

  static List<Map<String, dynamic>> getIncomeCategories(BuildContext context, AppLocalizations l10n) => [
    {
      'id': 'inc_salary',
      'name': getCategoryName(context, 'inc_salary'),
      'icon': IconUtils.getIcon('inc_salary'),
      'color': IconUtils.getColor('inc_salary'),
      'subModels': [
        {
          'id': 'inc_salary_main',
          'name': getCategoryName(context, 'inc_salary_main'),
          'icon': IconUtils.getIcon('inc_salary_main'),
        },
        {
          'id': 'inc_salary_bonus',
          'name': getCategoryName(context, 'inc_salary_bonus'),
          'icon': IconUtils.getIcon('inc_salary_bonus'),
        },
        {
          'id': 'inc_salary_dividend',
          'name': getCategoryName(context, 'inc_salary_dividend'),
          'icon': IconUtils.getIcon('inc_salary_dividend'),
        },
        {
          'id': 'inc_salary_pension',
          'name': getCategoryName(context, 'inc_salary_pension'),
          'icon': IconUtils.getIcon('inc_salary_pension'),
        },
        {
          'id': 'inc_salary_severance',
          'name': getCategoryName(context, 'inc_salary_severance'),
          'icon': IconUtils.getIcon('inc_salary_severance'),
        },
      ],
    },
    {
      'id': 'inc_extra',
      'name': getCategoryName(context, 'inc_extra'),
      'icon': IconUtils.getIcon('inc_extra'),
      'color': IconUtils.getColor('inc_extra'),
      'subModels': [
        {
          'id': 'inc_extra_freelance',
          'name': getCategoryName(context, 'inc_extra_freelance'),
          'icon': IconUtils.getIcon('inc_extra_freelance'),
        },
        {
          'id': 'inc_extra_parttime',
          'name': getCategoryName(context, 'inc_extra_parttime'),
          'icon': IconUtils.getIcon('inc_extra_parttime'),
        },
        {
          'id': 'inc_extra_commission',
          'name': getCategoryName(context, 'inc_extra_commission'),
          'icon': IconUtils.getIcon('inc_extra_commission'),
        },
        {
          'id': 'inc_extra_content',
          'name': getCategoryName(context, 'inc_extra_content'),
          'icon': IconUtils.getIcon('inc_extra_content'),
        },
        {
          'id': 'inc_extra_affiliate',
          'name': getCategoryName(context, 'inc_extra_affiliate'),
          'icon': IconUtils.getIcon('inc_extra_affiliate'),
        },
      ],
    },
    {
      'id': 'inc_invest',
      'name': getCategoryName(context, 'inc_invest'),
      'icon': IconUtils.getIcon('inc_invest'),
      'color': IconUtils.getColor('inc_invest'),
      'subModels': [
        {
          'id': 'inc_invest_stock',
          'name': getCategoryName(context, 'inc_invest_stock'),
          'icon': IconUtils.getIcon('inc_invest_stock'),
        },
        {
          'id': 'inc_invest_crypto',
          'name': getCategoryName(context, 'inc_invest_crypto'),
          'icon': IconUtils.getIcon('inc_invest_crypto'),
        },
        {
          'id': 'inc_invest_interest',
          'name': getCategoryName(context, 'inc_invest_interest'),
          'icon': IconUtils.getIcon('inc_invest_interest'),
        },
        {
          'id': 'inc_invest_gold',
          'name': getCategoryName(context, 'inc_invest_gold'),
          'icon': IconUtils.getIcon('inc_invest_gold'),
        },
        {
          'id': 'inc_invest_forex',
          'name': getCategoryName(context, 'inc_invest_forex'),
          'icon': IconUtils.getIcon('inc_invest_forex'),
        },
        {
          'id': 'inc_invest_bond',
          'name': getCategoryName(context, 'inc_invest_bond'),
          'icon': IconUtils.getIcon('inc_invest_bond'),
        },
      ],
    },
    {
      'id': 'inc_rent',
      'name': getCategoryName(context, 'inc_rent'),
      'icon': IconUtils.getIcon('inc_rent'),
      'color': IconUtils.getColor('inc_rent'),
      'subModels': [
        {
          'id': 'inc_rent_home',
          'name': getCategoryName(context, 'inc_rent_home'),
          'icon': IconUtils.getIcon('inc_rent_home'),
        },
        {
          'id': 'inc_rent_office',
          'name': getCategoryName(context, 'inc_rent_office'),
          'icon': IconUtils.getIcon('inc_rent_office'),
        },
        {
          'id': 'inc_rent_car',
          'name': getCategoryName(context, 'inc_rent_car'),
          'icon': IconUtils.getIcon('inc_rent_car'),
        },
        {
          'id': 'inc_rent_equipment',
          'name': getCategoryName(context, 'inc_rent_equipment'),
          'icon': IconUtils.getIcon('inc_rent_equipment'),
        },
      ],
    },
    {
      'id': 'inc_scholarship',
      'name': getCategoryName(context, 'inc_scholarship'),
      'icon': IconUtils.getIcon('inc_scholarship'),
      'color': IconUtils.getColor('inc_scholarship'),
      'subModels': [
        {
          'id': 'inc_scholarship_award',
          'name': getCategoryName(context, 'inc_scholarship_award'),
          'icon': IconUtils.getIcon('inc_scholarship_award'),
        },
        {
          'id': 'inc_scholarship_loan',
          'name': getCategoryName(context, 'inc_scholarship_loan'),
          'icon': IconUtils.getIcon('inc_scholarship_loan'),
        },
        {
          'id': 'inc_scholarship_gov',
          'name': getCategoryName(context, 'inc_scholarship_gov'),
          'icon': IconUtils.getIcon('inc_scholarship_gov'),
        },
        {
          'id': 'inc_scholarship_grant',
          'name': getCategoryName(context, 'inc_scholarship_grant'),
          'icon': IconUtils.getIcon('inc_scholarship_grant'),
        },
      ],
    },
    {
      'id': 'inc_sale',
      'name': getCategoryName(context, 'inc_sale'),
      'icon': IconUtils.getIcon('inc_sale'),
      'color': IconUtils.getColor('inc_sale'),
      'subModels': [
        {
          'id': 'inc_sale_online',
          'name': getCategoryName(context, 'inc_sale_online'),
          'icon': IconUtils.getIcon('inc_sale_online'),
        },
        {
          'id': 'inc_sale_physical',
          'name': getCategoryName(context, 'inc_sale_physical'),
          'icon': IconUtils.getIcon('inc_sale_physical'),
        },
        {
          'id': 'inc_sale_vehicle',
          'name': getCategoryName(context, 'inc_sale_vehicle'),
          'icon': IconUtils.getIcon('inc_sale_vehicle'),
        },
        {
          'id': 'inc_sale_property',
          'name': getCategoryName(context, 'inc_sale_property'),
          'icon': IconUtils.getIcon('inc_sale_property'),
        },
      ],
    },
    {
      'id': 'inc_gift',
      'name': getCategoryName(context, 'inc_gift'),
      'icon': IconUtils.getIcon('inc_gift'),
      'color': IconUtils.getColor('inc_gift'),
      'subModels': [
        {
          'id': 'inc_gift_general',
          'name': getCategoryName(context, 'inc_gift_general'),
          'icon': IconUtils.getIcon('inc_gift_general'),
        },
        {
          'id': 'inc_gift_award',
          'name': getCategoryName(context, 'inc_gift_award'),
          'icon': IconUtils.getIcon('inc_gift_award'),
        },
        {
          'id': 'inc_gift_inheritance',
          'name': getCategoryName(context, 'inc_gift_inheritance'),
          'icon': IconUtils.getIcon('inc_gift_inheritance'),
        },
        {
          'id': 'inc_gift_alimony',
          'name': getCategoryName(context, 'inc_gift_alimony'),
          'icon': IconUtils.getIcon('inc_gift_alimony'),
        },
        {
          'id': 'inc_gift_allowance',
          'name': getCategoryName(context, 'inc_gift_allowance'),
          'icon': IconUtils.getIcon('inc_gift_allowance'),
        },
      ],
    },
    {
      'id': 'inc_other',
      'name': getCategoryName(context, 'inc_other'),
      'icon': IconUtils.getIcon('inc_other'),
      'color': IconUtils.getColor('inc_other'),
      'subModels': [
        {
          'id': 'inc_other_general',
          'name': getCategoryName(context, 'inc_other_general'),
          'icon': IconUtils.getIcon('inc_other_general'),
        },
        {
          'id': 'inc_other_refund',
          'name': getCategoryName(context, 'inc_other_refund'),
          'icon': IconUtils.getIcon('inc_other_refund'),
        },
        {
          'id': 'inc_other_lottery',
          'name': getCategoryName(context, 'inc_other_lottery'),
          'icon': IconUtils.getIcon('inc_other_lottery'),
        },
        {
          'id': 'inc_other_collection',
          'name': getCategoryName(context, 'inc_other_collection'),
          'icon': IconUtils.getIcon('inc_other_collection'),
        },
        {
          'id': 'inc_other_cashback',
          'name': getCategoryName(context, 'inc_other_cashback'),
          'icon': IconUtils.getIcon('inc_other_cashback'),
        },
        {
          'id': 'inc_other_tax_refund',
          'name': getCategoryName(context, 'inc_other_tax_refund'),
          'icon': IconUtils.getIcon('inc_other_tax_refund'),
        },
      ],
    },
  ];
}
