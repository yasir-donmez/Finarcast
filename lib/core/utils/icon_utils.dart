import 'package:flutter/material.dart';
import '../theme/app_constants.dart';

/// Tüm kategoriler ve alt modeller için ikon ve renk eşleşmelerini tutan merkezi yardımcı sınıf.
/// Bu sayede hem işlem eklerken hem de dashboard/kasalar sayfalarında tutarlı ikonlar gösterilir.
class IconUtils {
  /// Kategori ismi veya ikon koduna göre IconData döndürür.
  static IconData getIcon(String? code) {
    if (code == null || code.isEmpty) return Icons.receipt_rounded;

    final lowerCode = code.toLowerCase();
    
    // Check if code is a numeric codepoint (custom category icon)
    final int? codepoint = int.tryParse(code);
    if (codepoint != null) {
      return IconData(codepoint, fontFamily: 'MaterialIcons');
    }
    
    // ==========================================
    // 1. STANDARDIZED CATEGORY IDs (PREFERRED)
    // ==========================================
    switch (lowerCode) {
      // --- GİDER (EXPENSE) ---
      case 'exp_grocery':
        return Icons.shopping_basket_rounded;
      case 'exp_grocery_food':
        return Icons.egg_rounded;
      case 'exp_grocery_cleaning':
        return Icons.cleaning_services_rounded;
      case 'exp_grocery_personal':
        return Icons.face_rounded;
      case 'exp_grocery_pet':
        return Icons.pets_rounded;
      
      case 'exp_dining':
        return Icons.restaurant_rounded;
      case 'exp_dining_restaurant':
        return Icons.restaurant_menu_rounded;
      case 'exp_dining_fastfood':
        return Icons.fastfood_rounded;
      case 'exp_dining_cafe':
        return Icons.coffee_rounded;
      case 'exp_dining_delivery':
        return Icons.delivery_dining_rounded;

      case 'exp_rent':
        return Icons.home_rounded;
      case 'exp_rent_home':
        return Icons.apartment_rounded;
      case 'exp_rent_office':
        return Icons.business_rounded;
      case 'exp_rent_storage':
        return Icons.warehouse_rounded;

      case 'exp_bill':
        return Icons.receipt_long_rounded;
      case 'exp_bill_electricity':
        return Icons.bolt_rounded;
      case 'exp_bill_water':
        return Icons.water_drop_rounded;
      case 'exp_bill_gas':
        return Icons.local_fire_department_rounded;
      case 'exp_bill_internet':
        return Icons.wifi_rounded;
      case 'exp_bill_phone':
        return Icons.phone_android_rounded;
      case 'exp_bill_dues':
        return Icons.home_work_rounded;

      case 'exp_home':
        return Icons.weekend_rounded;
      case 'exp_home_furniture':
        return Icons.chair_rounded;
      case 'exp_home_maintenance':
        return Icons.build_rounded;
      case 'exp_home_supplies':
        return Icons.shopping_bag_rounded;
      case 'exp_home_garden':
        return Icons.yard_rounded;

      case 'exp_fun':
        return Icons.movie_creation_rounded;
      case 'exp_fun_cinema':
        return Icons.local_movies_rounded;
      case 'exp_fun_concert':
        return Icons.music_note_rounded;
      case 'exp_fun_game':
        return Icons.sports_esports_rounded;
      case 'exp_fun_event':
        return Icons.event_rounded;
      case 'exp_fun_hobby':
        return Icons.palette_rounded;

      case 'exp_sub':
        return Icons.subscriptions_rounded;
      case 'exp_sub_stream':
        return Icons.smart_display_rounded;
      case 'exp_sub_music':
        return Icons.headphones_rounded;
      case 'exp_sub_software':
        return Icons.code_rounded;
      case 'exp_sub_gym':
        return Icons.fitness_center_rounded;

      case 'exp_health':
        return Icons.medical_services_rounded;
      case 'exp_health_doctor':
        return Icons.local_hospital_rounded;
      case 'exp_health_medicine':
        return Icons.medication_rounded;
      case 'exp_health_surgery':
        return Icons.vaccines_rounded;
      case 'exp_health_dentist':
        return Icons.sentiment_satisfied_alt_rounded;

      case 'exp_trans':
        return Icons.directions_transit_rounded;
      case 'exp_trans_taxi':
        return Icons.local_taxi_rounded;
      case 'exp_trans_bus':
        return Icons.directions_bus_rounded;
      case 'exp_trans_train':
        return Icons.train_rounded;
      case 'exp_trans_flight':
        return Icons.flight_rounded;
      case 'exp_trans_travel':
        return Icons.luggage_rounded;

      case 'exp_car':
        return Icons.directions_car_rounded;
      case 'exp_car_fuel':
        return Icons.local_gas_station_rounded;
      case 'exp_car_maintenance':
        return Icons.construction_rounded;
      case 'exp_car_insurance':
        return Icons.shield_rounded;
      case 'exp_car_parking':
        return Icons.local_parking_rounded;

      case 'exp_cloth':
        return Icons.checkroom_rounded;
      case 'exp_cloth_daily':
        return Icons.dry_cleaning_rounded;
      case 'exp_cloth_shoes':
        return Icons.ice_skating_rounded;
      case 'exp_cloth_acc':
        return Icons.watch_rounded;

      case 'exp_beauty':
        return Icons.spa_rounded;
      case 'exp_beauty_salon':
        return Icons.content_cut_rounded;
      case 'exp_beauty_cosmetics':
        return Icons.brush_rounded;
      case 'exp_beauty_spa':
        return Icons.spa_rounded;

      case 'exp_edu':
        return Icons.school_rounded;
      case 'exp_edu_course':
        return Icons.menu_book_rounded;
      case 'exp_edu_book':
        return Icons.auto_stories_rounded;
      case 'exp_edu_school':
        return Icons.account_balance_rounded;

      case 'exp_family':
        return Icons.child_care_rounded;
      case 'exp_family_baby':
        return Icons.child_friendly_rounded;
      case 'exp_family_toy':
        return Icons.smart_toy_rounded;
      case 'exp_family_allowance':
        return Icons.savings_rounded;

      case 'exp_debt':
        return Icons.credit_card_rounded;
      case 'exp_debt_credit_card':
        return Icons.credit_score_rounded;
      case 'exp_debt_loan':
        return Icons.account_balance_rounded;
      case 'exp_debt_personal':
        return Icons.handshake_rounded;

      case 'exp_tax':
        return Icons.gavel_rounded;
      case 'exp_tax_income':
        return Icons.receipt_rounded;
      case 'exp_tax_fine':
        return Icons.warning_amber_rounded;
      case 'exp_tax_fee':
        return Icons.assured_workload_rounded;

      case 'exp_invest':
        return Icons.trending_up_rounded;
      case 'exp_invest_gold':
        return Icons.workspace_premium_rounded;
      case 'exp_invest_stock':
        return Icons.show_chart_rounded;
      case 'exp_invest_crypto':
        return Icons.currency_bitcoin_rounded;
      case 'exp_invest_savings':
        return Icons.savings_rounded;

      case 'exp_other':
        return Icons.more_horiz_rounded;
      case 'exp_other_general':
        return Icons.category_rounded;
      case 'exp_other_donation':
        return Icons.volunteer_activism_rounded;
      case 'exp_other_insurance':
        return Icons.security_rounded;

      // --- GELİR (INCOME) ---
      case 'inc_salary':
        return Icons.account_balance_wallet_rounded;
      case 'inc_salary_main':
        return Icons.payments_rounded;
      case 'inc_salary_bonus':
        return Icons.card_giftcard_rounded;
      case 'inc_salary_dividend':
        return Icons.celebration_rounded;
      case 'inc_salary_pension':
        return Icons.elderly_rounded;

      case 'inc_extra':
        return Icons.monetization_on_rounded;
      case 'inc_extra_freelance':
        return Icons.laptop_mac_rounded;
      case 'inc_extra_parttime':
        return Icons.work_outline_rounded;
      case 'inc_extra_commission':
        return Icons.handshake_rounded;

      case 'inc_invest':
        return Icons.trending_up_rounded;
      case 'inc_invest_stock':
        return Icons.show_chart_rounded;
      case 'inc_invest_crypto':
        return Icons.currency_bitcoin_rounded;
      case 'inc_invest_interest':
        return Icons.savings_rounded;
      case 'inc_invest_gold':
        return Icons.currency_exchange_rounded;
      case 'inc_invest_property':
        return Icons.real_estate_agent_rounded;

      case 'inc_scholarship':
        return Icons.school_rounded;
      case 'inc_scholarship_award':
        return Icons.emoji_events_rounded;
      case 'inc_scholarship_loan':
        return Icons.account_balance_rounded;
      case 'inc_scholarship_gov':
        return Icons.assured_workload_rounded;

      case 'inc_sale':
        return Icons.store_rounded;
      case 'inc_sale_online':
        return Icons.shopping_cart_rounded;
      case 'inc_sale_physical':
        return Icons.storefront_rounded;

      case 'inc_rent':
        return Icons.house_rounded;
      case 'inc_rent_home':
        return Icons.apartment_rounded;
      case 'inc_rent_office':
        return Icons.business_rounded;
      case 'inc_rent_car':
        return Icons.car_rental_rounded;

      case 'inc_gift':
        return Icons.card_giftcard_rounded;
      case 'inc_gift_general':
        return Icons.cake_rounded;
      case 'inc_gift_award':
        return Icons.emoji_events_rounded;

      case 'inc_other':
        return Icons.more_horiz_rounded;
      case 'inc_other_general':
        return Icons.category_rounded;
      case 'inc_other_refund':
        return Icons.assignment_return_rounded;
      case 'inc_other_lottery':
        return Icons.casino_rounded;
    }

    // ==========================================
    // 2. DEFAULT FALLBACK
    // ==========================================
    return Icons.receipt_rounded;
  }

