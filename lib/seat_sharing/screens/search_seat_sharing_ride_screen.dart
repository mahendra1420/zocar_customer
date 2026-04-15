import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zocar/helpers/navigation.dart';
import 'package:zocar/seat_sharing/screens/rides_list_screen.dart';

import '../../constant/constant.dart';

class SearchSeatSharingRidesScreen extends StatefulWidget {
  const SearchSeatSharingRidesScreen({super.key});

  @override
  State<SearchSeatSharingRidesScreen> createState() => _SearchSeatSharingRidesScreenState();
}

const String recentSearchPairsKey = 'recent_search_pairs';

class _SearchSeatSharingRidesScreenState extends State<SearchSeatSharingRidesScreen> {
  final _formKey = GlobalKey<FormState>();
  CitySearchPrediction? fromLocation;
  CitySearchPrediction? toLocation;

  List<SearchLocationPair> stops = [];
  DateTime selectedDateTime = DateTime.now();
  final _fromLocationCtr = TextEditingController();
  final _toLocationCtr = TextEditingController();

  @override
  void initState() {
    super.initState();
    getRecentSearches();
  }

  getRecentSearches() async {
    stops = await getRecentSearchPairs();
    setState(() {});
  }

  void _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() {
        selectedDateTime = date;
      });
    }
  }

  Future<void> saveSearchPair({
    required CitySearchPrediction from,
    required CitySearchPrediction to,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final newPair = SearchLocationPair(from: from, to: to);
    final newJsonStr = jsonEncode(newPair.toJson());
    final existing = prefs.getStringList(recentSearchPairsKey) ?? [];
    existing.removeWhere((e) => e == newJsonStr);
    existing.insert(0, newJsonStr);
    final limited = existing.take(5).toList();
    await prefs.setStringList(recentSearchPairsKey, limited);
  }

  Future<List<SearchLocationPair>> getRecentSearchPairs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(recentSearchPairsKey) ?? [];
    return stored.map((jsonStr) {
      final map = jsonDecode(jsonStr);
      return SearchLocationPair.fromJson(map);
    }).toList();
  }

  Future<void> clearRecentSearchPairs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(recentSearchPairsKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Ride'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'From Location',
                  border: OutlineInputBorder(),
                ),
                controller: _fromLocationCtr,
                readOnly: true,
                onTap: () async {
                  final city = await Constant().searchCityLocation(context, types: ['(cities)']);
                  if (city == null) return;
                  _fromLocationCtr.text = city.city;
                  fromLocation = city;
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter from location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _toLocationCtr,
                decoration: const InputDecoration(
                  labelText: 'To Location',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  final city = await Constant().searchCityLocation(context, types: ['(cities)']);
                  if (city == null) return;
                  _toLocationCtr.text = city.city;
                  toLocation = city;
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter to location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Date Time Picker
              ListTile(
                title: const Text('Journey Date'),
                subtitle: Text(
                  DateFormat("dd-MM-yyyy").format(selectedDateTime),
                ),
                trailing: const Icon(Icons.access_time),
                onTap: _selectDateTime,
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Searches',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (stops.isNotEmpty)
                    TextButton.icon(
                      onPressed: () async {
                        await clearRecentSearchPairs();
                        getRecentSearches();
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Clear All'),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              Expanded(
                child: stops.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'No recent search found.!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                getRecentSearches();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: stops.length,
                        itemBuilder: (context, index) {
                          final stop = stops[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Icon(Icons.history),
                              ),
                              title: Text("${stop.from.city}  -  ${stop.to.city}"),
                              onTap: () {
                                fromLocation = stop.from;
                                toLocation = stop.to;
                                _fromLocationCtr.text = stop.from.city;
                                _toLocationCtr.text = stop.to.city;
                                setState(() {});
                              },
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 4),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    _formKey.currentState!.save();

                    // Create complete route stops list

                    if (fromLocation == null || toLocation == null) {
                      return;
                    }

                    saveSearchPair(from: fromLocation!, to: toLocation!);

                    context.push(RideListScreen(
                      from: fromLocation?.city ?? "",
                      to: toLocation?.city ?? "",
                      time: selectedDateTime,
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Search >>>',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
