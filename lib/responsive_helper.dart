import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  final double width;
  final double height;

  Responsive(this.context)
      : width = MediaQuery.of(context).size.width,
        height = MediaQuery.of(context).size.height;

  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 900;
  bool get isDesktop => width >= 900;

  /// Ukuran font responsif
  double fontSize({required double mobile, double? tablet, double? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Ukuran umum responsif (height/width, dll)
  double size({required double mobile, double? tablet, double? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Padding symmetric (default horizontal & vertical sama)
  EdgeInsets padding({
    required double mobile,
    double? tablet,
    double? desktop,
    bool horizontal = true,
    bool vertical = true,
  }) {
    double value = size(mobile: mobile, tablet: tablet, desktop: desktop);
    return EdgeInsets.symmetric(
      horizontal: horizontal ? value : 0,
      vertical: vertical ? value : 0,
    );
  }

  /// Padding asymmetric horizontal & vertical
  EdgeInsets paddingSymmetric({
    required double horizontalMobile,
    double? horizontalTablet,
    double? horizontalDesktop,
    required double verticalMobile,
    double? verticalTablet,
    double? verticalDesktop,
  }) {
    double h = size(mobile: horizontalMobile, tablet: horizontalTablet, desktop: horizontalDesktop);
    double v = size(mobile: verticalMobile, tablet: verticalTablet, desktop: verticalDesktop);
    return EdgeInsets.symmetric(horizontal: h, vertical: v);
  }

  /// Padding untuk top, bottom, left, right masing-masing
  EdgeInsets paddingOnly({
    required double leftMobile,
    double? leftTablet,
    double? leftDesktop,
    required double topMobile,
    double? topTablet,
    double? topDesktop,
    required double rightMobile,
    double? rightTablet,
    double? rightDesktop,
    required double bottomMobile,
    double? bottomTablet,
    double? bottomDesktop,
  }) {
    return EdgeInsets.only(
      left: size(mobile: leftMobile, tablet: leftTablet, desktop: leftDesktop),
      top: size(mobile: topMobile, tablet: topTablet, desktop: topDesktop),
      right: size(mobile: rightMobile, tablet: rightTablet, desktop: rightDesktop),
      bottom: size(mobile: bottomMobile, tablet: bottomTablet, desktop: bottomDesktop),
    );
  }

  /// Generic value responsif
  T value<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}