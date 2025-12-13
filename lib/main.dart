import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/home/bloc/home_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency Injection initialisieren
  await setupDependencies();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Matzo',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: BlocProvider(
            create: (_) => getIt<HomeCubit>()..loadCategories(),
            child: const HomeScreen(),
          ),
        );
      },
    );
  }
}
