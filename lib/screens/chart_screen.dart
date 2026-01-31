import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';
import '../models/sensor_data.dart';
import '../utils/event_bus.dart';
import '../widgets/custom_appbar.dart';
import 'dart:async';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BluetoothProvider _bluetoothProvider;
  List<SensorData> _sensorData = [];
  bool _isLoading = true;
  String _selectedTimeRange = 'Son 1 Saat';
  String _graphType = 'all'; // Default to showing all graphs
  late StreamSubscription _graphTypeSubscription;

  // Renk tanımlamaları
  final Color _internalTempColor = Colors.red;
  final Color _externalTempColor = Colors.blue;
  final Color _heartRateColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Event bus aboneliği
    _graphTypeSubscription =
        eventBus.on<GraphTypeSelectedEvent>().listen((event) {
      setState(() {
        _graphType = event.graphType;
        // Grafik tipine göre tab seç
        if (event.graphType == 'internal_temp' ||
            event.graphType == 'external_temp') {
          _tabController.animateTo(0); // Sıcaklık tab'ı
        } else if (event.graphType == 'heart_rate') {
          _tabController.animateTo(1); // Nabız tab'ı
        } else {
          _tabController.animateTo(2); // Hepsi tab'ı
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bluetoothProvider =
          Provider.of<BluetoothProvider>(context, listen: false);
      _loadData();

      // Eğer önceden bir grafik tipi seçildiyse, onu kullan
      if (selectedGraphType != 'all') {
        if (selectedGraphType == 'internal_temp' ||
            selectedGraphType == 'external_temp') {
          _tabController.animateTo(0); // Sıcaklık tab'ı
        } else if (selectedGraphType == 'heart_rate') {
          _tabController.animateTo(1); // Nabız tab'ı
        } else {
          _tabController.animateTo(2); // Hepsi tab'ı
        }
        _graphType = selectedGraphType;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _graphTypeSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<SensorData> data;

      switch (_selectedTimeRange) {
        case 'Son 1 Saat':
          data = await _bluetoothProvider.getLastHourData();
          debugPrint(
              "📊 Son 1 saat verisi yükleniyor. Veri sayısı: ${data.length}");
          break;
        case 'Bugün':
          data = await _bluetoothProvider.getTodaysSensorData();
          debugPrint(
              "📊 Bugünün verisi yükleniyor. Veri sayısı: ${data.length}");
          break;
        default:
          final now = DateTime.now();
          final yesterday = now.subtract(const Duration(days: 1));
          data =
              await _bluetoothProvider.getSensorDataByDateRange(yesterday, now);
          debugPrint(
              "📊 Son 24 saat verisi yükleniyor. Veri sayısı: ${data.length}");
      }

      // Veri kontrolü
      if (data.isEmpty) {
        debugPrint("⚠️ Grafik için hiç veri bulunamadı!");
      } else {
        debugPrint(
            "✅ ${data.length} adet veri yüklendi. İlk veri: ${data.first}, Son veri: ${data.last}");
      }

      setState(() {
        _sensorData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Veri yükleme hatası: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sensorData.isEmpty
              ? _buildNoDataView()
              : _buildChartView(),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Kayıtlı sensör verisi bulunamadı",
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            "Bluetooth ile bağlanıp veri toplayın",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildChartView() {
    return Column(
      children: [
        // Üst kısımdaki kontroller
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(
                    51), // 0.2 opaklık değeri yaklaşık 51 alpha değerine eşit
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grafik tipi seçimi
              Row(
                children: [
                  const Text('Grafik Tipi: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _graphType,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                            value: 'all', child: Text('Tüm Grafikler')),
                        const DropdownMenuItem(
                            value: 'internal_temp', child: Text('İç Sıcaklık')),
                        const DropdownMenuItem(
                            value: 'external_temp',
                            child: Text('Dış Sıcaklık')),
                        const DropdownMenuItem(
                            value: 'heart_rate', child: Text('Nabız')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _graphType = value!;
                          selectedGraphType = value;
                          // Grafik tipine göre tab seç
                          if (value == 'internal_temp' ||
                              value == 'external_temp') {
                            _tabController.animateTo(0); // Sıcaklık tab'ı
                          } else if (value == 'heart_rate') {
                            _tabController.animateTo(1); // Nabız tab'ı
                          } else {
                            _tabController.animateTo(2); // Hepsi tab'ı
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Zaman aralığı seçimi
              Row(
                children: [
                  const Text('Zaman Aralığı: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedTimeRange,
                      isExpanded: true,
                      items: ['Son 1 Saat', 'Bugün', 'Son 24 Saat']
                          .map((String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedTimeRange = newValue!;
                          _loadData();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tab Bar - Daha belirgin ve geniş bir şekilde
        Container(
          color: Colors.grey.shade100,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.thermostat),
                text: 'Sıcaklık',
              ),
              Tab(
                icon: Icon(Icons.favorite),
                text: 'Nabız',
              ),
              Tab(
                icon: Icon(Icons.dashboard),
                text: 'Tümü',
              ),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorWeight: 3,
          ),
        ),

        // Tab içerikleri
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTemperatureChart(),
              _buildHeartRateChart(),
              _buildCombinedChart(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureChart() {
    // Seçilen grafik tipine göre lineBarsData'yı filtreleyelim
    List<LineChartBarData> lineBars = [];

    // İç sıcaklık grafiğini ekle (_graphType all veya internal_temp ise)
    if (_graphType == 'all' || _graphType == 'internal_temp') {
      lineBars.add(
        LineChartBarData(
          spots: _sensorData.asMap().entries.map((entry) {
            return FlSpot(
                entry.key.toDouble(), entry.value.internalTemperature);
          }).toList(),
          isCurved: true,
          color: _internalTempColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
              show: _graphType ==
                  'internal_temp'), // Sadece iç sıcaklık grafiğinde noktaları göster
          belowBarData: BarAreaData(
            show: _graphType == 'internal_temp',
            color: _internalTempColor.withAlpha(
                51), // 0.2 opaklık değeri yaklaşık 51 alpha değerine eşit
          ),
        ),
      );
    }

    // Dış sıcaklık grafiğini ekle (_graphType all veya external_temp ise)
    if (_graphType == 'all' || _graphType == 'external_temp') {
      lineBars.add(
        LineChartBarData(
          spots: _sensorData.asMap().entries.map((entry) {
            return FlSpot(
                entry.key.toDouble(), entry.value.externalTemperature);
          }).toList(),
          isCurved: true,
          color: _externalTempColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
              show: _graphType ==
                  'external_temp'), // Sadece dış sıcaklık grafiğinde noktaları göster
          belowBarData: BarAreaData(
            show: _graphType == 'external_temp',
            color: _externalTempColor.withAlpha(
                51), // 0.2 opaklık değeri yaklaşık 51 alpha değerine eşit
          ),
        ),
      );
    }

    // Grafiğin başlığı
    String chartTitle = '';
    if (_graphType == 'internal_temp') {
      chartTitle = 'İç Sıcaklık Grafiği';
    } else if (_graphType == 'external_temp') {
      chartTitle = 'Dış Sıcaklık Grafiği';
    } else {
      chartTitle = 'Sıcaklık Grafiği';
    }

    // Min-max değerlerini hesapla
    List<double> tempValues = [];
    if (_graphType == 'all' || _graphType == 'internal_temp') {
      tempValues.addAll(_sensorData.map((e) => e.internalTemperature).toList());
    }
    if (_graphType == 'all' || _graphType == 'external_temp') {
      tempValues.addAll(_sensorData.map((e) => e.externalTemperature).toList());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            chartTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text('Sıcaklık (°C)',
                        style: TextStyle(fontSize: 10)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toStringAsFixed(1)}°C',
                            style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget:
                        const Text('Saat', style: TextStyle(fontSize: 10)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < _sensorData.length) {
                          final time = _sensorData[value.toInt()].timestamp;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(DateFormat('HH:mm').format(time),
                                style: const TextStyle(fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1),
                ),
                lineBarsData: lineBars,
                minX: 0,
                maxX: (_sensorData.length - 1).toDouble(),
                minY: _calculateMinY(tempValues),
                maxY: _calculateMaxY(tempValues),
              ),
            ),
          ),
        ),
        // Lejant
        if (_graphType == 'all')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('İç Sıcaklık', _internalTempColor),
                const SizedBox(width: 20),
                _buildLegendItem('Dış Sıcaklık', _externalTempColor),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeartRateChart() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Nabız Grafiği',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text('Nabız (bpm)',
                        style: TextStyle(fontSize: 10)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()} bpm',
                            style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget:
                        const Text('Saat', style: TextStyle(fontSize: 10)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < _sensorData.length) {
                          final time = _sensorData[value.toInt()].timestamp;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(DateFormat('HH:mm').format(time),
                                style: const TextStyle(fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _sensorData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(),
                          entry.value.heartRate.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: _heartRateColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                        show:
                            true), // Nabız grafiğinde her zaman noktaları gösterelim
                    belowBarData: BarAreaData(
                      show: true,
                      color: _heartRateColor
                          .withAlpha(51), // 20% of 255 is about 51
                    ),
                  ),
                ],
                minX: 0,
                maxX: (_sensorData.length - 1).toDouble(),
                minY: _calculateMinY(
                    _sensorData.map((e) => e.heartRate.toDouble()).toList(),
                    margin: 10),
                maxY: _calculateMaxY(
                    _sensorData.map((e) => e.heartRate.toDouble()).toList(),
                    margin: 10),
              ),
            ),
          ),
        ),

        // Hızlı istatistikler
        if (_sensorData.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nabız İstatistikleri:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHeartRateStat(
                        'Min',
                        _sensorData
                            .map((e) => e.heartRate)
                            .reduce((a, b) => a < b ? a : b)),
                    _buildHeartRateStat(
                        'Ort',
                        _calculateAverage(_sensorData
                                .map((e) => e.heartRate.toDouble())
                                .toList())
                            .round()),
                    _buildHeartRateStat(
                        'Max',
                        _sensorData
                            .map((e) => e.heartRate)
                            .reduce((a, b) => a > b ? a : b)),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeartRateStat(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, color: _heartRateColor, size: 16),
              const SizedBox(width: 4),
              Text('$value bpm',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedChart() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // İç sıcaklık, dış sıcaklık ve nabız için lejant
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('İç Sıcaklık', _internalTempColor),
                _buildLegendItem('Dış Sıcaklık', _externalTempColor),
                _buildLegendItem('Nabız', _heartRateColor),
              ],
            ),
          ),

          // İstatistikler
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Özet İstatistikler',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildStatisticRow('Ortalama İç Sıcaklık',
                        '${_calculateAverage(_sensorData.map((e) => e.internalTemperature).toList()).toStringAsFixed(1)}°C'),
                    _buildStatisticRow('Ortalama Dış Sıcaklık',
                        '${_calculateAverage(_sensorData.map((e) => e.externalTemperature).toList()).toStringAsFixed(1)}°C'),
                    _buildStatisticRow('Ortalama Nabız',
                        '${_calculateAverage(_sensorData.map((e) => e.heartRate.toDouble()).toList()).toStringAsFixed(0)} bpm'),
                    _buildStatisticRow('Toplam Kayıt', '${_sensorData.length}'),
                    if (_sensorData.isNotEmpty) ...[
                      _buildStatisticRow(
                          'İlk Kayıt',
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(_sensorData.first.timestamp)),
                      _buildStatisticRow(
                          'Son Kayıt',
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(_sensorData.last.timestamp)),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Grafikler
          SizedBox(
            height: 250,
            child: _buildTemperatureChart(),
          ),

          const SizedBox(height: 32),

          SizedBox(
            height: 250,
            child: _buildHeartRateChart(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildStatisticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Yardımcı fonksiyonlar
  double _calculateMinY(List<double> values, {double margin = 5.0}) {
    if (values.isEmpty) return 0;
    return (values.reduce((a, b) => a < b ? a : b) - margin);
  }

  double _calculateMaxY(List<double> values, {double margin = 5.0}) {
    if (values.isEmpty) return 100;
    return (values.reduce((a, b) => a > b ? a : b) + margin);
  }

  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
}
