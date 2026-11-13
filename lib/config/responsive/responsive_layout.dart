import 'package:flutter/widgets.dart';
import 'package:itsqmet_mobile_pos/config/responsive/responsive_extensions.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.mobile, this.tablet});

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;

  @override
  Widget build(BuildContext context) {
    final tabletBuilder = tablet;
    if (context.isTablet && tabletBuilder != null) {
      return tabletBuilder(context);
    }
    return mobile(context);
  }
}
