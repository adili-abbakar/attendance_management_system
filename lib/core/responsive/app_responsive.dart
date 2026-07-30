import 'package:flutter/material.dart';

/// Global responsive helper for the entire application.
///
/// Phone  : width < 600
/// Tablet : 600 - 1023
/// Desktop: >= 1024
///
/// Usage:
///
/// final r = AppResponsive.of(context);
///
/// padding: EdgeInsets.all(r.pagePadding)
/// SizedBox(height: r.spacing)
/// Text(style: TextStyle(fontSize: r.titleLarge))
/// Icon(size: r.iconLarge)
class AppResponsive {
  const AppResponsive._(this.width);

  final double width;

  static AppResponsive of(BuildContext context) {
    return AppResponsive._(MediaQuery.sizeOf(context).width);
  }

  bool get isPhone => width < 600;

  bool get isTablet => width >= 600 && width < 1024;

  bool get isDesktop => width >= 1024;

  //---------------------------------------------------------------------------
  // PAGE PADDING
  //---------------------------------------------------------------------------

  double get pagePadding {
    if (isPhone) return 12;
    if (isTablet) return 20;
    return 24;
  }

  double get dialogPadding {
    if (isPhone) return 14;
    if (isTablet) return 20;
    return 24;
  }

  double get dialogInset {
    if (isPhone) return 10;
    if (isTablet) return 24;
    return 40;
  }

  //---------------------------------------------------------------------------
  // SPACING
  //---------------------------------------------------------------------------

  double get spacingXS {
    if (isPhone) return 4;
    if (isTablet) return 6;
    return 8;
  }

  double get spacingS {
    if (isPhone) return 8;
    if (isTablet) return 10;
    return 12;
  }

  double get spacingM {
    if (isPhone) return 12;
    if (isTablet) return 16;
    return 20;
  }

  double get spacingL {
    if (isPhone) return 18;
    if (isTablet) return 24;
    return 32;
  }

  double get spacingXL {
    if (isPhone) return 24;
    if (isTablet) return 32;
    return 40;
  }

  //---------------------------------------------------------------------------
  // CARD
  //---------------------------------------------------------------------------

  double get cardPadding {
    if (isPhone) return 14;
    if (isTablet) return 18;
    return 20;
  }

  double get radius {
    if (isPhone) return 10;
    if (isTablet) return 12;
    return 14;
  }

  //---------------------------------------------------------------------------
  // ICONS
  //---------------------------------------------------------------------------

  double get iconSmall {
    if (isPhone) return 16;
    if (isTablet) return 18;
    return 20;
  }

  double get iconMedium {
    if (isPhone) return 20;
    if (isTablet) return 24;
    return 28;
  }

  double get iconLarge {
    if (isPhone) return 32;
    if (isTablet) return 40;
    return 48;
  }

  double get avatarRadius {
    if (isPhone) return 22;
    if (isTablet) return 28;
    return 34;
  }

  //---------------------------------------------------------------------------
  // TEXT
  //---------------------------------------------------------------------------

  double get display {
    if (isPhone) return 24;
    if (isTablet) return 28;
    return 34;
  }

  double get headline {
    if (isPhone) return 20;
    if (isTablet) return 24;
    return 28;
  }

  double get titleLarge {
    if (isPhone) return 18;
    if (isTablet) return 20;
    return 22;
  }

  double get titleMedium {
    if (isPhone) return 15;
    if (isTablet) return 17;
    return 18;
  }

  double get body {
    if (isPhone) return 13;
    if (isTablet) return 14;
    return 15;
  }

  double get bodySmall {
    if (isPhone) return 11;
    if (isTablet) return 12;
    return 13;
  }

  double get caption {
    if (isPhone) return 10;
    if (isTablet) return 11;
    return 12;
  }

  //---------------------------------------------------------------------------
  // BUTTONS
  //---------------------------------------------------------------------------

  double get buttonHeight {
    if (isPhone) return 42;
    if (isTablet) return 46;
    return 50;
  }

  double get buttonIcon {
    if (isPhone) return 18;
    if (isTablet) return 20;
    return 22;
  }

  //---------------------------------------------------------------------------
  // TABLES
  //---------------------------------------------------------------------------

  double get tableColumnSpacing {
    if (isPhone) return 16;
    if (isTablet) return 22;
    return 28;
  }

  double get tableHorizontalMargin {
    if (isPhone) return 10;
    if (isTablet) return 16;
    return 20;
  }

  double get tableHeadingHeight {
    if (isPhone) return 46;
    if (isTablet) return 52;
    return 56;
  }

  double get tableRowHeight {
    if (isPhone) return 46;
    if (isTablet) return 52;
    return 56;
  }

  //---------------------------------------------------------------------------
  // DIALOG
  //---------------------------------------------------------------------------

  double get dialogWidth {
    if (isPhone) return double.infinity;
    if (isTablet) return 550;
    return 650;
  }

  //---------------------------------------------------------------------------
  // GRID
  //---------------------------------------------------------------------------

  int gridColumns({int phone = 1, int tablet = 2, int desktop = 4}) {
    if (isPhone) return phone;
    if (isTablet) return tablet;
    return desktop;
  }
}
