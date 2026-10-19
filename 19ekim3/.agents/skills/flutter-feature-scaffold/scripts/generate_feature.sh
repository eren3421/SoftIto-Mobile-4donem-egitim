#!/usr/bin/env bash
# ==============================================================================
# Susadım Flutter Feature Generator
# Standart: Modüler Clean UI, ValueNotifier State Yönetimi ve Çift Tema Desteği
# ==============================================================================

set -euo pipefail

FEATURE_INPUT="${1:-}"

if [ -z "$FEATURE_INPUT" ]; then
  echo "❌ Hata: Özellik (feature) adı belirtilmedi."
  echo "Kullanım: ./generate_feature.sh <feature_name_snake_case>"
  echo "Örnek:   ./generate_feature.sh calorie_tracker"
  exit 1
fi

# Snake_case formatını zorunlu tut
if [[ ! "$FEATURE_INPUT" =~ ^[a-z0-9_]+$ ]]; then
  echo "❌ Hata: Özellik adı yalnızca küçük harf, rakam ve alt çizgi (_) içerebilir."
  echo "Örnek: step_counter, calorie_tracker, sleep_monitor"
  exit 1
fi

FEATURE_NAME="$FEATURE_INPUT"

# PascalCase ve Human Title formatlarını hesapla
PASCAL_NAME=$(echo "$FEATURE_NAME" | awk -F_ '{for(i=1;i<=NF;i++) printf "%s%s", toupper(substr($i,1,1)), tolower(substr($i,2)); print ""}')
HUMAN_TITLE=$(echo "$FEATURE_NAME" | awk -F_ '{for(i=1;i<=NF;i++) printf "%s%s%s", toupper(substr($i,1,1)), tolower(substr($i,2)), (i==NF?"":" "); print ""}')

# Proje kök dizinini belirle (pubspec.yaml aranır)
CURRENT_DIR="$(pwd)"
PROJECT_ROOT="$CURRENT_DIR"

