import 'package:zocar/helpers/navigation.dart';
import 'package:zocar/helpers/size_ext.dart';
import 'package:zocar/seat_sharing/controllers/seat_sharing_controller.dart';
import 'package:zocar/seat_sharing/repo/seat_sharing_repo.dart';
import 'package:zocar/seat_sharing/screens/ride_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constant/show_toast_dialog.dart';
import '../../helpers/loader.dart';
import '../../helpers/widget_binding.dart';
import '../models/seat_sharing_rides.dart';
import '../utils/format_date_time.dart';

class RideListScreen extends StatefulWidget {
  final String from;
  final String to;
  final DateTime time;

  const RideListScreen({
    super.key,
    required this.from,
    required this.to,
    required this.time,
  });

  @override
  State<RideListScreen> createState() => _RideListScreenState();
}

class _RideListScreenState extends State<RideListScreen> with TickerProviderStateMixin {
  final repo = SeatSharingRepo();
  final ctr = Get.find<SeatSharingController>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  bool _showClearSearch = false;
  bool _isHeaderExpanded = true;

  final TextEditingController _searchController = TextEditingController();

  // SeatSharingRidesResponse? get seatSharingRidesResponse => _seatSharingRidesResponse;
  // SeatSharingRidesResponse? _seatSharingRidesResponse;
  //
  // List<SeatSharingRideData> get ridesList => seatSharingRidesResponse?.data ?? [];

  late DateTime selectedDate;
  final int totalDays = 7;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.time;
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

    _scrollController.addListener(() {
      final isExpanded = _scrollController.offset < 100;
      if (isExpanded != _isHeaderExpanded) {
        setState(() {
          _isHeaderExpanded = isExpanded;
        });
      }
    });

