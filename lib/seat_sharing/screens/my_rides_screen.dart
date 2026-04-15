import 'package:zocar/helpers/navigation.dart';
import 'package:zocar/helpers/widget_binding.dart';
import 'package:zocar/seat_sharing/models/my_rides_list.dart';
import 'package:zocar/seat_sharing/repo/seat_sharing_repo.dart';
import 'package:zocar/seat_sharing/screens/ride_details_screen.dart';
import 'package:zocar/seat_sharing/screens/search_seat_sharing_ride_screen.dart';
import 'package:zocar/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/show_toast_dialog.dart';
import '../../helpers/loader.dart';
import '../controllers/seat_sharing_controller.dart';
import '../utils/format_date_time.dart';
import '../utils/ride_status_enum.dart';

class MyRidesListScreen extends StatefulWidget {
  const MyRidesListScreen({super.key});

  @override
  State<MyRidesListScreen> createState() => _MyRidesListScreenState();
}

class _MyRidesListScreenState extends State<MyRidesListScreen> with TickerProviderStateMixin {
  final repo = SeatSharingRepo();
  final ctr = Get.put(SeatSharingController());

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _showClearSearch = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = ['All', 'Upcoming', 'Started', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    widgetBinding((_) async {
      await getMyRidesList();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  getMyRidesList() async {
    final isShowLoading = ctr.myRidesListResponse == null;
    if (isShowLoading) showLoader(context);
    await ctr.getMyRidesList();
    if (isShowLoading) hideLoader();

    setState(() {});
  }

  List<MyRideData> get _filteredRides {
    List<MyRideData> rides = ctr.myRidesList;

    ///
    ///
    if (_selectedFilter != 'All') {
      rides = rides.where((ride) => ride.rideStatusEnum.displayName == _selectedFilter).toList();
    }

    ///
    ///
    if (_searchQuery.isNotEmpty) {
      rides = rides.where((ride) {
        return ride.fromStopName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ride.toStopName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ride.layoutLabel.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    ///
    /// sort by creation date newest first
    rides.sort((a, b) {
      final timeA = DateTime.tryParse(a.rideCreatedAt) ?? DateTime.now();
      final timeB = DateTime.tryParse(b.rideCreatedAt) ?? DateTime.now();
      return timeB.compareTo(timeA);
    });

    return rides;
  }

  void _showRideDetails(MyRideData ride) async {
    showLoader(context);
    final res = await repo.rideDetails(ride.seatSharingRequestId.toString(), fromId:ride.fromId , toId: ride.toId);
    hideLoader();
    if (res.status) {
      context.push(
        RideDetailsScreen(
          ride: res.data,
          from: ride.fromStopName,
          to: ride.toStopName,
          fromId: ride.fromId,
          toId: ride.toId,
          time: ride.departureDateTime,
          price: num.tryParse(ride.price.toString()) ?? 0,
        ),
      );
    } else {
      ShowToastDialog.showToast(res.message);
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    final filteredRides = _filteredRides;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.black,
        title: const Text(
          'My Rides',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search rides by location or seat...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _showClearSearch
                      ? IconButton(
                          onPressed: () {
                            _showClearSearch = false;
                            _searchController.clear();
                            _searchQuery = '';
                            setState(() {});
                          },
                          icon: const Icon(Icons.close, color: Colors.grey))
                      : null,
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _showClearSearch = value.trim().isNotEmpty;
                  });
                },
              ),
            ),
          ),

          ///
          ///
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;
                final color = (RideStatus.values.where((element) => element.displayName == filter).firstOrNull ?? RideStatus.upcoming).color;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: color.withOpacity(0.1),
                    checkmarkColor: color,
                    elevation: isSelected ? 2 : 0,
                    shadowColor: color.withOpacity(0.3),
                    labelStyle: TextStyle(
                      color: isSelected ? color[700] : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? color[300]! : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: filteredRides.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ctr.getMyRidesList();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: filteredRides.length,
                        itemBuilder: (context, index) {
                          return _buildRideCard(filteredRides[index], index);
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(SearchSeatSharingRidesScreen());
        },
        backgroundColor: ConstantColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add_road),
        label: const Text(
          'Book New Ride',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: RefreshIndicator(
        onRefresh: () async {
          await ctr.getMyRidesList();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.car_rental_sharp,
                  size: 80,
                  color: Colors.blue[300],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _searchQuery.isNotEmpty || _selectedFilter != 'All' ? 'No rides found' : 'No rides yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty || _selectedFilter != 'All' ? 'Try adjusting your search or filters' : 'Book your first ride to get started',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_searchQuery.isNotEmpty || _selectedFilter != 'All')
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _selectedFilter = 'All';
                      _searchController.clear();
                      _showClearSearch = false;
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    context.push(SearchSeatSharingRidesScreen());
                  },
                  icon: const Icon(Icons.add_road),
                  label: const Text('Book Your First Ride'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRideCard(MyRideData ride, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _showRideDetails(ride);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///
                  ///
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ride.rideStatusEnum.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: ride.rideStatusEnum.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              ride.rideStatusEnum.icon,
                              size: 14,
                              color: ride.rideStatusEnum.color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              ride.rideStatusEnum.displayName,
                              style: TextStyle(
                                color: ride.rideStatusEnum.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Ride #${ride.seatSharingRequestId}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            formatDateTime(ride.departureTime),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  ///
                  ///
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            // From location
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green[600],
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'FROM',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        ride.fromStopName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            ///
                            ///
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 2,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.green[400]!, Colors.red[400]!],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.grey[300]!,
                                            Colors.grey[200]!,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            ///
                            ///
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.red[600],
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'TO',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        ride.toStopName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      ///
                      ///
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [ride.rideStatusEnum.color.shade50, ride.rideStatusEnum.color.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: ride.rideStatusEnum.color.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.currency_rupee,
                              color: ride.rideStatusEnum.color.shade700,
                              size: 16,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ride.totalPrice,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ride.rideStatusEnum.color.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ride.layoutLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: ride.rideStatusEnum.color.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
