import 'package:flutter/material.dart';
import 'package:jetdriver/utils/logger.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';

class JetdriverApp extends StatelessWidget {
  const JetdriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Logger provider
        ChangeNotifierProvider(
          create: (_) => Logger.instance,
        ),
      ],
      child: MaterialApp(
        title: 'Jetdriver',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF4CAF50),
          scaffoldBackgroundColor: const Color(0xFF16213E),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            brightness: Brightness.dark,
          ),
        ),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}