import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final Map<String, dynamic> currentFilters;

  const FilterBottomSheetWidget({
    Key? key,
    required this.onApplyFilters,
    required this.currentFilters,
  }) : super(key: key);

  @override
  _FilterBottomSheetWidgetState createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(2.w)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Products',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Price Range
          Text('Price Range', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 1.h),
          RangeSlider(
            values: RangeValues(
              _filters['minPrice']?.toDouble() ?? 0.0,
              _filters['maxPrice']?.toDouble() ?? 1000.0,
            ),
            min: 0,
            max: 1000,
            divisions: 20,
            onChanged: (values) {
              setState(() {
                _filters['minPrice'] = values.start.round();
                _filters['maxPrice'] = values.end.round();
              });
            },
          ),
          Text('${_filters['minPrice']} - ${_filters['maxPrice']}'),

          SizedBox(height: 2.h),

          // Category Filter
          Text('Category', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            children: ['All', 'Electronics', 'Clothing', 'Food', 'Books'].map((
              category,
            ) {
              final isSelected = _filters['category'] == category;
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filters['category'] = selected ? category : null;
                  });
                },
              );
            }).toList(),
          ),

          Spacer(),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _filters.clear();
                    });
                  },
                  child: Text('Clear All'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilters(_filters);
                    Navigator.pop(context);
                  },
                  child: Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
