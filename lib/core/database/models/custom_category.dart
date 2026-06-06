import 'package:isar/isar.dart';

part 'custom_category.g.dart';

@collection
class CustomCategory {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uniqueId; // örn: exp_grocery_custom_123

  late String parentId; // örn: exp_grocery
  late String name;
  late int iconCode;
  
  @Index()
  int syncStatus = 0; // 0: synced, 1: pending, 2: deleted

  DateTime updatedAt = DateTime.now();
}
