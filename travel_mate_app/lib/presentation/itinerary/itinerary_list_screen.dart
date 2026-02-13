import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_mate_app/domain/entities/itinerary.dart';
import 'package:travel_mate_app/domain/usecases/get_itineraries.dart';

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/presentation/common/app_app_bar.dart';

/// 일정 목록 화면. 일정 생성·상세 이동.
class ItineraryListScreen extends StatefulWidget {
  const ItineraryListScreen({Key? key}) : super(key: key);

  @override
  State<ItineraryListScreen> createState() => _ItineraryListScreenState();
}

class _ItineraryListScreenState extends State<ItineraryListScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Itinerary> _itineraries = [];

  @override
  void initState() {
    super.initState();
    _loadItineraries();
  }

  Future<void> _loadItineraries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final getItineraries = Provider.of<GetItineraries>(context, listen: false);
      final fetchedItineraries = await getItineraries.execute();

      setState(() {
        _itineraries = fetchedItineraries;
        _isLoading = false;
        if (_itineraries.isEmpty) {
          _errorMessage = 'No itineraries shared yet. Share your travel plans!';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load itineraries: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: '일정',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/itinerary/new'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadItineraries,
                  child: ListView.builder(
                    itemCount: _itineraries.length,
                    itemBuilder: (context, index) {
                      final itinerary = _itineraries[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingMedium,
                            vertical: AppConstants.paddingSmall),
                        color: AppColors.card,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                          side: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: ListTile(
                          leading: itinerary.imageUrls.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(itinerary.imageUrls.first),
                                )
                              : const CircleAvatar(
                                  child: Icon(Icons.travel_explore),
                                ),
                          title: Text(itinerary.title),
                          subtitle: Text('Author: ${itinerary.authorId} - ${itinerary.startDate.toLocal().toString().split(' ')[0]} to ${itinerary.endDate.toLocal().toString().split(' ')[0]}'), // TODO: Display author's nickname
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            context.go('/itinerary/${itinerary.id}'); // Navigate to itinerary detail
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
