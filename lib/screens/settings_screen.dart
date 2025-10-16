import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:zedsecure/services/v2ray_service.dart';
import 'package:zedsecure/services/theme_service.dart';
import 'package:zedsecure/theme/app_theme.dart';
import 'package:zedsecure/models/subscription.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zedsecure/screens/per_app_proxy_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoConnect = false;
  bool _killSwitch = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoConnect = prefs.getBool('auto_connect') ?? false;
      _killSwitch = prefs.getBool('kill_switch') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      ),
      content: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'General',
            [
              _buildSettingTile(
                'Auto Connect',
                'Automatically connect on app start',
                FluentIcons.play_solid,
                _autoConnect,
                (value) {
                  setState(() {
                    _autoConnect = value;
                  });
                  _saveSetting('auto_connect', value);
                },
              ),
              _buildSettingTile(
                'Kill Switch',
                'Block internet if VPN disconnects',
                FluentIcons.shield_solid,
                _killSwitch,
                (value) {
                  setState(() {
                    _killSwitch = value;
                  });
                  _saveSetting('kill_switch', value);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Network',
            [
              _buildNavigationTile(
                'Per-App Proxy',
                'Choose which apps use VPN',
                FluentIcons.permissions,
                () {
                  Navigator.push(
                    context,
                    FluentPageRoute(builder: (context) => const PerAppProxyScreen()),
                  );
                },
              ),
              _buildNavigationTile(
                'DNS Settings',
                'Configure custom DNS servers',
                FluentIcons.server_enviroment,
                () => _showDnsDialog(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Appearance',
            [
              Consumer<ThemeService>(
                builder: (context, themeService, child) {
                  return _buildSettingTile(
                    'Dark Mode',
                    themeService.isDarkMode ? 'Using dark theme' : 'Using light theme',
                    themeService.isDarkMode ? FluentIcons.clear_night : FluentIcons.sunny,
                    themeService.isDarkMode,
                    (value) async {
                      await themeService.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Data',
            [
              _buildActionTile(
                'Backup Configs',
                'Export all configs to Downloads',
                FluentIcons.cloud_upload,
                () => _backupConfigs(),
              ),
              _buildActionTile(
                'Restore Configs',
                'Import configs from backup file',
                FluentIcons.cloud_download,
                () => _restoreConfigs(),
              ),
              _buildActionTile(
                'Clear Server Cache',
                'Clear all cached server data',
                FluentIcons.clear,
                () => _clearCache(),
              ),
              _buildActionTile(
                'Clear All Data',
                'Reset all settings and servers',
                FluentIcons.delete,
                () => _clearAllData(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'About',
            [
              _buildInfoTile('App Name', 'Zed-Secure'),
              _buildInfoTile('Version', '1.3.0'),
              _buildInfoTile('Build', '4'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Developed by CluvexStudio',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _launchURL('https://github.com/CluvexStudio/ZedSecure'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FluentIcons.globe, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'github.com/CluvexStudio/ZedSecure',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    return Container(
      decoration: AppTheme.glassDecoration(borderRadius: 12, opacity: 0.05, isDark: themeService.isDarkMode),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: ToggleSwitch(
          checked: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, color: Colors.orange, size: 20),
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Button(
          onPressed: onPressed,
          child: const Text('Execute'),
        ),
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(FluentIcons.chevron_right),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached server data including ping results.'),
        actions: [
          Button(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);

              final service = Provider.of<V2RayService>(context, listen: false);
              service.clearPingCache();

              if (mounted) {
                await displayInfoBar(
                  context,
                  builder: (context, close) {
                    return const InfoBar(
                      title: Text('Cache Cleared'),
                      severity: InfoBarSeverity.success,
                    );
                  },
                  duration: const Duration(seconds: 2),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will delete all servers, subscriptions, and settings. This action cannot be undone.'),
        actions: [
          Button(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);

              final service = Provider.of<V2RayService>(context, listen: false);
              await service.saveConfigs([]);
              await service.saveSubscriptions([]);
              service.clearPingCache();

              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (mounted) {
                await displayInfoBar(
                  context,
                  builder: (context, close) {
                    return const InfoBar(
                      title: Text('All Data Cleared'),
                      severity: InfoBarSeverity.warning,
                    );
                  },
                  duration: const Duration(seconds: 2),
                );
              }
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> _backupConfigs() async {
    try {
      final service = Provider.of<V2RayService>(context, listen: false);
      final configs = await service.loadConfigs();
      final subscriptions = await service.loadSubscriptions();

      if (configs.isEmpty && subscriptions.isEmpty) {
        if (mounted) {
          await displayInfoBar(
            context,
            builder: (context, close) {
              return const InfoBar(
                title: Text('No Data'),
                content: Text('No configs or subscriptions to backup'),
                severity: InfoBarSeverity.warning,
              );
            },
            duration: const Duration(seconds: 2),
          );
        }
        return;
      }

      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'configs': configs.map((c) => c.toJson()).toList(),
        'subscriptions': subscriptions.map((s) => s.toJson()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory!.path}/zedsecure_backup_$timestamp.json');
      await file.writeAsString(jsonString);

      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Backup Created'),
              content: Text('Saved to: ${file.path}'),
              severity: InfoBarSeverity.success,
            );
          },
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Backup Failed'),
              content: Text('Error: ${e.toString()}'),
              severity: InfoBarSeverity.error,
            );
          },
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _restoreConfigs() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      final files = directory!.listSync()
          .where((f) => f.path.contains('zedsecure_backup_') && f.path.endsWith('.json'))
          .toList();

      if (files.isEmpty) {
        if (mounted) {
          await displayInfoBar(
            context,
            builder: (context, close) {
              return const InfoBar(
                title: Text('No Backups Found'),
                content: Text('No backup files found in Downloads folder'),
                severity: InfoBarSeverity.warning,
              );
            },
            duration: const Duration(seconds: 3),
          );
        }
        return;
      }

      files.sort((a, b) => b.path.compareTo(a.path));

      await showDialog(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Select Backup File'),
          content: SizedBox(
            width: 400,
            height: 300,
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final filename = file.path.split('/').last;
                return ListTile(
                  title: Text(filename),
                  subtitle: Text(File(file.path).statSync().modified.toString()),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _performRestore(file.path);
                  },
                );
              },
            ),
          ),
          actions: [
            Button(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Restore Failed'),
              content: Text('Error: ${e.toString()}'),
              severity: InfoBarSeverity.error,
            );
          },
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _performRestore(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      final service = Provider.of<V2RayService>(context, listen: false);
      int configsImported = 0;
      int subsImported = 0;

      if (backupData['configs'] != null) {
        final configsList = backupData['configs'] as List;
        final existingConfigs = await service.loadConfigs();
        
        for (var configJson in configsList) {
          try {
            final configMap = configJson as Map<String, dynamic>;
            final fullConfig = configMap['fullConfig'] as String;
            final parsedConfigs = await service.parseSubscriptionContent(fullConfig);
            existingConfigs.addAll(parsedConfigs);
            configsImported++;
          } catch (e) {
            debugPrint('Error parsing config: $e');
          }
        }
        
        await service.saveConfigs(existingConfigs);
      }

      if (backupData['subscriptions'] != null) {
        final subsList = backupData['subscriptions'] as List;
        final existingSubs = await service.loadSubscriptions();
        
        for (var subJson in subsList) {
          try {
            final sub = Subscription.fromJson(subJson as Map<String, dynamic>);
            if (!existingSubs.any((s) => s.url == sub.url)) {
              existingSubs.add(sub);
              subsImported++;
            }
          } catch (e) {
            debugPrint('Error parsing subscription: $e');
          }
        }
        
        await service.saveSubscriptions(existingSubs);
      }

      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Restore Complete'),
              content: Text(
                'Imported $configsImported config(s) and $subsImported subscription(s)'
              ),
              severity: InfoBarSeverity.success,
            );
          },
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Restore Failed'),
              content: Text('Error: ${e.toString()}'),
              severity: InfoBarSeverity.error,
            );
          },
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return const InfoBar(
              title: Text('Link Copied'),
              content: Text('GitHub link copied to clipboard'),
              severity: InfoBarSeverity.success,
            );
          },
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('Error copying URL: $e');
    }
  }

  Future<void> _showDnsDialog() async {
    final service = Provider.of<V2RayService>(context, listen: false);
    bool useDns = service.useDns;
    List<String> dnsServers = service.dnsServers;
    
    final dns1Controller = TextEditingController(text: dnsServers.isNotEmpty ? dnsServers[0] : '1.1.1.1');
    final dns2Controller = TextEditingController(text: dnsServers.length > 1 ? dnsServers[1] : '1.0.0.1');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => ContentDialog(
          title: const Text('DNS Settings'),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      checked: useDns,
                      onChanged: (value) {
                        setState(() {
                          useDns = value ?? true;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text('Use Custom DNS'),
                  ],
                ),
                const SizedBox(height: 16),
                if (useDns) ...[
                  const Text('Primary DNS', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  TextBox(
                    controller: dns1Controller,
                    placeholder: '1.1.1.1',
                  ),
                  const SizedBox(height: 12),
                  const Text('Secondary DNS', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  TextBox(
                    controller: dns2Controller,
                    placeholder: '1.0.0.1',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Popular DNS Providers:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(height: 8),
                        Text('Cloudflare: 1.1.1.1, 1.0.0.1', style: TextStyle(fontSize: 11)),
                        Text('Google: 8.8.8.8, 8.8.4.4', style: TextStyle(fontSize: 11)),
                        Text('Quad9: 9.9.9.9, 149.112.112.112', style: TextStyle(fontSize: 11)),
                        Text('OpenDNS: 208.67.222.222, 208.67.220.220', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            Button(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final servers = <String>[];
                if (dns1Controller.text.isNotEmpty) servers.add(dns1Controller.text.trim());
                if (dns2Controller.text.isNotEmpty) servers.add(dns2Controller.text.trim());
                
                if (servers.isEmpty) {
                  servers.addAll(['1.1.1.1', '1.0.0.1']);
                }
                
                await service.saveDnsSettings(useDns, servers);
                if (context.mounted) {
                  Navigator.pop(context);
                  await displayInfoBar(
                    context,
                    builder: (context, close) {
                      return const InfoBar(
                        title: Text('DNS Settings Saved'),
                        content: Text('Changes will apply on next connection'),
                        severity: InfoBarSeverity.success,
                      );
                    },
                    duration: const Duration(seconds: 3),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    
    dns1Controller.dispose();
    dns2Controller.dispose();
  }
}

