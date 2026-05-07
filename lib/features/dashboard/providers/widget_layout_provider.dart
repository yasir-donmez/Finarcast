import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/dashboard_widget.dart';

class WidgetConfig {
  final String id;
  final String type;
  final DashboardWidgetSize size;
  final int page;

  WidgetConfig({
    required this.id,
    required this.type,
    required this.size,
    required this.page,
  });

  WidgetConfig copyWith({String? id, String? type, DashboardWidgetSize? size, int? page}) {
    return WidgetConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      size: size ?? this.size,
      page: page ?? this.page,
    );
  }
}

class WidgetLayoutNotifier extends StateNotifier<List<List<WidgetConfig>>> {
  WidgetLayoutNotifier() : super([]) {
    // Başlangıç verilerini normalize ederek yükle
    _normalize(_initialWidgets);
  }

  static final List<WidgetConfig> _initialWidgets = [
    WidgetConfig(id: '1', type: 'timeline', size: DashboardWidgetSize.large, page: 0),
    WidgetConfig(id: '2', type: 'radar', size: DashboardWidgetSize.large, page: 1),
    WidgetConfig(id: '3', type: 'spending', size: DashboardWidgetSize.large, page: 2),
  ];

  int _getWeight(DashboardWidgetSize size) {
    switch (size) {
      case DashboardWidgetSize.small: return 1;
      case DashboardWidgetSize.wide: return 2;
      case DashboardWidgetSize.large: return 4;
    }
  }

  void _normalize(List<WidgetConfig> widgets) {
    // 1. Sıralama (Sayfa numarasına göre, aynı sayfadakiler ID'ye göre)
    // Bu sıralama "itilme" sırasını belirler.
    widgets.sort((a, b) {
      if (a.page != b.page) return a.page.compareTo(b.page);
      return a.id.compareTo(b.id);
    });

    List<List<WidgetConfig>> pages = [[], [], [], []];
    List<WidgetConfig> overflow = [];

    // CASCADE PUSH: Zincirleme iteleme mantığı
    void performCascadePush(List<WidgetConfig> allWidgets) {
      List<List<WidgetConfig>> newPages = [[], [], [], []];
      int currentPage = 0;
      int currentWeight = 0;
      List<WidgetConfig> currentOverflow = [];

      for (var w in allWidgets) {
        final wWeight = _getWeight(w.size);
        
        // Eğer widget'ın istediği sayfa henüz gelmediyse ve biz daha gerideysek,
        // o sayfaya kadar atlayabiliriz (Eğer arada başka widget yoksa)
        if (w.page > currentPage && currentWeight == 0) {
          currentPage = w.page.clamp(0, 3);
        }

        // Sayfa doluysa bir sonrakine it
        while (currentPage < 4 && currentWeight + wWeight > 4) {
          currentPage++;
          currentWeight = 0;
        }

        if (currentPage < 4) {
          newPages[currentPage].add(w.copyWith(page: currentPage));
          currentWeight += wWeight;
        } else {
          currentOverflow.add(w);
        }
      }
      pages = newPages;
      overflow = currentOverflow;
    }

    // 1. TUR: İteleme ile yerleştir
    performCascadePush(widgets);

    // 2. ADIM: Geriye dönük iteleme (Boşlukları doldurarak kurtar)
    if (overflow.isNotEmpty) {
      final allToResqueeze = [...pages.expand((p) => p), ...overflow];
      // "En baştan başla ve hiç boşluk bırakmadan doldur" (Squeeze)
      List<List<WidgetConfig>> squeezedPages = [[], [], [], []];
      int cP = 0;
      int cW = 0;
      List<WidgetConfig> finalOverflow = [];

      for (var w in allToResqueeze) {
        final wWeight = _getWeight(w.size);
        while (cP < 4 && cW + wWeight > 4) {
          cP++;
          cW = 0;
        }
        if (cP < 4) {
          squeezedPages[cP].add(w.copyWith(page: cP));
          cW += wWeight;
        } else {
          finalOverflow.add(w);
        }
      }
      pages = squeezedPages;
      overflow = finalOverflow;
    }

    // 3. ADIM: Otomatik Küçültme (Son çare)
    if (overflow.isNotEmpty) {
      List<WidgetConfig> allToFix = [...pages.expand((p) => p), ...overflow];
      bool canShrinkMore = true;
      while (overflow.isNotEmpty && canShrinkMore) {
        canShrinkMore = false;
        // Küçültme önceliği: En büyükleri küçült
        for (int i = 0; i < allToFix.length; i++) {
          final w = allToFix[i];
          if (w.size == DashboardWidgetSize.large) {
            allToFix[i] = w.copyWith(size: DashboardWidgetSize.wide);
            canShrinkMore = true;
            break;
          } else if (w.size == DashboardWidgetSize.wide) {
            allToFix[i] = w.copyWith(size: DashboardWidgetSize.small);
            canShrinkMore = true;
            break;
          }
        }
        
        // Küçülttükten sonra tekrar iteleme ve sıkıştırma dene
        performCascadePush(allToFix);
        if (overflow.isNotEmpty) {
          // Hala sığmıyorsa tekrar sıkıştır
          final allTemp = [...pages.expand((p) => p), ...overflow];
          List<List<WidgetConfig>> tempPages = [[], [], [], []];
          int tP = 0; int tW = 0; List<WidgetConfig> tO = [];
          for (var tw in allTemp) {
            final twW = _getWeight(tw.size);
            while (tP < 4 && tW + twW > 4) { tP++; tW = 0; }
            if (tP < 4) { tempPages[tP].add(tw.copyWith(page: tP)); tW += twW; }
            else { tO.add(tw); }
          }
          pages = tempPages; overflow = tO;
        }
        allToFix = [...pages.expand((p) => p), ...overflow];
      }
    }

    state = pages;
  }

  void removeWidget(String id) {
    final allWidgets = state.expand((p) => p).toList();
    allWidgets.removeWhere((w) => w.id == id);
    _normalize(allWidgets);
  }

  void addWidget(String type, DashboardWidgetSize size) {
    final id = 'widget_${DateTime.now().millisecondsSinceEpoch}';
    // Son sayfada yer varsa oraya, yoksa ilk boşluğa eklemeye çalışır
    final newWidget = WidgetConfig(
      id: id,
      type: type,
      size: size,
      page: 3, // Önce son sayfayı dene, normalize en uygun yere iter
    );

    final allWidgets = [...state.expand((p) => p), newWidget];
    _normalize(allWidgets);
  }

  void changeWidgetPage(String widgetId, int newPageIndex) {
    final int targetPage = newPageIndex.clamp(0, 3);
    final allWidgets = state.expand((p) => p).toList();
    
    _normalize(allWidgets.map((w) {
      if (w.id == widgetId) return w.copyWith(page: targetPage);
      return w;
    }).toList());
  }

  void setWidgetSizeById(String id, DashboardWidgetSize newSize) {
    final allWidgets = state.expand((p) => p).toList();
    _normalize(allWidgets.map((w) {
      if (w.id == id) return w.copyWith(size: newSize);
      return w;
    }).toList());
  }
}

final widgetLayoutProvider = StateNotifierProvider<WidgetLayoutNotifier, List<List<WidgetConfig>>>((ref) {
  return WidgetLayoutNotifier();
});