while [ "$PROJECT_ROOT" != "/" ] && [ ! -f "$PROJECT_ROOT/pubspec.yaml" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done

if [ ! -f "$PROJECT_ROOT/pubspec.yaml" ]; then
  echo "❌ Hata: Proje kök dizini (pubspec.yaml) bulunamadı!"
  exit 1
fi

FEATURE_DIR="$PROJECT_ROOT/lib/features/${FEATURE_NAME}"

if [ -d "$FEATURE_DIR" ]; then
  echo "⚠️ Uyarı: '${FEATURE_DIR}' dizini zaten mevcut. Var olan dosyalar korunacaktır."
fi

# Klasörleri oluştur
mkdir -p "${FEATURE_DIR}/controllers"
mkdir -p "${FEATURE_DIR}/models"
mkdir -p "${FEATURE_DIR}/views"
mkdir -p "${FEATURE_DIR}/widgets"

echo "📂 Klasörler hazırlandı: lib/features/${FEATURE_NAME}/"

# ------------------------------------------------------------------------------
# 1. Model Dosyası
# ------------------------------------------------------------------------------
MODEL_FILE="${FEATURE_DIR}/models/${FEATURE_NAME}_model.dart"
if [ ! -f "$MODEL_FILE" ]; then
  cat <<EOF > "$MODEL_FILE"
class ${PASCAL_NAME}Item {
  final String id;
  final String title;
  final int value;
  final DateTime timestamp;

  const ${PASCAL_NAME}Item({
    required this.id,
    required this.title,
    required this.value,
    required this.timestamp,
  });

  ${PASCAL_NAME}Item copyWith({
    String? id,
    String? title,
    int? value,
    DateTime? timestamp,
  }) {
    return ${PASCAL_NAME}Item(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'value': value,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ${PASCAL_NAME}Item.fromJson(Map<String, dynamic> json) => ${PASCAL_NAME}Item(
    id: json['id'] as String,
    title: json['title'] as String,
    value: json['value'] as int,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
EOF
  echo "  ✅ Model oluşturuldu: models/${FEATURE_NAME}_model.dart"
fi

# ------------------------------------------------------------------------------
# 2. Controller Dosyası
# ------------------------------------------------------------------------------
CONTROLLER_FILE="${FEATURE_DIR}/controllers/${FEATURE_NAME}_controller.dart"
if [ ! -f "$CONTROLLER_FILE" ]; then
  cat <<EOF > "$CONTROLLER_FILE"
import 'package:flutter/foundation.dart';
import '../models/${FEATURE_NAME}_model.dart';

class ${PASCAL_NAME}Controller {
  final ValueNotifier<int> totalCount = ValueNotifier<int>(0);
  final ValueNotifier<List<${PASCAL_NAME}Item>> items =
      ValueNotifier<List<${PASCAL_NAME}Item>>([]);

  final int targetGoal = 100;

  double get progressRatio => (totalCount.value / targetGoal).clamp(0.0, 1.0);
  bool get isCompleted => totalCount.value >= targetGoal;

  void addItem(String title, int value) {
    if (value <= 0) return;
    totalCount.value += value;
    final newItem = ${PASCAL_NAME}Item(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      value: value,
      timestamp: DateTime.now(),
    );
    items.value = [newItem, ...items.value];
  }

  void reset() {
    totalCount.value = 0;
    items.value = [];
  }

  void dispose() {
    totalCount.dispose();
    items.dispose();
  }
}
EOF
  echo "  ✅ Controller oluşturuldu: controllers/${FEATURE_NAME}_controller.dart"
fi

# ------------------------------------------------------------------------------
# 3. Widget Dosyası (Modüler Kart Bileşeni)
# ------------------------------------------------------------------------------
WIDGET_FILE="${FEATURE_DIR}/widgets/${FEATURE_NAME}_card.dart"
if [ ! -f "$WIDGET_FILE" ]; then
  cat <<EOF > "$WIDGET_FILE"
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ${PASCAL_NAME}Card extends StatelessWidget {
  final int totalCount;
  final int targetGoal;
  final VoidCallback onAdd;

  const ${PASCAL_NAME}Card({
    super.key,
    required this.totalCount,
    required this.targetGoal,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.neonCyanBright : AppColors.neonCyan;
    final progress = (totalCount / targetGoal).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, accentColor),
            const SizedBox(height: 12),
            _buildProgressBar(progress, accentColor, isDark),
            const SizedBox(height: 12),
            _buildFooter(context, onAdd),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color accentColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$HUMAN_TITLE',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '\$totalCount / \$targetGoal',
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress, Color accentColor, bool isDark) {
    final trackColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 10,
        backgroundColor: trackColor,
        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, VoidCallback onAdd) {
    return Align(
      alignment: Alignment.centerRight,
      child: FilledButton.tonalIcon(
        onPressed: onAdd,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Ekle'),
      ),
    );
  }
}
EOF
  echo "  ✅ Widget oluşturuldu: widgets/${FEATURE_NAME}_card.dart"
fi

# ------------------------------------------------------------------------------
# 4. View Dosyası
# ------------------------------------------------------------------------------
VIEW_FILE="${FEATURE_DIR}/views/${FEATURE_NAME}_view.dart"
if [ ! -f "$VIEW_FILE" ]; then
  cat <<EOF > "$VIEW_FILE"
import 'package:flutter/material.dart';
import '../controllers/${FEATURE_NAME}_controller.dart';
import '../widgets/${FEATURE_NAME}_card.dart';

class ${PASCAL_NAME}View extends StatefulWidget {
  final ${PASCAL_NAME}Controller? controller;

  const ${PASCAL_NAME}View({
    super.key,
    this.controller,
  });

  @override
  State<${PASCAL_NAME}View> createState() => _${PASCAL_NAME}ViewState();
}

class _${PASCAL_NAME}ViewState extends State<${PASCAL_NAME}View> {
  late final ${PASCAL_NAME}Controller _controller;
  late final bool _isInternalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      _controller = ${PASCAL_NAME}Controller();
      _isInternalController = true;
    }
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$HUMAN_TITLE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Sıfırla',
            onPressed: _controller.reset,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCardSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSection() {
    return ValueListenableBuilder<int>(
      valueListenable: _controller.totalCount,
      builder: (context, count, _) {
        return ${PASCAL_NAME}Card(
          totalCount: count,
          targetGoal: _controller.targetGoal,
          onAdd: () => _controller.addItem('Kayıt', 10),
        );
      },
    );
  }
}
EOF
  echo "  ✅ View oluşturuldu: views/${FEATURE_NAME}_view.dart"
fi

echo ""
echo "🎉 '${FEATURE_NAME}' özelliği başarıyla oluşturuldu!"
echo "📍 Yol: lib/features/${FEATURE_NAME}/"
echo "🔍 Doğrulama için: flutter analyze"
