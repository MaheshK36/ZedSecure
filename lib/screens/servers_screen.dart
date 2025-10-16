import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:zedsecure/services/v2ray_service.dart';
import 'package:zedsecure/services/theme_service.dart';
import 'package:zedsecure/models/v2ray_config.dart';
import 'package:zedsecure/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ServersScreen extends StatefulWidget {
  const ServersScreen({super.key});

  @override
  State<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends State<ServersScreen> {
  List<V2RayConfig> _configs = [];
  bool _isLoading = true;
  bool _isSorting = false;
  String _searchQuery = '';
  final Map<String, int?> _pingResults = {};
  String? _selectedConfigId;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
    _loadSelectedConfig();
  }

  Future<void> _loadSelectedConfig() async {
    final service = Provider.of<V2RayService>(context, listen: false);
    final selected = await service.loadSelectedConfig();
    if (selected != null) {
      setState(() {
        _selectedConfigId = selected.id;
      });
    }
  }

  Future<void> _loadConfigs() async {
    setState(() {
      _isLoading = true;
    });

    final service = Provider.of<V2RayService>(context, listen: false);
    final configs = await service.loadConfigs();

    setState(() {
      _configs = configs;
      _isLoading = false;
    });
  }

  Future<void> _pingAllServers() async {
    setState(() {
      _isSorting = true;
      _pingResults.clear();
    });

    final service = Provider.of<V2RayService>(context, listen: false);
    
    final futures = <Future>[];
    for (int i = 0; i < _configs.length; i++) {
      final config = _configs[i];
      
      final future = service.getServerDelay(config).then((ping) {
        if (mounted) {
          setState(() {
            _pingResults[config.id] = ping ?? -1;
          });
        }
      }).catchError((e) {
        if (mounted) {
          setState(() {
            _pingResults[config.id] = -1;
          });
        }
      });
      
      futures.add(future);
      
      if (futures.length >= 10 || i == _configs.length - 1) {
        await Future.wait(futures);
        futures.clear();
      }
    }

    if (mounted) {
      _sortByPing();
      setState(() {
        _isSorting = false;
      });
    }
  }

  void _sortByPing() {
    setState(() {
      _configs.sort((a, b) {
        final pingA = _pingResults[a.id] ?? 999999;
        final pingB = _pingResults[b.id] ?? 999999;
        
        if (pingA == -1 && pingB == -1) return 0;
        if (pingA == -1) return 1;
        if (pingB == -1) return -1;
        
        return pingA.compareTo(pingB);
      });
    });
  }

  List<V2RayConfig> get _filteredConfigs {
    if (_searchQuery.isEmpty) return _configs;
    return _configs.where((config) {
      return config.remark.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          config.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          config.configType.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<V2RayConfig> get _manualConfigs {
    return _filteredConfigs.where((config) => config.source == 'manual').toList();
  }

  List<V2RayConfig> get _subscriptionConfigs {
    return _filteredConfigs.where((config) => config.source == 'subscription').toList();
  }

  Future<void> _importFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData == null || clipboardData.text == null || clipboardData.text!.isEmpty) {
        if (mounted) {
          await displayInfoBar(
            context,
            builder: (context, close) {
              return const InfoBar(
                title: Text('Empty Clipboard'),
                content: Text('Please copy a config first'),
                severity: InfoBarSeverity.warning,
              );
            },
            duration: const Duration(seconds: 2),
          );
        }
        return;
      }

      final service = Provider.of<V2RayService>(context, listen: false);
      final config = await service.parseConfigFromClipboard(clipboardData.text!);

      if (config != null) {
        await _loadConfigs();
        if (mounted) {
          await displayInfoBar(
            context,
            builder: (context, close) {
              return InfoBar(
                title: const Text('Config Added'),
                content: Text('${config.remark} added successfully'),
                severity: InfoBarSeverity.success,
              );
            },
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Import Failed'),
              content: Text(e.toString()),
              severity: InfoBarSeverity.error,
            );
          },
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Servers', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        commandBar: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            IconButton(
              icon: const Icon(FluentIcons.paste, size: 18),
              onPressed: _importFromClipboard,
            ),
            IconButton(
              icon: const Icon(FluentIcons.q_r_code, size: 18),
              onPressed: _scanQRCode,
            ),
            IconButton(
              icon: _isSorting
                  ? const SizedBox(width: 18, height: 18, child: ProgressRing())
                  : const Icon(FluentIcons.sort, size: 18),
              onPressed: _isSorting ? null : _pingAllServers,
            ),
            if (_pingResults.values.any((ping) => ping == -1))
              IconButton(
                icon: Icon(FluentIcons.delete, size: 18, color: Colors.red),
                onPressed: _deleteDeadConfigs,
              ),
            IconButton(
              icon: const Icon(FluentIcons.refresh, size: 18),
              onPressed: _loadConfigs,
            ),
          ],
        ),
      ),
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextBox(
              placeholder: 'Search servers...',
              prefix: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(FluentIcons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: ProgressRing())
                : _filteredConfigs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FluentIcons.server, size: 64, color: Colors.grey[80]),
                            const SizedBox(height: 16),
                            const Text(
                              'No servers found',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add servers from Subscriptions',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          if (_manualConfigs.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12, top: 8),
                              child: Row(
                                children: [
                                  const Icon(FluentIcons.edit, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Manual Configs (${_manualConfigs.length})',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ..._manualConfigs.map((config) => _buildServerCard(config)),
                            const SizedBox(height: 24),
                          ],
                          if (_subscriptionConfigs.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12, top: 8),
                              child: Row(
                                children: [
                                  const Icon(FluentIcons.cloud_download, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Subscription Configs (${_subscriptionConfigs.length})',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ..._subscriptionConfigs.map((config) => _buildServerCard(config)),
                          ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerCard(V2RayConfig config) {
    final ping = _pingResults[config.id];
    final service = Provider.of<V2RayService>(context, listen: false);
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final isConnected = service.activeConfig?.id == config.id;
    final isSelected = _selectedConfigId == config.id;

    return GestureDetector(
      onTap: isConnected ? null : () => _handleSelectConfig(config),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.glassDecoration(
          borderRadius: 12, 
          opacity: isConnected ? 0.15 : (isSelected ? 0.1 : 0.05),
          isDark: themeService.isDarkMode,
        ).copyWith(
          border: isSelected && !isConnected
              ? Border.all(color: Colors.blue.withOpacity(0.5), width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.getPingColor(ping).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getProtocolIcon(config.configType),
                    color: AppTheme.getPingColor(ping),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      config.remark,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${config.address}:${config.port} • ${config.protocolDisplay}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[100],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
              if (ping != null && ping >= 0)
                Container(
                  constraints: const BoxConstraints(minWidth: 50),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.getPingColor(ping).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${ping}ms',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.getPingColor(ping),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              if (ping != null && ping == -1)
                Container(
                  constraints: const BoxConstraints(minWidth: 50),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Fail',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              if (ping == null)
                const SizedBox(width: 50),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(FluentIcons.speed_high, size: 16),
                onPressed: () => _pingSingleServer(config),
              ),
              IconButton(
                icon: Icon(
                  isConnected ? FluentIcons.plug_disconnected : FluentIcons.plug_connected,
                  size: 16,
                ),
                onPressed: () => _handleConnect(config),
              ),
              DropDownButton(
                leading: const Icon(FluentIcons.more_vertical, size: 16),
                items: [
                  MenuFlyoutItem(
                    leading: const Icon(FluentIcons.copy, size: 14),
                    text: const Text('Copy Config'),
                    onPressed: () => _copyConfig(config),
                  ),
                  MenuFlyoutItem(
                    leading: const Icon(FluentIcons.q_r_code, size: 14),
                    text: const Text('Show QR Code'),
                    onPressed: () => _showQRCode(config),
                  ),
                  if (!isConnected)
                    MenuFlyoutItem(
                      leading: Icon(FluentIcons.delete, size: 14, color: Colors.red),
                      text: const Text('Delete'),
                      onPressed: () => _deleteConfig(config),
                    ),
                ],
              ),
            ],
          ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSelectConfig(V2RayConfig config) async {
    setState(() {
      _selectedConfigId = config.id;
    });

    final service = Provider.of<V2RayService>(context, listen: false);
    await service.saveSelectedConfig(config);

    if (mounted) {
      await displayInfoBar(
        context,
        builder: (context, close) {
          return InfoBar(
            title: const Text('Server Selected'),
            content: Text('${config.remark} is now selected'),
            severity: InfoBarSeverity.success,
          );
        },
        duration: const Duration(seconds: 2),
      );
    }
  }

  IconData _getProtocolIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vmess':
        return FluentIcons.shield;
      case 'vless':
        return FluentIcons.shield_solid;
      case 'trojan':
        return FluentIcons.security_group;
      case 'shadowsocks':
        return FluentIcons.lock_solid;
      default:
        return FluentIcons.server;
    }
  }

  Future<void> _pingSingleServer(V2RayConfig config) async {
    setState(() {
      _pingResults[config.id] = null; // Show loading
    });
    
    final service = Provider.of<V2RayService>(context, listen: false);
    final ping = await service.getServerDelay(config);
    
    if (mounted) {
      setState(() {
        _pingResults[config.id] = ping ?? -1;
      });
    }
  }

  Future<void> _deleteConfig(V2RayConfig config) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Delete Config'),
        content: Text('Are you sure you want to delete "${config.remark}"?'),
        actions: [
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      final service = Provider.of<V2RayService>(context, listen: false);
      final configs = await service.loadConfigs();
      configs.removeWhere((c) => c.id == config.id);
      await service.saveConfigs(configs);
      service.clearPingCache(configId: config.id);
      
      await _loadConfigs();
      
      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Config Deleted'),
              content: Text('${config.remark} has been deleted'),
              severity: InfoBarSeverity.warning,
            );
          },
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> _deleteDeadConfigs() async {
    final deadConfigs = _configs.where((config) {
      final ping = _pingResults[config.id];
      return ping == -1;
    }).toList();

    if (deadConfigs.isEmpty) {
      await displayInfoBar(
        context,
        builder: (context, close) {
          return const InfoBar(
            title: Text('No Dead Configs'),
            content: Text('All configs are working fine'),
            severity: InfoBarSeverity.info,
          );
        },
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Delete Dead Configs'),
        content: Text(
          'Found ${deadConfigs.length} dead config(s) with timeout or failed ping.\n\n'
          'Do you want to delete them?'
        ),
        actions: [
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (result == true) {
      final service = Provider.of<V2RayService>(context, listen: false);
      final configs = await service.loadConfigs();
      
      final deadIds = deadConfigs.map((c) => c.id).toSet();
      configs.removeWhere((c) => deadIds.contains(c.id));
      
      await service.saveConfigs(configs);
      
      for (var config in deadConfigs) {
        service.clearPingCache(configId: config.id);
      }
      
      await _loadConfigs();
      setState(() {
        _pingResults.clear();
      });
      
      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Dead Configs Deleted'),
              content: Text('Deleted ${deadConfigs.length} dead config(s)'),
              severity: InfoBarSeverity.success,
            );
          },
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _copyConfig(V2RayConfig config) async {
    await Clipboard.setData(ClipboardData(text: config.fullConfig));
    if (mounted) {
      await displayInfoBar(
        context,
        builder: (context, close) {
          return InfoBar(
            title: const Text('Config Copied'),
            content: Text('${config.remark} copied to clipboard'),
            severity: InfoBarSeverity.success,
          );
        },
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _showQRCode(V2RayConfig config) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(config.remark),
        content: SizedBox(
          width: 350,
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: config.fullConfig,
                  version: QrVersions.auto,
                  size: 300,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scan this QR code to import config',
                style: TextStyle(fontSize: 12, color: Colors.grey[100]),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanQRCode() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return const InfoBar(
              title: Text('Permission Denied'),
              content: Text('Camera permission is required to scan QR codes'),
              severity: InfoBarSeverity.error,
            );
          },
          duration: const Duration(seconds: 3),
        );
      }
      return;
    }

    if (mounted) {
      await Navigator.push(
        context,
        FluentPageRoute(
          builder: (context) => _QRScannerScreen(
            onQRScanned: (String code) async {
              Navigator.pop(context);
              try {
                final service = Provider.of<V2RayService>(context, listen: false);
                final config = await service.parseConfigFromClipboard(code);
                if (config != null) {
                  await _loadConfigs();
                  if (mounted) {
                    await displayInfoBar(
                      context,
                      builder: (context, close) {
                        return InfoBar(
                          title: const Text('Config Added'),
                          content: Text('${config.remark} added from QR code'),
                          severity: InfoBarSeverity.success,
                        );
                      },
                      duration: const Duration(seconds: 2),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  await displayInfoBar(
                    context,
                    builder: (context, close) {
                      return InfoBar(
                        title: const Text('Invalid QR Code'),
                        content: Text(e.toString()),
                        severity: InfoBarSeverity.error,
                      );
                    },
                    duration: const Duration(seconds: 3),
                  );
                }
              }
            },
          ),
        ),
      );
    }
  }

  Future<void> _handleConnect(V2RayConfig config) async {
    final service = Provider.of<V2RayService>(context, listen: false);

    if (service.activeConfig?.id == config.id) {
      await service.disconnect();
      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return const InfoBar(
              title: Text('Disconnected'),
              severity: InfoBarSeverity.info,
            );
          },
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      if (service.isConnected) {
        await service.disconnect();
      }

      final success = await service.connect(config);
      if (mounted) {
        await displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: Text(success ? 'Connected' : 'Connection Failed'),
              content: Text(
                success ? 'Connected to ${config.remark}' : 'Failed to connect to server',
              ),
              severity: success ? InfoBarSeverity.success : InfoBarSeverity.error,
            );
          },
          duration: const Duration(seconds: 2),
        );
      }
    }
  }
}

class _QRScannerScreen extends StatefulWidget {
  final Function(String) onQRScanned;

  const _QRScannerScreen({required this.onQRScanned});

  @override
  State<_QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<_QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (isScanning) {
      final List<Barcode> barcodes = capture.barcodes;
      for (final barcode in barcodes) {
        if (barcode.rawValue != null) {
          isScanning = false;
          controller.stop();
          widget.onQRScanned(barcode.rawValue!);
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Scan QR Code'),
        leading: IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      content: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Position the QR code within the frame',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

