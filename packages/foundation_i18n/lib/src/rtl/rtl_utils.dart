import 'package:flutter/widgets.dart';

class RtlUtils {
  static bool isRtl(BuildContext context) => Directionality.of(context) == TextDirection.rtl;

  static EdgeInsetsDirectional flipPaddingIfRtl(BuildContext context, EdgeInsetsDirectional padding) {
    if (!isRtl(context)) return padding;
    // In RTL, directional padding is already handled; this helper exists for readability/extensibility.
    return padding;
  }
}