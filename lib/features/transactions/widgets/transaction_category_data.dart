import 'package:flutter/material.dart';
import '../../../core/theme/app_constants.dart';
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

  static List<Map<String, dynamic>> getExpenseCategories(BuildContext context, AppLocalizations l10n) => [
    {
      'id': 'exp_grocery',
      'name': l10n.grocery,
      'icon': Icons.shopping_basket_rounded,
      'color': Colors.orange,
      'subModels': [
        {
          'id': 'exp_grocery_food',
          'name': l10n.food,
          'icon': Icons.egg_rounded,
        },
        {
          'id': 'exp_grocery_cleaning',
          'name': l10n.cleaning,
          'icon': Icons.cleaning_services_rounded,
        },
        {
          'id': 'exp_grocery_personal',
          'name': l10n.personalCare,
          'icon': Icons.face_rounded,
        },
      ],
    },
    {
      'id': 'exp_dining',
      'name': l10n.dining,
      'icon': Icons.restaurant_rounded,
      'color': Colors.deepOrangeAccent,
      'subModels': [
        {
          'id': 'exp_dining_restaurant',
          'name': l10n.restaurant,
          'icon': Icons.restaurant_menu_rounded,
        },
        {
          'id': 'exp_dining_fastfood',
          'name': l10n.fastFood,
          'icon': Icons.fastfood_rounded,
        },
        {
          'id': 'exp_dining_cafe',
          'name': l10n.cafe,
          'icon': Icons.coffee_rounded,
        },
        {
          'id': 'exp_dining_delivery',
          'name': l10n.delivery,
          'icon': Icons.delivery_dining_rounded,
        },
      ],
    },
    {
      'id': 'exp_rent',
      'name': l10n.rent,
      'icon': Icons.home_rounded,
      'color': Colors.blue,
      'subModels': [
        {
          'id': 'exp_rent_home',
          'name': l10n.homeRent,
          'icon': Icons.apartment_rounded,
        },
        {
          'id': 'exp_rent_office',
          'name': l10n.workspace,
          'icon': Icons.business_rounded,
        },
        {
          'id': 'exp_rent_storage',
          'name': l10n.storage,
          'icon': Icons.warehouse_rounded,
        },
      ],
    },
    {
      'id': 'exp_bill',
      'name': l10n.bill,
      'icon': Icons.receipt_long_rounded,
      'color': Colors.lightBlue,
      'subModels': [
        {
          'id': 'exp_bill_electricity',
          'name': l10n.electricity,
          'icon': Icons.bolt_rounded,
        },
        {
          'id': 'exp_bill_water',
          'name': l10n.water,
          'icon': Icons.water_drop_rounded,
        },
        {
          'id': 'exp_bill_gas',
          'name': l10n.gas,
          'icon': Icons.local_fire_department_rounded,
        },
        {
          'id': 'exp_bill_internet',
          'name': l10n.internet,
          'icon': Icons.wifi_rounded,
        },
        {
          'id': 'exp_bill_phone',
          'name': l10n.phone,
          'icon': Icons.phone_android_rounded,
        },
      ],
    },
    {
      'id': 'exp_fun',
      'name': l10n.entertainment,
      'icon': Icons.movie_creation_rounded,
      'color': AppColors.secondary,
      'subModels': [
        {
          'id': 'exp_fun_cinema',
          'name': l10n.cinema,
          'icon': Icons.local_movies_rounded,
        },
        {
          'id': 'exp_fun_concert',
          'name': l10n.concert,
          'icon': Icons.music_note_rounded,
        },
        {
          'id': 'exp_fun_game',
          'name': l10n.game,
          'icon': Icons.sports_esports_rounded,
        },
        {
          'id': 'exp_fun_event',
          'name': l10n.event,
          'icon': Icons.event_rounded,
        },
      ],
    },
    {
      'id': 'exp_sub',
      'name': l10n.subscription,
      'icon': Icons.subscriptions_rounded,
      'color': AppColors.getError(context),
      'subModels': [
        {
          'id': 'exp_sub_stream',
          'name': l10n.streaming,
          'icon': Icons.smart_display_rounded,
        },
        {
          'id': 'exp_sub_music',
          'name': l10n.musicSubscription,
          'icon': Icons.headphones_rounded,
        },
        {
          'id': 'exp_sub_software',
          'name': l10n.software,
          'icon': Icons.code_rounded,
        },
        {
          'id': 'exp_sub_gym',
          'name': l10n.gym,
          'icon': Icons.fitness_center_rounded,
        },
      ],
    },
    {
      'id': 'exp_health',
      'name': l10n.health,
      'icon': Icons.medical_services_rounded,
      'color': AppColors.getIncome(context),
      'subModels': [
        {
          'id': 'exp_health_doctor',
          'name': l10n.doctor,
          'icon': Icons.local_hospital_rounded,
        },
        {
          'id': 'exp_health_medicine',
          'name': l10n.medicine,
          'icon': Icons.medication_rounded,
        },
        {
          'id': 'exp_health_surgery',
          'name': l10n.surgery,
          'icon': Icons.vaccines_rounded,
        },
        {
          'id': 'exp_health_dentist',
          'name': l10n.dentist,
          'icon': Icons.sentiment_satisfied_alt_rounded,
        },
      ],
    },
    {
      'id': 'exp_trans',
      'name': l10n.transportation,
      'icon': Icons.directions_car_rounded,
      'color': Colors.teal,
      'subModels': [
        {
          'id': 'exp_trans_taxi',
          'name': l10n.taxi,
          'icon': Icons.local_taxi_rounded,
        },
        {
          'id': 'exp_trans_bus',
          'name': l10n.bus,
          'icon': Icons.directions_bus_rounded,
        },
        {
          'id': 'exp_trans_train',
          'name': l10n.train,
          'icon': Icons.train_rounded,
        },
        {
          'id': 'exp_trans_flight',
          'name': l10n.flight,
          'icon': Icons.flight_rounded,
        },
        {
          'id': 'exp_trans_fuel',
          'name': l10n.fuel,
          'icon': Icons.local_gas_station_rounded,
        },
      ],
    },
    {
      'id': 'exp_cloth',
      'name': l10n.clothing,
      'icon': Icons.checkroom_rounded,
      'color': Colors.pinkAccent,
      'subModels': [
        {
          'id': 'exp_cloth_daily',
          'name': l10n.dailyWear,
          'icon': Icons.dry_cleaning_rounded,
        },
        {
          'id': 'exp_cloth_shoes',
          'name': l10n.shoes,
          'icon': Icons.ice_skating_rounded,
        },
        {
          'id': 'exp_cloth_acc',
          'name': l10n.accessory,
          'icon': Icons.watch_rounded,
        },
      ],
    },
    {
      'id': 'exp_edu',
      'name': l10n.education,
      'icon': Icons.school_rounded,
      'color': Colors.amber,
      'subModels': [
        {
          'id': 'exp_edu_course',
          'name': l10n.course,
          'icon': Icons.menu_book_rounded,
        },
        {
          'id': 'exp_edu_book',
          'name': l10n.book,
          'icon': Icons.auto_stories_rounded,
        },
        {
          'id': 'exp_edu_school',
          'name': l10n.school,
          'icon': Icons.account_balance_rounded,
        },
      ],
    },
    {
      'id': 'exp_debt',
      'name': l10n.debtPayment,
      'icon': Icons.credit_card_rounded,
      'color': AppColors.getExpense(context),
      'subModels': [
        {
          'id': 'exp_debt_credit_card',
          'name': l10n.creditCard,
          'icon': Icons.credit_score_rounded,
        },
        {
          'id': 'exp_debt_loan',
          'name': l10n.loan,
          'icon': Icons.account_balance_rounded,
        },
        {
          'id': 'exp_debt_personal',
          'name': l10n.personalDebt,
          'icon': Icons.handshake_rounded,
        },
      ],
    },
    {
      'id': 'exp_other',
      'name': l10n.other,
      'icon': Icons.more_horiz_rounded,
      'color': Colors.grey,
      'subModels': [
        {
          'id': 'exp_other_general',
          'name': l10n.other,
          'icon': Icons.category_rounded,
        },
        {
          'id': 'exp_other_donation',
          'name': 'Bağış/Yardım',
          'icon': Icons.volunteer_activism_rounded,
        },
        {
          'id': 'exp_other_insurance',
          'name': 'Sigorta',
          'icon': Icons.security_rounded,
        },
        {
          'id': 'exp_other_pocket_money',
          'name': 'Harçlık',
          'icon': Icons.savings_rounded,
        },
      ],
    },
  ];

  static List<Map<String, dynamic>> getIncomeCategories(BuildContext context, AppLocalizations l10n) => [
    {
      'id': 'inc_salary',
      'name': l10n.salary,
      'icon': Icons.account_balance_wallet_rounded,
      'color': AppColors.getPrimary(context),
      'subModels': [
        {
          'id': 'inc_salary_main',
          'name': l10n.mainSalary,
          'icon': Icons.payments_rounded,
        },
        {
          'id': 'inc_salary_bonus',
          'name': l10n.bonus,
          'icon': Icons.card_giftcard_rounded,
        },
        {
          'id': 'inc_salary_dividend',
          'name': l10n.dividend,
          'icon': Icons.celebration_rounded,
        },
      ],
    },
    {
      'id': 'inc_extra',
      'name': l10n.extraIncome,
      'icon': Icons.monetization_on_rounded,
      'color': AppColors.getIncome(context),
      'subModels': [
        {
          'id': 'inc_extra_freelance',
          'name': l10n.freelance,
          'icon': Icons.laptop_mac_rounded,
        },
        {
          'id': 'inc_extra_parttime',
          'name': l10n.partTime,
          'icon': Icons.work_outline_rounded,
        },
        {
          'id': 'inc_extra_commission',
          'name': l10n.commission,
          'icon': Icons.handshake_rounded,
        },
      ],
    },
    {
      'id': 'inc_invest',
      'name': l10n.investmentReturn,
      'icon': Icons.trending_up_rounded,
      'color': Colors.blueAccent,
      'subModels': [
        {
          'id': 'inc_invest_stock',
          'name': l10n.stock,
          'icon': Icons.show_chart_rounded,
        },
        {
          'id': 'inc_invest_crypto',
          'name': l10n.crypto,
          'icon': Icons.currency_bitcoin_rounded,
        },
        {
          'id': 'inc_invest_interest',
          'name': l10n.interest,
          'icon': Icons.savings_rounded,
        },
      ],
    },
    {
      'id': 'inc_scholarship',
      'name': l10n.scholarshipLoan,
      'icon': Icons.school_rounded,
      'color': Colors.amber,
      'subModels': [
        {
          'id': 'inc_scholarship_award',
          'name': l10n.scholarship,
          'icon': Icons.emoji_events_rounded,
        },
        {
          'id': 'inc_scholarship_loan',
          'name': l10n.credit,
          'icon': Icons.account_balance_rounded,
        },
      ],
    },
    {
      'id': 'inc_sale',
      'name': l10n.sale,
      'icon': Icons.store_rounded,
      'color': Colors.orangeAccent,
      'subModels': [
        {
          'id': 'inc_sale_online',
          'name': l10n.onlineSale,
          'icon': Icons.shopping_cart_rounded,
        },
        {
          'id': 'inc_sale_physical',
          'name': l10n.physicalSale,
          'icon': Icons.storefront_rounded,
        },
      ],
    },
    {
      'id': 'inc_rent',
      'name': l10n.rentalIncome,
      'icon': Icons.house_rounded,
      'color': AppColors.secondary,
      'subModels': [
        {
          'id': 'inc_rent_home',
          'name': l10n.home,
          'icon': Icons.apartment_rounded,
        },
        {
          'id': 'inc_rent_office',
          'name': l10n.officeIncome,
          'icon': Icons.business_rounded,
        },
      ],
    },
    {
      'id': 'inc_gift',
      'name': l10n.gift,
      'icon': Icons.card_giftcard_rounded,
      'color': Colors.pinkAccent,
      'subModels': [
        {
          'id': 'inc_gift_general',
          'name': 'Hediye',
          'icon': Icons.cake_rounded,
        },
        {
          'id': 'inc_gift_award',
          'name': 'Ödül/İkramiye',
          'icon': Icons.emoji_events_rounded,
        },
      ],
    },
    {
      'id': 'inc_other',
      'name': l10n.other,
      'icon': Icons.more_horiz_rounded,
      'color': Colors.grey,
      'subModels': [
        {
          'id': 'inc_other_general',
          'name': l10n.other,
          'icon': Icons.category_rounded,
        },
        {
          'id': 'inc_other_refund',
          'name': 'İade/Geri Ödeme',
          'icon': Icons.assignment_return_rounded,
        },
        {
          'id': 'inc_other_lottery',
          'name': 'Şans Oyunları',
          'icon': Icons.casino_rounded,
        },
      ],
    },
  ];
}
