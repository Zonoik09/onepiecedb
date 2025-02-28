import 'package:provider/provider.dart';
import 'group_provider.dart';

final List<ChangeNotifierProvider> providers = [
  ChangeNotifierProvider(create: (_) => GroupProvider()),
];