  /// Kategori ismi veya ikon koduna göre Renk döndürür.
  static Color getColor(String? code) {
    if (code == null || code.isEmpty) return AppColors.darkTextSecondary;

    final lowerCode = code.toLowerCase();

    // ==========================================
    // 1. STANDARDIZED CATEGORY IDs (PREFERRED)
    // ==========================================
    if (lowerCode.startsWith('exp_grocery')) return Colors.orange;
    if (lowerCode.startsWith('exp_dining')) return Colors.deepOrangeAccent;
    if (lowerCode.startsWith('exp_rent')) return Colors.blue;
    if (lowerCode.startsWith('exp_bill')) return Colors.lightBlue;
    if (lowerCode.startsWith('exp_home')) return Colors.deepPurple;
    if (lowerCode.startsWith('exp_trans')) return Colors.teal;
    if (lowerCode.startsWith('exp_car')) return Colors.cyan;
    if (lowerCode.startsWith('exp_fun')) return AppColors.secondary;
    if (lowerCode.startsWith('exp_sub')) return AppColors.error;
    if (lowerCode.startsWith('exp_health')) return Colors.greenAccent;
    if (lowerCode.startsWith('exp_cloth')) return Colors.pinkAccent;
    if (lowerCode.startsWith('exp_beauty')) return Colors.purpleAccent;
    if (lowerCode.startsWith('exp_edu')) return Colors.amber;
    if (lowerCode.startsWith('exp_family')) return Colors.indigo;
    if (lowerCode.startsWith('exp_debt')) return Colors.redAccent;
    if (lowerCode.startsWith('exp_tax')) return Colors.blueGrey;
    if (lowerCode.startsWith('exp_invest')) return Colors.amberAccent;
    
    if (lowerCode.startsWith('inc_salary')) return AppColors.primary;
    if (lowerCode.startsWith('inc_extra')) return Colors.green;
    if (lowerCode.startsWith('inc_invest')) return Colors.blueAccent;
    if (lowerCode.startsWith('inc_scholarship')) return Colors.amber;
    if (lowerCode.startsWith('inc_sale')) return Colors.orangeAccent;
    if (lowerCode.startsWith('inc_rent')) return AppColors.secondary;
    if (lowerCode.startsWith('inc_gift')) return Colors.pinkAccent;

    // ==========================================
    // 2. DEFAULT FALLBACK
    // ==========================================
    return AppColors.darkTextSecondary;
  }

  /// Bir listedeki en çok tekrar eden ikon kodunu döndürür.
  static String? getDominantIconCode(List<String?> iconCodes) {
    if (iconCodes.isEmpty) return null;
    final Map<String, int> counts = {};
    for (final code in iconCodes) {
      if (code == null || code.isEmpty) continue;
      counts[code] = (counts[code] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
