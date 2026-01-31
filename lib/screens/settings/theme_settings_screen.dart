import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_appbar.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tema Ayarları',
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Koyu Mod'),
            subtitle: const Text('Uygulama temasını değiştir'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.setDarkMode(value);
            },
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/theme_provider.dart';
// import '../../widgets/custom_appbar.dart';

// class ThemeSettingsScreen extends StatelessWidget {
//   const ThemeSettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tema Ayarları'),
//       ),
//       body: ListView(
//         children: [
//           SwitchListTile(
//             title: const Text('Koyu Mod'),
//             subtitle: const Text('Uygulama temasını değiştir'),
//             value: themeProvider.isDarkMode,
//             onChanged: (value) {
//               themeProvider.toggleTheme();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
