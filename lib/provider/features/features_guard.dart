import 'package:flutter/material.dart';
import 'package:hr/provider/function/user_provider.dart';
import 'package:provider/provider.dart';

class FeatureGuard extends StatelessWidget {
  final String featureId;
  final Widget child;

  const FeatureGuard({
    super.key,
    required this.featureId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    // ini ngecek apakah fitur ini ada di role user
    if (userProvider.hasFeature(featureId)) {
      return child;
    }
    return const SizedBox.shrink();
  }
}
