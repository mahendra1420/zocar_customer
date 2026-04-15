import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/helpers/calculate_30_percent_ext.dart';
import 'package:zocar/helpers/devlog.dart';
import 'package:zocar/helpers/payment_gateway.dart';
import 'package:zocar/helpers/size_ext.dart';
import 'package:zocar/helpers/url_launcher_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../helpers/loader.dart';
import '../../utils/preferences.dart';
import '../controllers/seat_sharing_controller.dart';
import '../models/ride_details.dart';
import '../models/seat.dart';
import '../models/stop_point.dart';
import '../repo/seat_sharing_repo.dart';
import '../utils/format_date_time.dart';
import '../utils/group_seats_by_row.dart';
import '../utils/ride_status_enum.dart';
import '../widgets/seat_row.dart';

///
///
/// NOTE: this is seat sharing ride details screen (not normal ride details)
///
///
class RideDetailsScreen extends StatefulWidget {
  final String from;
  final String fromId;
  final String to;
  final String toId;
  final DateTime time;
  final num price;
  final RideDetailsData ride;

  const RideDetailsScreen({super.key, required this.ride, required this.from, required this.to, required this.time, required this.price, required this.fromId, required this.toId});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> with TickerProviderStateMixin {
  final repo = SeatSharingRepo();

  final ctr = Get.find<SeatSharingController>();
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final isCollapsed = _scrollController.hasClients && _scrollController.offset > (200 - kToolbarHeight); // tweak threshold
    if (isCollapsed != _isAppBarCollapsed) {
      setState(() {
        _isAppBarCollapsed = isCollapsed;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // String _getStopName(String stopId) {
  //   final stop = widget.ride.stops.where((s) => s.stopId == stopId).firstOrNull;
  //   return stop?.name ?? stopId;
  // }

  int _getAvailableSeats() {
    return widget.ride.seats.where((seat) => !seat.isBooked && !seat.isDriver && !seat.isSelected).length;
  }

  int _getAvailableSeatsWithoutSelected() {
    return widget.ride.seats.where((seat) => !seat.isBooked && !seat.isDriver).length;
  }

  int _getBookedSeats() {
    return widget.ride.seats.where((seat) => seat.isBooked).length;
  }

  int _getSelectedSeats() {
    return widget.ride.seats.where((seat) => seat.isSelected).length;
  }

  int _getUserBookedSeats() {
    final userId = Preferences.getInt(Preferences.userId);
    return widget.ride.seats.where((seat) => seat.bookedBy?.toString() == userId.toString()).length;
  }

  int get userId => Preferences.getInt(Preferences.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: ScrollbarTheme(
        data: ScrollbarThemeData(thumbColor: WidgetStatePropertyAll(widget.ride.rideStatusEnum.color), crossAxisMargin: 1, radius: Radius.circular(8)),
        child: Scrollbar(
          key: ValueKey("main_scrollbar_for_details"),
          thumbVisibility: true,
          controller: _scrollController,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Custom App Bar with gradient
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                actions: [
                  if (_isAppBarCollapsed)
                    IconButton(
                        onPressed: () {
                          _scrollController.animateTo(0, duration: 500.milliseconds, curve: Curves.easeInSine);
                        },
                        icon: Icon(Icons.keyboard_arrow_down_outlined)),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (widget.ride.rideStatusEnum.color),
                          (widget.ride.rideStatusEnum.color).withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Ride #${widget.ride.id}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        (widget.ride.rideStatusEnum.icon),
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.ride.rideStatusEnum.displayName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.schedule, color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  formatDateTime(widget.ride.departureTime),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.route, color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${widget.ride.from} → ${widget.ride.to}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
              ),

              ///
              ///
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade50,
                            Colors.white,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Route Section - Left Side
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // From Location
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade600,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Your pickup location',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              widget.from,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Connector Line
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 3.5),
                                        Container(
                                          width: 1,
                                          height: 12,
                                          color: Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // To Location
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade600,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Your drop location',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              widget.to,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Price Section - Right Side
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.currency_rupee,
                                      color: Colors.green.shade700,
                                      size: 18,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.price.toStringAsFixed(0),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    Text(
                                      'per seat',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
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

              SliverToBoxAdapter(
                child: Builder(builder: (context) {
                  final yourSeats = widget.ride.seats.where((element) => element.bookedBy?.toString() == userId.toString());
                  final yourAdvancePaidSeats = yourSeats.where((element) => element.advancePayment > 0);
                  final yourAdvancePaid = yourAdvancePaidSeats.fold(0.0, (prev, e) => prev + e.advancePayment);
                  if (yourAdvancePaid <= 0) return SizedBox();
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade50,
                              Colors.white,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.currency_rupee,
                                color: Colors.green.shade700,
                                size: 15,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade800,
                                      height: 1.0,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'You paid ',
                                      ),
                                      TextSpan(
                                        text: yourAdvancePaid.toStringAsFixed(0),
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ' advance for seat(s): ',
                                      ),
                                      TextSpan(
                                        text: yourAdvancePaidSeats.map((e) => e.label).join(", "),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              ///
              ///
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    indicatorWeight: 3,
                    dividerHeight: 0,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(text: 'Seats', icon: Icon(Icons.event_seat, size: 20)),
                      Tab(text: 'Route', icon: Icon(Icons.route, size: 20)),
                      // Tab(text: 'Pricing', icon: Icon(Icons.currency_rupee, size: 20)),
                      Tab(text: 'Details', icon: Icon(Icons.info_outline, size: 20)),
                    ],
                  ),
                ),
              ),

              ///
              ///
              SliverFillRemaining(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSeatsTab(),
                      _buildRouteTab(),
                      // _buildPricingTab(),
                      _buildDetailsTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      ///
      ///
      // floatingActionButton: (RideStatus.notStarted == widget.ride.rideStatusEnum && widget.ride.departureDateTime.difference(DateTime.now()).inMinutes > 5)
      //     ? FloatingActionButton(
      //         heroTag: "edit",
      //         onPressed: () {
      //           context.push(SeatLayoutScreen(rideDetailsData: widget.ride));
      //         },
      //         backgroundColor: Colors.teal,
      //         child: const Icon(Icons.edit, color: Colors.white),
      //       )
      //     : null,

      ///
      ///
      bottomNavigationBar: switch (widget.ride.rideStatusEnum) {
        RideStatus.upcoming => buildNotStartedUpcoming(context),
        RideStatus.notStarted => buildNotStartedUpcoming(context),
        RideStatus.started => SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 6,
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: buildElevatedButton(
                      context,
                      icon: Icons.call,
                      foregroundColor: Colors.green,
                      color: Colors.green.withOpacity(0.1),
                      label: "Call Driver",
                      elevation: 0,
                      onTap: () async {
                        final mobile = widget.ride.driverDetail.phone;
                        if (mobile.trim().isEmpty) {
                          showToast("Mobile number not available.!", position: EasyLoadingToastPosition.bottom);
                          return;
                        }
                        try {
                          UrlLauncher.launchMobile(mobile, prefix: "+91");
                        } catch (e) {
                          devlogError("error on call driver");
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        _ => null,
      },
    );
  }

  SafeArea buildNotStartedUpcoming(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 6,
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: buildElevatedButton(
                context,
                icon: Icons.call,
                foregroundColor: Colors.green,
                color: Colors.green.withOpacity(0.1),
                label: "Call Driver",
                elevation: 0,
                onTap: () async {
                  final mobile = widget.ride.driverDetail.phone;
                  if (mobile.trim().isEmpty) {
                    showToast("Mobile number not available.!", position: EasyLoadingToastPosition.bottom);
                    return;
                  }
                  try {
                    UrlLauncher.launchMobile(mobile, prefix: "+91");
                  } catch (e) {
                    devlogError("error on call driver");
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: buildElevatedButton(context,
                  label: (_getAvailableSeatsWithoutSelected() <= 0) ? "No Seats" : "Book Seats",
                  icon: (_getAvailableSeatsWithoutSelected() <= 0) ? Icons.cancel_presentation : Icons.done_outline,
                  color: _getAvailableSeatsWithoutSelected() <= 0 ? Colors.grey : Colors.indigo,
                  onTap: onBookSeatsButtonTap
                  // onTap: () async {
                  //   if (_getAvailableSeatsWithoutSelected() <= 0) {
                  //     showToast("No available seats. Choose another ride.!", position: EasyLoadingToastPosition.bottom);
                  //     return;
                  //   }
                  //   if (_getSelectedSeats() <= 0) {
                  //     showToast("Select seats to book", position: EasyLoadingToastPosition.bottom);
                  //     return;
                  //   }
                  //
                  //   final selectedSeats = widget.ride.seats.where((seat) => seat.isSelected).toList();
                  //   final seatLabels = selectedSeats.map((s) => s.label).join(', ');
                  //
                  //   final payAdvanceEnabled = Preferences.getInitialPaymentPercentage() > 0;
                  //   final payAdvancePrecentage = Preferences.getInitialPaymentPercentage();
                  //   devlog("payad : $payAdvancePrecentage");
                  //   final double totalAmount = (widget.price * selectedSeats.length).toDouble();
                  //   final confirm = await showDialog<bool>(
                  //     context: context,
                  //     builder: (context) => AlertDialog(
                  //       title: const Text("Confirm Booking"),
                  //       content: Text(
                  //           "Are you sure you want to book the following seats?\n\n$seatLabels${payAdvanceEnabled ? "\n\nPay Advance : ${totalAmount.percent30} (${payAdvancePrecentage}% of ${totalAmount.round()})" : ""}"),
                  //       actions: [
                  //         TextButton(
                  //           onPressed: () => Navigator.pop(context, false),
                  //           child: const Text("Cancel"),
                  //         ),
                  //         ElevatedButton(
                  //           onPressed: () => Navigator.pop(context, true),
                  //           child: Text(payAdvanceEnabled ? "Pay Advance" : "Confirm"),
                  //         ),
                  //       ],
                  //     ),
                  //   );
                  //
                  //   if (confirm != true) return;
                  //
                  //   if (payAdvanceEnabled) {
                  //     PaymentGateway.instance.openRazorPay(
                  //         amount: totalAmount,
                  //         onSuccess: (response) async {
                  //           await bookSeatsOfRide(selectedSeats: selectedSeats, totalAmount: totalAmount, response: response);
                  //         });
                  //   } else {
                  //     await bookSeatsOfRide(selectedSeats: selectedSeats);
                  //   }
                  // },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Add these variables at the top of your class
  StopPoint? selectedPickupStopPoint;
  StopPoint? selectedDropStopPoint;

// Your existing booking logic with bottom sheet integration
  void onBookSeatsButtonTap() async {
    if (_getAvailableSeatsWithoutSelected() <= 0) {
      showToast("No available seats. Choose another ride.!", position: EasyLoadingToastPosition.bottom);
      return;
    }
    if (_getSelectedSeats() <= 0) {
      showToast("Select seats to book", position: EasyLoadingToastPosition.bottom);
      return;
    }

    final selectedSeats = widget.ride.seats.where((seat) => seat.isSelected).toList();

    // Show bottom sheet for stop point selection
    final stopPointsResult = await _showStopPointSelectionBottomSheet();
    if (stopPointsResult == null) return; // User cancelled

    selectedPickupStopPoint = stopPointsResult['pickup'];
    selectedDropStopPoint = stopPointsResult['drop'];

    final seatLabels = selectedSeats.map((s) => s.label).join(', ');

    // final payAdvanceEnabled = Preferences.getInitialPaymentPercentage() > 0;
    // final payAdvancePrecentage = Preferences.getInitialPaymentPercentage();
    // devlog("payad : $payAdvancePrecentage");
    final double totalAmount = (widget.price * selectedSeats.length).toDouble();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Booking"),
        content: Text(
            "Are you sure you want to book the following seats?"
                "\n\n$seatLabels\n\n"
                "Pickup: ${selectedPickupStopPoint?.name}\n"
                "Drop: ${selectedDropStopPoint?.name}"
                // "${payAdvanceEnabled ? "\n\nPay Advance : ${totalAmount.percent30} (${payAdvancePrecentage}% of ${totalAmount.round()})" : ""}"
                ""),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Confirm"),
            // child: Text(payAdvanceEnabled ? "Pay Advance" : "Confirm"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // if (payAdvanceEnabled) {
    //   PaymentGateway.instance.openRazorPay(
    //       amount: totalAmount,
    //       onSuccess: (response) async {
    //         await bookSeatsOfRide(
    //           selectedSeats: selectedSeats,
    //           totalAmount: totalAmount,
    //           response: response,
    //           pickupStopPoint: selectedPickupStopPoint,
    //           dropStopPoint: selectedDropStopPoint,
    //         );
    //       });
    // } else {
      await bookSeatsOfRide(
        selectedSeats: selectedSeats,
        pickupStopPoint: selectedPickupStopPoint,
        dropStopPoint: selectedDropStopPoint,
      );
    // }
  }

// Bottom sheet for stop point selection
  Future<Map<String, StopPoint?>?> _showStopPointSelectionBottomSheet() async {
    StopPoint? tempPickupStopPoint = selectedPickupStopPoint;
    StopPoint? tempDropStopPoint = selectedDropStopPoint;

    // Get all stop points from all stops
    List<StopPoint> pickupStopPoints = [];
    List<StopPoint> dropStopPoints = [];
    for (var stop in widget.ride.stops.where((element) => element.id == widget.fromId)) {
      pickupStopPoints.addAll(stop.stopPoints.where((element) => element.type != StopPointType.drop));
    }

    for (var stop in widget.ride.stops.where((element) => element.id == widget.toId)) {
      dropStopPoints.addAll(stop.stopPoints.where((element) => element.type != StopPointType.pickup));
    }

    if (pickupStopPoints.isEmpty) {
      showToast("No pickup points available", position: EasyLoadingToastPosition.bottom);
      return null;
    }
    if (dropStopPoints.isEmpty) {
      showToast("No pickup points available", position: EasyLoadingToastPosition.bottom);
      return null;
    }

    return await showModalBottomSheet<Map<String, StopPoint?>>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Select Pickup & Drop Points',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pickup Section
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Pickup Point',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tempPickupStopPoint?.name ?? 'Select pickup point',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: tempPickupStopPoint != null ? Colors.black87 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Drop Section
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Drop Point',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tempDropStopPoint?.name ?? 'Select drop point',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: tempDropStopPoint != null ? Colors.black87 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stop Points List

                  Expanded(
                    child: ListView(
                      children: [
                        const Text(
                          'Available Pickup Points',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: pickupStopPoints.length,
                          itemBuilder: (context, index) {
                            final stopPoint = pickupStopPoints[index];
                            final isPickupSelected = tempPickupStopPoint?.id == stopPoint.id;

                            return InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setState(() {
                                  tempPickupStopPoint = stopPoint;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: (isPickupSelected) ? (Colors.green) : Colors.grey.withOpacity(0.3),
                                    width: (isPickupSelected) ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(
                                    stopPoint.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${stopPoint.latitude}, ${stopPoint.longitude}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isPickupSelected ? Colors.green : Colors.green[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Pickup',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isPickupSelected ? Colors.white : Colors.green[800],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Available Drop Points',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: dropStopPoints.length,
                          itemBuilder: (context, index) {
                            final stopPoint = dropStopPoints[index];
                            final isDropSelected = tempDropStopPoint?.id == stopPoint.id;

                            return InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setState(() {
                                  tempDropStopPoint = stopPoint;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: (isDropSelected) ? (Colors.red) : Colors.grey.withOpacity(0.3),
                                    width: (isDropSelected) ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(
                                    stopPoint.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${stopPoint.latitude}, ${stopPoint.longitude}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDropSelected ? Colors.red : Colors.red[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Drop',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isDropSelected ? Colors.white : Colors.red[800],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: (tempPickupStopPoint != null && tempDropStopPoint != null)
                              ? () {
                                  Navigator.pop(context, {
                                    'pickup': tempPickupStopPoint,
                                    'drop': tempDropStopPoint,
                                  });
                                }
                              : null,
                          child: const Text('Continue'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> bookSeatsOfRide(
      {required List<Seat> selectedSeats, double? totalAmount, PaymentSuccessResponse? response, required StopPoint? pickupStopPoint, required StopPoint? dropStopPoint}) async {
    final fromStop = widget.ride.stops.where((element) => element.name == widget.from).firstOrNull;
    final toStop = widget.ride.stops.where((element) => element.name == widget.to).firstOrNull;
    final price = widget.ride.pricing.where((element) => element.price.toDouble() == widget.price.toDouble()).firstOrNull;
    final transactionId = response?.paymentId;
    showLoader(context);
    final res = await repo.bookSeats(
        rideId: widget.ride.id.toString(),
        seats: selectedSeats,
        user_from_stop_id: fromStop?.id.toString(),
        user_to_stop_id: toStop?.id.toString(),
        user_price_id: price?.id?.toString(),
        // advance_payment: totalAmount?.percent30,
        advance_payment: totalAmount,
        user_pickup_point_id: pickupStopPoint?.id,
        user_drop_point_id: dropStopPoint?.id,
        razorpay_transaction_id: transactionId);
    hideLoader();

    ShowToastDialog.showToast(res.$2);
    if (res.$1) {
      ctr.getAllRidesAgain();
      Navigator.popUntil(context, (route) => route.settings.name == "/MyRidesListScreen");
    } else {
      //
    }
  }

  ElevatedButton buildElevatedButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    Color? foregroundColor,
    double? elevation,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shadowColor: Colors.transparent,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        elevation: elevation ?? 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildRouteTab() {
    final stops = widget.ride.stops;
    stops.sort((a, b) => (a.order).compareTo((b.order)));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Route Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: ListView.builder(
                  itemCount: stops.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final stop = stops[index];
                    final isFirst = index == 0;
                    final isLast = index == stops.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isFirst ? Colors.green : (isLast ? Colors.red : Colors.blue),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 3,
                                height: 40,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isFirst || isLast ? Colors.blue[50] : Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isFirst || isLast ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stop.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isFirst || isLast ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${stop.latitude}, ${stop.longitude}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isFirst || isLast)
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isFirst ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      isFirst ? 'START' : 'END',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (stop.stopPoints.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.place,
                                              size: 12,
                                              color: Colors.grey[700],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Stop Points',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ...stop.stopPoints.asMap().entries.map((entry) {
                                          final pointIndex = entry.key;
                                          final stopPoint = entry.value;

                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: pointIndex < stop.stopPoints.length - 1 ? 4.0 : 0.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        stopPoint.name,
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      if (stopPoint.type != StopPointType.both)
                                                        Text(
                                                          " (${stopPoint.type != StopPointType.both ? stopPoint.type.name.capitalizeFirst : ""} only)",
                                                          style: const TextStyle(
                                                            fontSize: 8,
                                                            color: Colors.grey,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatsTab() {
    final seats = widget.ride.seats;

    final rows = groupSeatsByRow(seats);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seat Layout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                SizedBox(width: 6.w),
                Expanded(child: _buildLegendItem(Colors.blue, "Driver")),
                Expanded(child: _buildLegendItem(Colors.red, "Booked")),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 6.w),
                Expanded(child: _buildLegendItem(Colors.green, "Available")),
                Expanded(child: _buildLegendItem(Colors.orange, "Selected")),
              ],
            ),
            const SizedBox(height: 5),
            if (_getUserBookedSeats() > 0)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 6.w),
                  Icon(Icons.account_circle_rounded, color: Colors.red, size: 10),
                  SizedBox(width: 1.w),
                  Text("Your seats", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10)),
                ],
              ),
            const SizedBox(height: 30),

            /// --- seat layout --
            ///
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: rows.asMap().entries.map((entry) {
                      final rowIndex = entry.key;
                      final rowSeats = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: SeatRow(
                            rowSeats: rowSeats,
                            rowIndex: rowIndex,
                            onTap: (seat) {
                              if ({RideStatus.upcoming, RideStatus.notStarted}.contains(widget.ride.rideStatusEnum)) {
                                if (!seat.isDriver && !seat.isBooked) {
                                  seat.isSelected = !seat.isSelected;
                                  setState(() {});
                                }
                              }
                            }),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            ///
            ///
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        seats.length.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        _getAvailableSeats().toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text(
                        'Available',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        _getBookedSeats().toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const Text(
                        'Booked',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        _getSelectedSeats().toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const Text(
                        'Selected',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {Widget? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: icon,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildDetailsTab() {
    // final ride = widget.ride;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Driver Information'),
              const SizedBox(height: 12),
              _buildDriverCard(),
              const SizedBox(height: 24),
              _buildSectionHeader('Vehicle Information'),
              const SizedBox(height: 12),
              _buildVehicleCard(),
              const SizedBox(height: 24),
              _buildSectionHeader('Timeline'),
              const SizedBox(height: 12),
              _buildTimelineCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDriverCard() {
    final driverDetail = widget.ride.driverDetail;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          // Driver Photo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.shade200, width: 2),
            ),
            child: ClipOval(
              child: driverDetail.photoUrl.isNotEmpty
                  ? Image.network(
                      driverDetail.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDriverAvatar();
                      },
                    )
                  : _buildDriverAvatar(),
            ),
          ),
          const SizedBox(width: 16),

          // Driver Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${driverDetail.prenom} ${driverDetail.nom}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      driverDetail.phone,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        driverDetail.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (driverDetail.id.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.badge, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'ID: ${driverDetail.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverAvatar() {
    return Container(
      color: Colors.blue.shade100,
      child: Icon(
        Icons.person,
        size: 30,
        color: Colors.blue.shade400,
      ),
    );
  }

  Widget _buildVehicleCard() {
    final ride = widget.ride;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.directions_car,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.vehicleName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ride.vehicleNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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
    );
  }

  Widget _buildTimelineCard() {
    final ride = widget.ride;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        children: [
          _buildTimelineItem(
            icon: Icons.access_time,
            label: 'Created',
            value: DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.parse(ride.createdAt)),
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.orange.shade200),
          const SizedBox(height: 12),
          _buildTimelineItem(
            icon: Icons.update,
            label: 'Last Updated',
            value: DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.parse(ride.updatedAt)),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String label,
    required String value,
    required MaterialColor color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: color.shade600,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// Widget _buildDetailsTab() {
//   final ride = widget.ride;
//
//   return Card(
//     elevation: 2,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//     child: Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Additional Details',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const SizedBox(height: 12),
//                   // _buildInfoRow('Driver ID', ride.driverId.toString()),
//                   _buildInfoRow('Vehicle Name', ride.vehicleName.toString()),
//                   _buildInfoRow('Vehicle Number', ride.vehicleNumber.toString()),
//                   Divider(),
//                   _buildInfoRow('Created', DateFormat('MMM dd, yyyy').format(DateTime.parse(ride.createdAt))),
//                   _buildInfoRow('Last Updated', DateFormat('MMM dd, yyyy').format(DateTime.parse(ride.updatedAt))),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget _buildInfoRow(String label, String value) {
//   return Padding(
//     padding: const EdgeInsets.only(bottom: 8),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey[600],
//             fontSize: 14,
//           ),
//         ),
//         Text(
//           value,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 14,
//           ),
//         ),
//       ],
//     ),
//   );
// }
}