    widgetBinding((_) async {
      await getAllRides();
    });
  }

  getAllRides() async {
    showLoader(context);
    await ctr.getAllRides(from: widget.from, to: widget.to, time: selectedDate);
    hideLoader();
    // if (res.status) {
    //   _seatSharingRidesResponse = res;
    // } else {
    //   ShowToastDialog.showToast(res.message);
    // }
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<SeatSharingRideData> get _filteredRides {
    List<SeatSharingRideData> rides = ctr.ridesList;

    /// search filter
    if (_searchQuery.isNotEmpty) {
      rides = rides.where((ride) {
        return ride.from.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ride.to.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ride.stops.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    /// sorting by departure time ,newest first
    rides.sort((a, b) {
      final timeA = DateTime.tryParse(a.departureTime) ?? DateTime.now();
      final timeB = DateTime.tryParse(b.departureTime) ?? DateTime.now();
      return timeB.compareTo(timeA);
    });

    return rides;
  }

  List<String> _parseStops(String stopsString) {
    return stopsString.split(',').map((s) => s.trim()).toList();
  }

  List<DateTime> getDateList() {
    return List.generate(totalDays, (index) => widget.time.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final dateList = getDateList();
    final filteredRides = _filteredRides;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom SliverAppBar with collapsible header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.blue.shade50,
            foregroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: AnimatedOpacity(
                opacity: _isHeaderExpanded ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  'Available Rides',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade50,
                      Colors.blue.shade100,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedOpacity(
                          opacity: _isHeaderExpanded ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Rides',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${widget.from} ➜ ${widget.to}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('dd MMM yyyy').format(selectedDate),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.directions_car,
                                        color: Colors.blue,
                                        size: 20,
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
                  ),
                ),
              ),
            ),
          ),

          // Sticky search bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickySearchDelegate(
              child: Container(
                height: 70,
                color: Colors.grey[50],
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10),
                child: Container(
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search rides by location...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      suffixIcon: _showClearSearch
                          ? IconButton(
                              onPressed: () {
                                _showClearSearch = false;
                                _searchController.clear();
                                _searchQuery = '';
                                setState(() {});
                              },
                              icon: Icon(Icons.close, color: Colors.grey[600]),
                            )
                          : null,
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
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
            ),
          ),

          // Collapsible date selector
          SliverAnimatedList(
            initialItemCount: 1,
            itemBuilder: (context, index, animation) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0, -1), end: Offset.zero),
                ),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    height: _isHeaderExpanded ? 90 : 0,
                    child: AnimatedOpacity(
                      opacity: _isHeaderExpanded ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        color: Colors.grey[50],
                        // padding: const EdgeInsets.symmetric(vertical: 5),
                        child: SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            itemCount: dateList.length,
                            separatorBuilder: (_, __) => SizedBox(width: 2.w),
                            itemBuilder: (context, index) {
                              final date = dateList[index];
                              final isSelected = date.day == selectedDate.day && date.month == selectedDate.month && date.year == selectedDate.year;

                              return GestureDetector(
                                onTap: () {
                                  selectedDate = date;
                                  getAllRides();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: [Colors.blue, Colors.blue.shade600],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: isSelected ? null : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? Colors.transparent : Colors.grey.shade200,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      else
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('dd').format(date),
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat('E').format(date),
                                        style: TextStyle(
                                          color: isSelected ? Colors.white70 : Colors.grey[600],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Rides list or empty state
          filteredRides.isEmpty
              ? SliverFillRemaining(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildEmptyState(),
                  ),
                )
              : SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(
                                  (index * 0.1).clamp(0.0, 1.0),
                                  ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                                  curve: Curves.easeOutBack,
                                ),
                              ),
                            ),
                            child: _buildRideCard(filteredRides[index], index),
                          ),
                        );
                      },
                      childCount: filteredRides.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty ? 'No rides found' : 'No rides available',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _searchQuery.isNotEmpty ? 'Try adjusting your search terms or check back later' : 'No rides found for your selected route and date',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            if (_searchQuery.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _searchQuery = '';
                  _showClearSearch = false;
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.blue.shade50,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard(SeatSharingRideData ride, int index) {
    final stops = _parseStops(ride.stops);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _showRideDetails(ride);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price and seats availability row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.1),
                            Colors.green.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            size: 18,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${ride.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '/seat',
                            style: TextStyle(
                              color: Colors.green[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: ride.remaining_seats > 0
                              ? [Colors.indigo.withOpacity(0.1), Colors.indigo.withOpacity(0.05)]
                              : [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.05)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ride.remaining_seats > 0 ? Colors.indigo.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.airline_seat_recline_normal,
                            size: 16,
                            color: ride.remaining_seats > 0 ? Colors.indigo[700] : Colors.orange[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            (ride.remaining_seats > 0) ? '${ride.remaining_seats.toInt()}/${ride.total_seats.toInt()}' : "FULL",
                            style: TextStyle(
                              color: ride.remaining_seats > 0 ? Colors.indigo[700] : Colors.orange[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (ride.remaining_seats > 0) ...[
                            const SizedBox(width: 2),
                            Text(
                              'left',
                              style: TextStyle(
                                color: ride.remaining_seats > 0 ? Colors.indigo[600] : Colors.orange[600],
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // From location
                          Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green, Colors.green.shade600],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ride.from,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Stops indicator
                          if (stops.length > 2) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  width: 14,
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 2,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.grey[300]!,
                                          Colors.grey[200]!,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${stops.length - 2} stop${stops.length - 2 == 1 ? '' : 's'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 6),

                          // To location
                          Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.red, Colors.red.shade600],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ride.to,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Time container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[100]!, Colors.blue[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            color: Colors.blue[600],
                            size: 22,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatDateTime(ride.departureTime),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Stops chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: stops.take(6).map((stop) {
                      // final stopIndex = stops.indexOf(stop);
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          stop,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildRideCard(SeatSharingRideData ride, int index) {
  //   final stops = _parseStops(ride.stops);
  //
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 16),
  //     child: Card(
  //       elevation: 2,
  //       color: Colors.white,
  //       shadowColor: Colors.black.withOpacity(0.08),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       child: InkWell(
  //         borderRadius: BorderRadius.circular(20),
  //         onTap: () {
  //           _showRideDetails(ride);
  //         },
  //         child: Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 14,
  //                       vertical: 8,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       gradient: LinearGradient(
  //                         colors: [
  //                           (ride.rideStatusEnum.color).withOpacity(0.1),
  //                           (ride.rideStatusEnum.color).withOpacity(0.05),
  //                         ],
  //                       ),
  //                       borderRadius: BorderRadius.circular(25),
  //                       border: Border.all(
  //                         color: (ride.rideStatusEnum.color).withOpacity(0.2),
  //                         width: 1,
  //                       ),
  //                     ),
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Icon(
  //                           (ride.rideStatusEnum.icon),
  //                           size: 16,
  //                           color: (ride.rideStatusEnum.color),
  //                         ),
  //                         const SizedBox(width: 6),
  //                         Text(
  //                           ride.rideStatusEnum.displayName,
  //                           style: TextStyle(
  //                             color: (ride.rideStatusEnum.color),
  //                             fontWeight: FontWeight.w600,
  //                             fontSize: 12,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //                     decoration: BoxDecoration(
  //                       color: Colors.grey[100],
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     child: Text(
  //                       'ID: ${ride.id}',
  //                       style: TextStyle(
  //                         color: Colors.grey[600],
  //                         fontSize: 11,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //
  //               const SizedBox(height: 20),
  //
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         // From location
  //                         Row(
  //                           children: [
  //                             Container(
  //                               width: 14,
  //                               height: 14,
  //                               decoration: BoxDecoration(
  //                                 gradient: LinearGradient(
  //                                   colors: [Colors.green, Colors.green.shade600],
  //                                 ),
  //                                 shape: BoxShape.circle,
  //                                 boxShadow: [
  //                                   BoxShadow(
  //                                     color: Colors.green.withOpacity(0.3),
  //                                     blurRadius: 4,
  //                                     offset: const Offset(0, 1),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                             const SizedBox(width: 12),
  //                             Expanded(
  //                               child: Text(
  //                                 ride.from,
  //                                 style: const TextStyle(
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.bold,
  //                                   color: Colors.black87,
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //
  //                         // Stops indicator
  //                         if (stops.length > 2) ...[
  //                           const SizedBox(height: 6),
  //                           Row(
  //                             children: [
  //                               Container(
  //                                 width: 14,
  //                                 alignment: Alignment.center,
  //                                 child: Container(
  //                                   width: 2,
  //                                   height: 24,
  //                                   decoration: BoxDecoration(
  //                                     gradient: LinearGradient(
  //                                       begin: Alignment.topCenter,
  //                                       end: Alignment.bottomCenter,
  //                                       colors: [
  //                                         Colors.grey[300]!,
  //                                         Colors.grey[200]!,
  //                                       ],
  //                                     ),
  //                                     borderRadius: BorderRadius.circular(1),
  //                                   ),
  //                                 ),
  //                               ),
  //                               const SizedBox(width: 12),
  //                               Expanded(
  //                                 child: Text(
  //                                   '${stops.length - 2} stop${stops.length - 2 == 1 ? '' : 's'}',
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     color: Colors.grey[600],
  //                                     fontWeight: FontWeight.w500,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                         const SizedBox(height: 6),
  //
  //                         // To location
  //                         Row(
  //                           children: [
  //                             Container(
  //                               width: 14,
  //                               height: 14,
  //                               decoration: BoxDecoration(
  //                                 gradient: LinearGradient(
  //                                   colors: [Colors.red, Colors.red.shade600],
  //                                 ),
  //                                 shape: BoxShape.circle,
  //                                 boxShadow: [
  //                                   BoxShadow(
  //                                     color: Colors.red.withOpacity(0.3),
  //                                     blurRadius: 4,
  //                                     offset: const Offset(0, 1),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                             const SizedBox(width: 12),
  //                             Expanded(
  //                               child: Text(
  //                                 ride.to,
  //                                 style: const TextStyle(
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.bold,
  //                                   color: Colors.black87,
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //
  //                   // Time container
  //                   Container(
  //                     padding: const EdgeInsets.all(16),
  //                     decoration: BoxDecoration(
  //                       gradient: LinearGradient(
  //                         colors: [Colors.blue[100]!, Colors.blue[50]!],
  //                         begin: Alignment.topLeft,
  //                         end: Alignment.bottomRight,
  //                       ),
  //                       borderRadius: BorderRadius.circular(16),
  //                       border: Border.all(
  //                         color: Colors.blue.withOpacity(0.1),
  //                       ),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.blue.withOpacity(0.05),
  //                           blurRadius: 4,
  //                           offset: const Offset(0, 2),
  //                         ),
  //                       ],
  //                     ),
  //                     child: Column(
  //                       children: [
  //                         Icon(
  //                           Icons.schedule_rounded,
  //                           color: Colors.blue[600],
  //                           size: 22,
  //                         ),
  //                         const SizedBox(height: 6),
  //                         Text(
  //                           formatDateTime(ride.departureTime),
  //                           style: TextStyle(
  //                             fontSize: 12,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.blue[700],
  //                           ),
  //                           textAlign: TextAlign.center,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //
  //               const SizedBox(height: 20),
  //
  //               // Stops chips
  //               SingleChildScrollView(
  //                 scrollDirection: Axis.horizontal,
  //                 child: Row(
  //                   children: stops.take(6).map((stop) {
  //                     final stopIndex = stops.indexOf(stop);
  //                     return Container(
  //                       margin: const EdgeInsets.only(right: 8),
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 12,
  //                         vertical: 6,
  //                       ),
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey[50],
  //                         border: Border.all(color: Colors.grey[200]!),
  //                         borderRadius: BorderRadius.circular(20),
  //                       ),
  //                       child: Text(
  //                         stop,
  //                         style: TextStyle(
  //                           fontSize: 12,
  //                           color: Colors.grey[700],
  //                           fontWeight: FontWeight.w500,
  //                         ),
  //                       ),
  //                     );
  //                   }).toList(),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _showRideDetails(SeatSharingRideData ride) async {
    showLoader(context);
    final res = await repo.rideDetails(
      ride.id.toString(),
      fromId: ride.fromId,
      toId: ride.toId,
    );
    hideLoader();
    if (res.status) {
      context.push(RideDetailsScreen(
        ride: res.data,
        from: widget.from,
        to: widget.to,
        time: selectedDate,
        price: ride.price,
        fromId: ride.fromId,
        toId: ride.toId,
      ));
    } else {
      ShowToastDialog.showToast(res.message);
    }
    return;
  }
}

// Custom SliverPersistentHeaderDelegate for sticky search
class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickySearchDelegate({required this.child});

  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 70;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

// import 'package:zocar/helpers/navigation.dart';
// import 'package:zocar/helpers/size_ext.dart';
// import 'package:zocar/seat_sharing/repo/seat_sharing_repo.dart';
// import 'package:zocar/seat_sharing/screens/ride_details_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import '../../constant/show_toast_dialog.dart';
// import '../../helpers/loader.dart';
// import '../../helpers/widget_binding.dart';
// import '../models/seat_sharing_rides.dart';
// import '../utils/format_date_time.dart';
//
// class RideListScreen extends StatefulWidget {
//   final String from;
//   final String to;
//   final DateTime time;
//
//   const RideListScreen({
//     super.key,
//     required this.from,
//     required this.to,
//     required this.time,
//   });
//
//   @override
//   State<RideListScreen> createState() => _RideListScreenState();
// }
//
// class _RideListScreenState extends State<RideListScreen> with TickerProviderStateMixin {
//   final repo = SeatSharingRepo();
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   String _searchQuery = '';
//   bool _showClearSearch = false;
//
//   final TextEditingController _searchController = TextEditingController();
//
//   SeatSharingRidesResponse? get seatSharingRidesResponse => _seatSharingRidesResponse;
//   SeatSharingRidesResponse? _seatSharingRidesResponse;
//
//   List<SeatSharingRideData> get ridesList => seatSharingRidesResponse?.data ?? [];
//
//   late DateTime selectedDate;
//   final int totalDays = 7;
//
//   @override
//   void initState() {
//     super.initState();
//     selectedDate = widget.time;
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//     _animationController.forward();
//     widgetBinding((_) async {
//       await getAllRides();
//     });
//   }
//
//   getAllRides() async {
//     showLoader(context);
//     final res = await repo.seatSharingRides(from: widget.from, to: widget.to, time: widget.time);
//     hideLoader();
//     if (res.status) {
//       _seatSharingRidesResponse = res;
//     } else {
//       ShowToastDialog.showToast(res.message);
//     }
//     setState(() {});
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   List<SeatSharingRideData> get _filteredRides {
//     List<SeatSharingRideData> rides = ridesList;
//
//     /// search filter
//     if (_searchQuery.isNotEmpty) {
//       rides = rides.where((ride) {
//         return ride.from.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//             ride.to.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//             ride.stops.toLowerCase().contains(_searchQuery.toLowerCase());
//       }).toList();
//     }
//
//     /// sorting by departure time ,newest first
//     rides.sort((a, b) {
//       final timeA = DateTime.tryParse(a.departureTime) ?? DateTime.now();
//       final timeB = DateTime.tryParse(b.departureTime) ?? DateTime.now();
//       return timeB.compareTo(timeA);
//     });
//
//     return rides;
//   }
//
//   List<String> _parseStops(String stopsString) {
//     return stopsString.split(',').map((s) => s.trim()).toList();
//   }
//
//   List<DateTime> getDateList() {
//     return List.generate(totalDays, (index) => widget.time.add(Duration(days: index)));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dateList = getDateList();
//     final filteredRides = _filteredRides;
//
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         backgroundColor: Colors.grey[50],
//         foregroundColor: Colors.black,
//         title: const Text(
//           'Available Rides',
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 17,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//
//           // From - To - Date
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 5,
//                   offset: const Offset(0, 3),
//                 )
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("${widget.from} ➜ ${widget.to}",
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 4),
//                 Text(
//                   "Selected Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}",
//                   style: TextStyle(color: Colors.grey[700]),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 10),
//
//           // Horizontal Date Selector
//           SizedBox(
//             height: 80,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               itemCount: dateList.length,
//               separatorBuilder: (_, __) => const SizedBox(width: 8),
//               itemBuilder: (context, index) {
//                 final date = dateList[index];
//                 final isSelected = date.day == selectedDate.day &&
//                     date.month == selectedDate.month &&
//                     date.year == selectedDate.year;
//
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedDate = date;
//                     });
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: isSelected ? Colors.blueAccent : Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
//                       ),
//                       boxShadow: [
//                         if (isSelected)
//                           const BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 4,
//                             offset: Offset(0, 2),
//                           )
//                       ],
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           DateFormat('dd').format(date),
//                           style: TextStyle(
//                             color: isSelected ? Colors.white : Colors.black,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         Text(
//                           DateFormat('E').format(date), // Mon, Tue...
//                           style: TextStyle(
//                             color: isSelected ? Colors.white70 : Colors.grey,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           if (ridesList.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: 'Search rides by location...',
//                     prefixIcon: Icon(Icons.search),
//                     suffixIcon: _showClearSearch
//                         ? IconButton(
//                             onPressed: () {
//                               _showClearSearch = false;
//                               _searchController.clear();
//                               _searchQuery = '';
//                               setState(() {});
//                             },
//                             icon: Icon(Icons.close))
//                         : null,
//                     hintStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey),
//                     border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade100, width: 0.5)),
//                     enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade100, width: 0.5)),
//                     focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.indigo.shade200, width: 0.8)),
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 14,
//                     ),
//                   ),
//                   onTapOutside: (event) {
//                     FocusManager.instance.primaryFocus?.unfocus();
//                   },
//                   onChanged: (value) {
//                     setState(() {
//                       _searchQuery = value;
//                       _showClearSearch = value.trim().isNotEmpty;
//                     });
//                   },
//                 ),
//               ),
//             ),
//           Expanded(
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: filteredRides.isEmpty
//                   ? _buildEmptyState()
//                   : RefreshIndicator(
//                       onRefresh: () async {
//                         await getAllRides();
//                       },
//                       child: ListView.builder(
//                         padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 8.h),
//                         itemCount: filteredRides.length,
//                         itemBuilder: (context, index) {
//                           return _buildRideCard(filteredRides[index], index);
//                         },
//                       ),
//                     ),
//             ),
//           ),
//         ],
//       ),
//       // floatingActionButton: FloatingActionButton.extended(
//       //   onPressed: () {
//       //     context.push(SeatLayoutScreen());
//       //   },
//       //   backgroundColor: Colors.blue,
//       //   foregroundColor: Colors.white,
//       //   icon: const Icon(Icons.add),
//       //   label: const Text('New Ride'),
//       // ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.directions_car_outlined,
//             size: 80,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             _searchQuery.isNotEmpty ? 'No rides found' : 'No rides available',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _searchQuery.isNotEmpty ? 'Try adjusting your search' : 'Search your nearest city or town',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[500],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRideCard(SeatSharingRideData ride, int index) {
//     final stops = _parseStops(ride.stops);
//
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 300 + (index * 100)),
//       curve: Curves.easeOutBack,
//       margin: EdgeInsets.only(bottom: 1.h),
//       child: Card(
//         elevation: 2,
//         color: Colors.white,
//         shadowColor: Colors.black26,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16),
//           onTap: () {
//             _showRideDetails(ride);
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: (ride.rideStatusEnum.color).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             (ride.rideStatusEnum.icon),
//                             size: 16,
//                             color: (ride.rideStatusEnum.color),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             ride.rideStatusEnum.displayName,
//                             style: TextStyle(
//                               color: (ride.rideStatusEnum.color),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Text(
//                       'ID: ${ride.id}',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 ///
//                 ///
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           ///
//                           ///
//                           Row(
//                             children: [
//                               Container(
//                                 width: 12,
//                                 height: 12,
//                                 decoration: const BoxDecoration(
//                                   color: Colors.green,
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   ride.from,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           ///
//                           ///
//                           if (stops.length > 2) ...[
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Container(
//                                   width: 12,
//                                   alignment: Alignment.center,
//                                   child: Container(
//                                     width: 2,
//                                     height: 20,
//                                     color: Colors.grey[300],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     '${stops.length - 2} stops',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                           const SizedBox(height: 4),
//
//                           ///
//                           ///
//                           Row(
//                             children: [
//                               Container(
//                                 width: 12,
//                                 height: 12,
//                                 decoration: const BoxDecoration(
//                                   color: Colors.red,
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   ride.to,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     ///
//                     ///
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           const Icon(
//                             Icons.schedule,
//                             color: Colors.blue,
//                             size: 20,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             formatDateTime(ride.departureTime),
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 ///
//                 ///
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           children: stops.take(4).map((stop) {
//                             final isLast = stop == stops.last;
//                             return Row(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 4,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey[100],
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     stop,
//                                     style: const TextStyle(fontSize: 12),
//                                   ),
//                                 ),
//                                 if (!isLast) const SizedBox(width: 4),
//                               ],
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ),
//
//                     // Action buttons
//                     // Row(
//                     //   children: [
//                     //     IconButton(
//                     //       onPressed: () => _shareRide(ride),
//                     //       icon: const Icon(Icons.share, size: 20),
//                     //       tooltip: 'Share',
//                     //     ),
//                     //     IconButton(
//                     //       onPressed: () => _showRideDetails(ride),
//                     //       icon: const Icon(Icons.info_outline, size: 20),
//                     //       tooltip: 'Details',
//                     //     ),
//                     //   ],
//                     // ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showRideDetails(SeatSharingRideData ride) async {
//     showLoader(context);
//     final res = await repo.rideDetails(ride.id.toString());
//     hideLoader();
//     if (res.status) {
//       context.push(RideDetailsScreen(ride: res.data));
//     } else {
//       ShowToastDialog.showToast(res.message);
//     }
//     return;
//   }
// }
//
// ///
// ///
// // showModalBottomSheet(
// //   context: context,
// //   backgroundColor: Colors.transparent,
// //   isScrollControlled: true,
// //   builder: (context) => DraggableScrollableSheet(
// //     initialChildSize: 0.7,
// //     minChildSize: 0.5,
// //     maxChildSize: 0.9,
// //     builder: (context, scrollController) {
// //       return Container(
// //         decoration: const BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //         ),
// //         child: Column(
// //           children: [
// //             // Handle bar
// //             Container(
// //               margin: const EdgeInsets.only(top: 12),
// //               width: 40,
// //               height: 4,
// //               decoration: BoxDecoration(
// //                 color: Colors.grey[300],
// //                 borderRadius: BorderRadius.circular(2),
// //               ),
// //             ),
// //
// //             Expanded(
// //               child: SingleChildScrollView(
// //                 controller: scrollController,
// //                 padding: const EdgeInsets.all(20),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     // Header
// //                     Row(
// //                       children: [
// //                         Container(
// //                           padding: const EdgeInsets.symmetric(
// //                             horizontal: 12,
// //                             vertical: 6,
// //                           ),
// //                           decoration: BoxDecoration(
// //                             color: _getStatusColor(ride.rideStatusName).withOpacity(0.1),
// //                             borderRadius: BorderRadius.circular(20),
// //                           ),
// //                           child: Row(
// //                             mainAxisSize: MainAxisSize.min,
// //                             children: [
// //                               Icon(
// //                                 _getStatusIcon(ride.rideStatusName),
// //                                 size: 16,
// //                                 color: _getStatusColor(ride.rideStatusName),
// //                               ),
// //                               const SizedBox(width: 4),
// //                               Text(
// //                                 ride.rideStatusName,
// //                                 style: TextStyle(
// //                                   color: _getStatusColor(ride.rideStatusName),
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                         const Spacer(),
// //                         Text(
// //                           'Ride #${ride.id}',
// //                           style: const TextStyle(
// //                             fontSize: 18,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //
// //                     const SizedBox(height: 24),
// //
// //                     // Route details
// //                     const Text(
// //                       'Route Details',
// //                       style: TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 16),
// //
// //                     ..._parseStops(ride.stops).asMap().entries.map((entry) {
// //                       final index = entry.key;
// //                       final stop = entry.value;
// //                       final isFirst = index == 0;
// //                       final isLast = index == _parseStops(ride.stops).length - 1;
// //
// //                       return Row(
// //                         children: [
// //                           Column(
// //                             children: [
// //                               Container(
// //                                 width: 16,
// //                                 height: 16,
// //                                 decoration: BoxDecoration(
// //                                   color: isFirst ? Colors.green : (isLast ? Colors.red : Colors.blue),
// //                                   shape: BoxShape.circle,
// //                                 ),
// //                               ),
// //                               if (!isLast)
// //                                 Container(
// //                                   width: 2,
// //                                   height: 30,
// //                                   color: Colors.grey[300],
// //                                 ),
// //                             ],
// //                           ),
// //                           const SizedBox(width: 12),
// //                           Expanded(
// //                             child: Container(
// //                               padding: const EdgeInsets.symmetric(vertical: 8),
// //                               child: Text(
// //                                 stop,
// //                                 style: TextStyle(
// //                                   fontSize: 16,
// //                                   fontWeight: isFirst || isLast ? FontWeight.bold : FontWeight.normal,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       );
// //                     }).toList(),
// //
// //                     const SizedBox(height: 24),
// //
// //                     // Time details
// //                     Container(
// //                       padding: const EdgeInsets.all(16),
// //                       decoration: BoxDecoration(
// //                         color: Colors.blue[50],
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       child: Row(
// //                         children: [
// //                           const Icon(Icons.schedule, color: Colors.blue),
// //                           const SizedBox(width: 12),
// //                           Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               const Text(
// //                                 'Departure Time',
// //                                 style: TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.blue,
// //                                 ),
// //                               ),
// //                               Text(
// //                                 _formatDateTime(ride.departureTime),
// //                                 style: const TextStyle(fontSize: 16),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //
// //                     const SizedBox(height: 16),
// //
// //                     // Additional info
// //                     Container(
// //                       padding: const EdgeInsets.all(16),
// //                       decoration: BoxDecoration(
// //                         color: Colors.grey[50],
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           const Text(
// //                             'Additional Information',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 16,
// //                             ),
// //                           ),
// //                           const SizedBox(height: 12),
// //                           _buildInfoRow('Driver ID', ride.driverId.toString()),
// //                           _buildInfoRow('Created', DateFormat('MMM dd, yyyy').format(DateTime.parse(ride.createdAt))),
// //                           _buildInfoRow('Last Updated', DateFormat('MMM dd, yyyy').format(DateTime.parse(ride.updatedAt))),
// //                         ],
// //                       ),
// //                     ),
// //
// //                     const SizedBox(height: 24),
// //
// //                     // Action buttons
// //                     Row(
// //                       children: [
// //                         Expanded(
// //                           child: ElevatedButton.icon(
// //                             onPressed: () => _shareRide(ride),
// //                             icon: const Icon(Icons.share),
// //                             label: const Text('Share Ride'),
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: Colors.blue,
// //                               foregroundColor: Colors.white,
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(12),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 12),
// //                         Expanded(
// //                           child: OutlinedButton.icon(
// //                             onPressed: () {
// //                               Navigator.pop(context);
// //                               // Navigate to edit ride
// //                             },
// //                             icon: const Icon(Icons.edit),
// //                             label: const Text('Edit Ride'),
// //                             style: OutlinedButton.styleFrom(
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(12),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     },
// //   ),
// // );
// ///
// ///
