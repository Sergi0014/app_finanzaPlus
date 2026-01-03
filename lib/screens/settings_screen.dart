import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/backup_service.dart';
import '../providers/theme_provider.dart';

/// Pantalla de configuración
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currency = 'USD';
  int _weekStart = DateTime.monday;
  bool _notificationsEnabled = true;

  final BackupService _backupService = BackupService();

  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'Dólar estadounidense'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'MXN', 'symbol': '\$', 'name': 'Peso mexicano'},
    {'code': 'COP', 'symbol': '\$', 'name': 'Peso colombiano'},
    {'code': 'ARS', 'symbol': '\$', 'name': 'Peso argentino'},
    {'code': 'CLP', 'symbol': '\$', 'name': 'Peso chileno'},
  ];

  final List<Map<String, dynamic>> _weekDays = [
    {'value': DateTime.monday, 'name': 'Lunes'},
    {'value': DateTime.sunday, 'name': 'Domingo'},
    {'value': DateTime.saturday, 'name': 'Sábado'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currency = prefs.getString('currency') ?? 'USD';
      _weekStart = prefs.getInt('week_start') ?? DateTime.monday;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    setState(() => _currency = currency);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Moneda actualizada')));
    }
  }

  Future<void> _saveWeekStart(int weekStart) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('week_start', weekStart);
    setState(() => _weekStart = weekStart);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicio de semana actualizado')),
      );
    }
  }

  Future<void> _saveNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    setState(() => _notificationsEnabled = enabled);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Notificaciones activadas'
                : 'Notificaciones desactivadas',
          ),
        ),
      );
    }
  }

  Future<void> _createBackup() async {
    try {
      final path = await _backupService.createBackup();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup creado: $path')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al crear backup: $e')));
      }
    }
  }

  Future<void> _restoreBackup() async {
    try {
      final restored = await _backupService.restoreBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              restored
                  ? 'Backup restaurado correctamente'
                  : 'Restauración cancelada',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al restaurar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          _buildSection('Apariencia'),
          _buildDarkModeTile(),
          const Divider(),
          _buildSection('General'),
          _buildCurrencyTile(),
          _buildWeekStartTile(),
          const Divider(),
          _buildSection('Notificaciones'),
          _buildNotificationsTile(),
          const Divider(),
          _buildSection('Datos'),
          _buildBackupTile(),
          _buildRestoreTile(),
          _buildImportTile(),
          const Divider(),
          _buildSection('Acerca de'),
          _buildAboutTile(),
        ],
      ),
    );
  }

  Widget _buildDarkModeTile() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return SwitchListTile(
          secondary: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          ),
          title: const Text('Modo oscuro'),
          subtitle: Text(
            themeProvider.isDarkMode
                ? 'Tema oscuro activado'
                : 'Tema claro activado',
          ),
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            themeProvider.toggleTheme();
          },
        );
      },
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildCurrencyTile() {
    return ListTile(
      leading: const Icon(Icons.attach_money),
      title: const Text('Moneda'),
      subtitle: Text(
        _currencies.firstWhere(
          (c) => c['code'] == _currency,
          orElse: () => _currencies[0],
        )['name']!,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Seleccionar moneda'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _currencies.length,
                itemBuilder: (context, index) {
                  final currency = _currencies[index];
                  return RadioListTile<String>(
                    title: Text(currency['name']!),
                    subtitle: Text('${currency['symbol']} ${currency['code']}'),
                    value: currency['code']!,
                    groupValue: _currency,
                    onChanged: (value) {
                      Navigator.pop(context, value);
                    },
                  );
                },
              ),
            ),
          ),
        );
        if (selected != null) {
          await _saveCurrency(selected);
        }
      },
    );
  }

  Widget _buildWeekStartTile() {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: const Text('Inicio de semana'),
      subtitle: Text(
        _weekDays.firstWhere(
          (d) => d['value'] == _weekStart,
          orElse: () => _weekDays[0],
        )['name'],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final selected = await showDialog<int>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Inicio de semana'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: _weekDays.map((day) {
                return RadioListTile<int>(
                  title: Text(day['name']),
                  value: day['value'],
                  groupValue: _weekStart,
                  onChanged: (value) {
                    Navigator.pop(context, value);
                  },
                );
              }).toList(),
            ),
          ),
        );
        if (selected != null) {
          await _saveWeekStart(selected);
        }
      },
    );
  }

  Widget _buildNotificationsTile() {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications),
      title: const Text('Notificaciones semanales'),
      subtitle: const Text('Recibe un resumen cada semana'),
      value: _notificationsEnabled,
      onChanged: _saveNotifications,
    );
  }

  Widget _buildBackupTile() {
    return ListTile(
      leading: const Icon(Icons.backup),
      title: const Text('Crear copia de seguridad'),
      subtitle: const Text('Guarda tus datos localmente'),
      trailing: const Icon(Icons.chevron_right),
      onTap: _createBackup,
    );
  }

  Widget _buildRestoreTile() {
    return ListTile(
      leading: const Icon(Icons.restore),
      title: const Text('Restaurar copia de seguridad'),
      subtitle: const Text('Recupera tus datos guardados'),
      trailing: const Icon(Icons.chevron_right),
      onTap: _restoreBackup,
    );
  }

  Widget _buildImportTile() {
    return ListTile(
      leading: const Icon(Icons.file_upload),
      title: const Text('Importar desde CSV'),
      subtitle: const Text('Importa transacciones desde archivo'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        try {
          final imported = await _backupService.importFromCSV();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  imported
                      ? 'Datos importados correctamente'
                      : 'Importación cancelada',
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error al importar: $e')));
          }
        }
      },
    );
  }

  Widget _buildAboutTile() {
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text('Acerca de la app'),
      subtitle: const Text('Versión 2.2.4'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'FinanzasPlus',
          applicationVersion: '2.2.4',
          applicationIcon: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 36,
              color: Colors.white,
            ),
          ),
          children: [
            const Text(
              'Aplicación completa para gestión de finanzas personales y hábitos saludables.',
            ),
            const SizedBox(height: 16),
            const Text('Desarrollado como proyecto de titulación AITEC'),
          ],
        );
      },
    );
  }
}
