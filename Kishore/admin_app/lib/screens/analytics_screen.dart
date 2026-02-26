import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'All Time';
  final List<String> _periods = ['Today', 'This Week', 'This Month', 'All Time'];
  
  double _totalRevenue = 0;
  int _totalShops = 0;
  int _activeShops = 0;
  int _totalSales = 0;
  List<ShopSalesData> _shopSalesData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    
    try {
      // Get all shopkeepers
      QuerySnapshot shopsSnapshot = await FirebaseFirestore.instance
          .collection('shopkeepers')
          .get();
      
      _totalShops = shopsSnapshot.docs.length;
      _activeShops = shopsSnapshot.docs.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return data['isAvailable'] == true;
      }).length;
      
      List<ShopSalesData> tempShopData = [];
      double totalRevenue = 0;
      int totalSalesCount = 0;
      
      // Get sales data for each shop
      for (var shopDoc in shopsSnapshot.docs) {
        var shopData = shopDoc.data() as Map<String, dynamic>;
        String shopId = shopDoc.id;
        String shopName = shopData['shopName'] ?? 'Unknown Shop';
        String ownerName = shopData['name'] ?? 'Unknown';
        
        // Get sales collection for this shop
        QuerySnapshot salesSnapshot = await FirebaseFirestore.instance
            .collection('shopkeepers')
            .doc(shopId)
            .collection('sales')
            .get();
        
        double shopTotal = 0;
        int shopSalesCount = 0;
        
        for (var saleDoc in salesSnapshot.docs) {
          var saleData = saleDoc.data() as Map<String, dynamic>;
          double amount = (saleData['amount'] as num?)?.toDouble() ?? 0;
          shopTotal += amount;
          shopSalesCount++;
        }
        
        totalRevenue += shopTotal;
        totalSalesCount += shopSalesCount;
        
        tempShopData.add(ShopSalesData(
          shopId: shopId,
          shopName: shopName,
          ownerName: ownerName,
          totalAmount: shopTotal,
          salesCount: shopSalesCount,
          color: _getColorForIndex(tempShopData.length),
        ));
      }
      
      // Sort by total amount descending
      tempShopData.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      
      setState(() {
        _shopSalesData = tempShopData;
        _totalRevenue = totalRevenue;
        _totalSales = totalSalesCount;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics: $e');
      setState(() => _isLoading = false);
    }
  }

  Color _getColorForIndex(int index) {
    List<Color> colors = [
      const Color(0xFF007AFF), // iOS Blue
      const Color(0xFF34C759), // Green
      const Color(0xFFFF9500), // Orange
      const Color(0xFF5856D6), // Purple
      const Color(0xFFFF2D55), // Pink
      const Color(0xFF64D2FF), // Light Blue
      const Color(0xFFFFCC00), // Yellow
      const Color(0xFFAF52DE), // Lavender
      const Color(0xFFFF3B30), // Red
      const Color(0xFF5AC8FA), // Teal
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Shop Details'),
          ],
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.background,
              AppTheme.background.withOpacity(0.95),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading analytics data...',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildShopDetailsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sales Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceGlass,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.divider.withOpacity(0.2),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPeriod,
                      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
                      items: _periods.map((String period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _selectedPeriod = newValue);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatsCard(
                'Total Revenue',
                '₹${_formatNumber(_totalRevenue)}',
                Icons.attach_money,
                AppTheme.primary,
              ),
              _buildStatsCard(
                'Total Shops',
                '$_totalShops',
                Icons.store,
                AppTheme.success,
              ),
              _buildStatsCard(
                'Active Shops',
                '$_activeShops',
                Icons.check_circle,
                Colors.orange,
              ),
              _buildStatsCard(
                'Total Sales',
                '$_totalSales',
                Icons.receipt_long,
                Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Revenue Distribution Title
          const Text(
            'Revenue Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total revenue shared among ${_shopSalesData.length} shops',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          // Pie Chart
          if (_totalRevenue > 0)
            _buildPieChart()
          else
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.surfaceGlass,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 60,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No sales data available',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add sales records to see analytics',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Sales Breakdown List
          const Text(
            'Shop Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildSalesBreakdownList(),
        ],
      ),
    );
  }

  Widget _buildShopDetailsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _shopSalesData.length,
      itemBuilder: (context, index) {
        final shop = _shopSalesData[index];
        final percentage = _totalRevenue > 0 
            ? (shop.totalAmount / _totalRevenue * 100) 
            : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceGlass,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: shop.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: shop.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.shopName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            shop.ownerName,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem('Total Sales', shop.salesCount.toString()),
                    _buildDetailItem('Revenue', '₹${_formatNumber(shop.totalAmount)}'),
                    _buildDetailItem('Share', '${percentage.toStringAsFixed(1)}%'),
                  ],
                ),
                if (index < _shopSalesData.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Divider(
                      color: AppTheme.divider.withOpacity(0.2),
                      height: 1,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlass,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlass,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: PieChartPainter(
                shopSalesData: _shopSalesData.where((shop) => shop.totalAmount > 0).toList(),
                totalRevenue: _totalRevenue,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: _shopSalesData.asMap().entries.map((entry) {
        final index = entry.key;
        final shop = entry.value;
        if (shop.totalAmount == 0) return const SizedBox.shrink();
        
        final percentage = (shop.totalAmount / _totalRevenue * 100);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: shop.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: shop.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${shop.shopName} (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSalesBreakdownList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _shopSalesData.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final shop = _shopSalesData[index];
        final percentage = _totalRevenue > 0 
            ? (shop.totalAmount / _totalRevenue * 100) 
            : 0.0;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceGlass,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: shop.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: shop.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.shopName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${shop.salesCount} sales',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${_formatNumber(shop.totalAmount)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: shop.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: shop.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: shop.color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(shop.color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatNumber(double number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(1)}Cr';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(1)}L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }
}

class ShopSalesData {
  final String shopId;
  final String shopName;
  final String ownerName;
  final double totalAmount;
  final int salesCount;
  final Color color;

  ShopSalesData({
    required this.shopId,
    required this.shopName,
    required this.ownerName,
    required this.totalAmount,
    required this.salesCount,
    required this.color,
  });
}

class PieChartPainter extends CustomPainter {
  final List<ShopSalesData> shopSalesData;
  final double totalRevenue;

  PieChartPainter({
    required this.shopSalesData,
    required this.totalRevenue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.2;
    
    double startAngle = -90 * (3.14159 / 180); // Start from top
    
    // Draw pie slices
    for (int i = 0; i < shopSalesData.length; i++) {
      final shop = shopSalesData[i];
      final sweepAngle = (shop.totalAmount / totalRevenue) * 360 * (3.14159 / 180);
      
      final paint = Paint()
        ..color = shop.color
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
    
    // Draw inner white circle for donut style (optional)
    final innerPaint = Paint()
      ..color = AppTheme.surfaceGlass
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.6, innerPaint);
    
    // Draw center text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Total\n${_formatNumber(totalRevenue)}',
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  String _formatNumber(double number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(1)}Cr';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(1)}L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}