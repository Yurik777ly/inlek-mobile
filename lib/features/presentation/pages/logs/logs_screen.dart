import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/http_logger.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<HttpLogEntry> _logs = [];
  HttpLogType? _selectedFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _timer;
  final Set<String> _expandedLogs = {};

  @override
  void initState() {
    super.initState();
    _loadLogs();

    // Обновляем логи каждые 2 секунды
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _loadLogs();
      }
    });
  }

  void _loadLogs() {
    setState(() {
      _logs = HttpLogger.getLogs();
    });
  }

  void _toggleAutoRefresh() {
    setState(() {
      if (_timer != null) {
        _timer?.cancel();
        _timer = null;
      } else {
        _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
          if (mounted) {
            _loadLogs();
          }
        });
      }
    });
  }

  List<HttpLogEntry> get _filteredLogs {
    var filtered = _logs;

    if (_selectedFilter != null) {
      filtered = filtered.where((log) => log.type == _selectedFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((log) {
        return log.url.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            log.method.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            log.body.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiConstants.whiteColor,
      appBar: AppBar(
        title: const Text(
          'HTTP Логи',
          style: TextStyle(
            color: UiConstants.blackColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: UiConstants.whiteColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              _timer != null ? Icons.pause : Icons.play_arrow,
              color: UiConstants.blackColor,
            ),
            onPressed: _toggleAutoRefresh,
            tooltip: _timer != null
                ? 'Остановить автообновление'
                : 'Запустить автообновление',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: UiConstants.blackColor),
            onPressed: _loadLogs,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: UiConstants.blackColor),
            onSelected: (value) {
              if (value == 'clear') {
                _clearLogs();
              } else if (value == 'export') {
                _exportLogs();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Text('Экспорт логов'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Очистить логи'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _buildLogsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск по логам...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: UiConstants.pink2Color),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Все', null),
                SizedBox(width: 8.w),
                _buildFilterChip('Запросы', HttpLogType.request),
                SizedBox(width: 8.w),
                _buildFilterChip('Ответы', HttpLogType.response),
                SizedBox(width: 8.w),
                _buildFilterChip('Ошибки', HttpLogType.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, HttpLogType? type) {
    final isSelected = _selectedFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? type : null;
        });
      },
      selectedColor: UiConstants.pink2Color.withOpacity(0.2),
      checkmarkColor: UiConstants.pink2Color,
    );
  }

  Widget _buildLogsList() {
    final filteredLogs = _filteredLogs;

    if (filteredLogs.isEmpty) {
      return const Center(
        child: Text(
          'Логи не найдены',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: getMarginOrPadding(bottom: 94),
      itemCount: filteredLogs.length,
      itemBuilder: (context, index) {
        final log = filteredLogs[index];
        return _buildLogItem(log);
      },
    );
  }

  Widget _buildLogItem(HttpLogEntry log) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: InkWell(
        onTap: () => _showLogDetails(log),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIndicator(log),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      log.method,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _copyLogData(log),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: UiConstants.pink2Color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.copy,
                        size: 16.w,
                        color: UiConstants.pink2Color,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    log.formattedTimestamp,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                log.shortUrl,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (log.statusCode != null) ...[
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'Status: ${log.statusCode}',
                      style: TextStyle(
                        color: log.isSuccess ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (log.duration != null) ...[
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          log.formattedDuration,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ] else if (log.duration != null) ...[
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.formattedDuration,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (log.body.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (_expandedLogs.contains(log.id)) {
                                    _expandedLogs.remove(log.id);
                                  } else {
                                    _expandedLogs.add(log.id);
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    _isJson(log.body)
                                        ? Icons.code
                                        : Icons.text_fields,
                                    size: 12.w,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      _isJson(log.body)
                                          ? 'JSON Body (${log.body.length} chars)'
                                          : 'Body (${log.body.length} chars)',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    _expandedLogs.contains(log.id)
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    size: 16.w,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          InkWell(
                            onTap: () => _copyBody(log.body),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.copy,
                                size: 14.w,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_expandedLogs.contains(log.id)) ...[
                        SizedBox(height: 4.h),
                        SelectableText(
                          _isJson(log.body) ? _formatJson(log.body) : log.body,
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: Colors.grey[700],
                          ),
                        ),
                      ] else ...[
                        SizedBox(height: 4.h),
                        SelectableText(
                          _isJson(log.body) ? _formatJson(log.body) : log.body,
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(HttpLogEntry log) {
    Color color;
    IconData icon;

    switch (log.type) {
      case HttpLogType.request:
        color = Colors.blue;
        icon = Icons.arrow_upward;
        break;
      case HttpLogType.response:
        color = log.isSuccess ? Colors.green : Colors.red;
        icon = Icons.arrow_downward;
        break;
      case HttpLogType.error:
        color = Colors.red;
        icon = Icons.error;
        break;
    }

    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 14.w,
        color: color,
      ),
    );
  }

  void _showLogDetails(HttpLogEntry log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: GestureDetector(
            onTap:
                () {}, // Предотвращаем закрытие при клике на сам bottom sheet
            child: DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              builder: (context, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: UiConstants.whiteColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          _buildStatusIndicator(log),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '${log.method} ${log.shortUrl}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _copyLogData(log),
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: UiConstants.pink2Color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.copy,
                                size: 18.w,
                                color: UiConstants.pink2Color,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailSection('URL', log.url),
                            _buildDetailSection('Method', log.method),
                            _buildDetailSection(
                                'Timestamp', log.formattedTimestamp),
                            if (log.duration != null)
                              _buildDetailSection(
                                  'Duration', log.formattedDuration),
                            if (log.statusCode != null)
                              _buildDetailSection(
                                  'Status Code', log.statusCode.toString()),
                            _buildDetailSection(
                                'Headers', _formatHeaders(log.headers)),
                            _buildBodySection(log.body),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: UiConstants.pink2Color,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: SelectableText(
              content,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodySection(String body) {
    final isJson = _isJson(body);
    final displayBody = body.isNotEmpty ? body : 'Empty';

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isJson ? Icons.code : Icons.text_fields,
                size: 16.w,
                color: UiConstants.pink2Color,
              ),
              SizedBox(width: 8.w),
              Text(
                'Body',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: UiConstants.pink2Color,
                ),
              ),
              if (isJson) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: UiConstants.pink2Color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'JSON',
                    style: TextStyle(
                      fontSize: 10,
                      color: UiConstants.pink2Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              InkWell(
                onTap: () => _copyBody(body),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: UiConstants.pink2Color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.copy,
                    size: 16.w,
                    color: UiConstants.pink2Color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: SelectableText(
              isJson ? _formatJson(displayBody) : displayBody,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatHeaders(Map<String, String> headers) {
    if (headers.isEmpty) return 'No headers';
    return headers.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  void _copyBody(String body) {
    final textToCopy = _isJson(body) ? _formatJson(body) : body;
    Clipboard.setData(ClipboardData(text: textToCopy));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isJson(body)
              ? 'Formatted JSON copied to clipboard'
              : 'Body copied to clipboard',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: UiConstants.pink2Color,
      ),
    );
  }

  void _copyLogData(HttpLogEntry log) {
    final buffer = StringBuffer();

    // Заголовок
    buffer.writeln('=== HTTP ${log.type.toString().toUpperCase()} ===');
    buffer.writeln('Time: ${log.formattedTimestamp}');
    buffer.writeln('ID: ${log.id}');
    buffer.writeln();

    // Основная информация
    buffer.writeln('Method: ${log.method}');
    buffer.writeln('URL: ${log.url}');
    if (log.duration != null) {
      buffer.writeln('Duration: ${log.formattedDuration}');
    }
    if (log.statusCode != null) {
      buffer.writeln('Status Code: ${log.statusCode}');
    }
    buffer.writeln();

    // Headers
    buffer.writeln('Headers:');
    if (log.headers.isEmpty) {
      buffer.writeln('  No headers');
    } else {
      log.headers.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }
    buffer.writeln();

    // Body
    buffer.writeln('Body:');
    if (log.body.isEmpty) {
      buffer.writeln('  Empty');
    } else {
      final bodyText = _isJson(log.body) ? _formatJson(log.body) : log.body;
      // Добавляем отступы к каждой строке body
      bodyText.split('\n').forEach((line) {
        buffer.writeln('  $line');
      });
    }

    final textToCopy = buffer.toString();
    Clipboard.setData(ClipboardData(text: textToCopy));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${log.type.toString().toUpperCase()} data copied to clipboard',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: UiConstants.pink2Color,
      ),
    );
  }

  String _formatJson(String jsonString) {
    if (jsonString.isEmpty) return 'Empty';

    try {
      final jsonObject = jsonDecode(jsonString);
      return JsonEncoder.withIndent('  ').convert(jsonObject);
    } catch (e) {
      return jsonString; // Если не JSON, возвращаем как есть
    }
  }

  bool _isJson(String text) {
    if (text.isEmpty) return false;
    try {
      jsonDecode(text);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить логи'),
        content: const Text('Вы уверены, что хотите очистить все логи?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              HttpLogger.clearLogs();
              _loadLogs();
              Navigator.pop(context);
            },
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }

  void _exportLogs() {
    final logsJson = _logs.map((log) => log.toJson()).toList();
    final jsonString = JsonEncoder.withIndent('  ').convert(logsJson);

    Clipboard.setData(ClipboardData(text: jsonString));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Логи скопированы в буфер обмена'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
