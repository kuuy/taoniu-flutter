import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main_tab/main_tab_controller.dart';
import '../../../../routes/app_routes.dart';

class TvTableTheme {
  static const Color tvCanvasBg = Color(0xFF0E111A);
  static const Color tvHeaderBg = Color(0xFF161B26);
  static const Color tvCardBg = Color(0xFF1B202E);
  static const Color tvRowAltBg = Color(0xFF121622);
  static const Color tvBorderColor = Color(0xFF242A38);
  static const Color tvTextHeader = Color(0xFF8E95A5);
  static const Color tvTextPrimary = Color(0xFFF0F3FA);
  static const Color tvTextSecondary = Color(0xFFA0A7B5);
  static const Color tvGreen = Color(0xFF00E676);
  static const Color tvRed = Color(0xFFFF5252);
  static const Color tvBlue = Color(0xFF3D78FF);
  static const Color tvPurple = Color(0xFFB388FF);
  static const Color tvAmber = Color(0xFFFFB300);
  static const Color tvCyan = Color(0xFF00E5FF);

  static const LinearGradient tvCardGradient = LinearGradient(
    colors: [Color(0xFF1C2230), Color(0xFF141824)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tvBannerGradient = LinearGradient(
    colors: [Color(0xFF1E2638), Color(0xFF121622)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const TextStyle headerTextStyle = TextStyle(
    color: tvTextHeader,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle cellTextStyle = TextStyle(
    color: tvTextPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle numberTextStyle = TextStyle(
    color: tvTextPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static PreferredSizeWidget buildAppBar({
    required String title,
    Widget? leading,
    bool showBackButton = true,
    List<Widget>? actions,
    Widget? titleWidget,
  }) {
    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: tvTextPrimary, size: 18),
        tooltip: 'Back',
        onPressed: () {
          final canPop = Get.context != null && Navigator.canPop(Get.context!);
          if (canPop) {
            Get.back();
          } else if (Get.isRegistered<MainTabController>()) {
            Get.find<MainTabController>().changePage(0);
          } else {
            Get.offAllNamed(AppRoutes.mainTab);
          }
        },
      );
    }

    return AppBar(
      backgroundColor: tvHeaderBg,
      elevation: 0,
      iconTheme: const IconThemeData(color: tvTextPrimary),
      titleSpacing: leadingWidget != null ? 0.0 : 16.0,
      leading: leadingWidget,
      title: titleWidget ??
          Text(
            title,
            style: const TextStyle(
              color: tvTextPrimary,
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
          ),
      actions: actions,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Divider(height: 1.0, thickness: 1.0, color: tvBorderColor),
      ),
    );
  }

  static Widget buildStickyTable({
    required DataColumn firstColumn,
    required List<DataColumn> remainingColumns,
    required int itemCount,
    required DataCell Function(int index) firstCellBuilder,
    required List<DataCell> Function(int index) remainingCellsBuilder,
    void Function(int index)? onSelectRow,
    double headingRowHeight = 38.0,
    double dataRowMinHeight = 36.0,
    double dataRowMaxHeight = 36.0,
    double minColumnSpacing = 20.0,
    double horizontalMargin = 16.0,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed Left Sticky Column
          Container(
            decoration: const BoxDecoration(
              color: tvCanvasBg,
              border: Border(
                right: BorderSide(
                  color: tvBorderColor,
                  width: 1.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: DataTable(
              showCheckboxColumn: false,
              headingRowHeight: headingRowHeight,
              dataRowMinHeight: dataRowMinHeight,
              dataRowMaxHeight: dataRowMaxHeight,
              columnSpacing: minColumnSpacing,
              horizontalMargin: horizontalMargin,
              headingRowColor: WidgetStateProperty.all(tvHeaderBg),
              border: const TableBorder(
                horizontalInside: BorderSide(
                  color: tvBorderColor,
                  width: 0.5,
                ),
              ),
              columns: [firstColumn],
              rows: List.generate(itemCount, (index) {
                return DataRow(
                  color: WidgetStateProperty.all(
                    index % 2 == 0 ? tvCanvasBg : tvRowAltBg,
                  ),
                  onSelectChanged: onSelectRow != null ? (_) => onSelectRow(index) : null,
                  cells: [firstCellBuilder(index)],
                );
              }),
            ),
          ),
          // Scrollable Right Columns
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final numFields = remainingColumns.length;
                const avgColWidth = 70.0;
                final totalColWidth = numFields * avgColWidth;
                final extraSpace = constraints.maxWidth - totalColWidth - (horizontalMargin * 2);
                final dynamicSpacing = (numFields > 1 && extraSpace > 0)
                    ? (minColumnSpacing + (extraSpace / (numFields - 1))).clamp(minColumnSpacing, 100.0)
                    : minColumnSpacing;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: DataTable(
                      showCheckboxColumn: false,
                      headingRowHeight: headingRowHeight,
                      dataRowMinHeight: dataRowMinHeight,
                      dataRowMaxHeight: dataRowMaxHeight,
                      columnSpacing: dynamicSpacing,
                      horizontalMargin: horizontalMargin,
                      headingRowColor: WidgetStateProperty.all(tvHeaderBg),
                      border: const TableBorder(
                        horizontalInside: BorderSide(
                          color: tvBorderColor,
                          width: 0.5,
                        ),
                      ),
                      columns: remainingColumns,
                      rows: List.generate(itemCount, (index) {
                        return DataRow(
                          color: WidgetStateProperty.all(
                            index % 2 == 0 ? tvCanvasBg : tvRowAltBg,
                          ),
                          onSelectChanged: onSelectRow != null ? (_) => onSelectRow(index) : null,
                          cells: remainingCellsBuilder(index),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
