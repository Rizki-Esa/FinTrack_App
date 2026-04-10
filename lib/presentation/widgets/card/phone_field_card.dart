import 'package:flutter/material.dart';
import 'package:frontend_fintrack/presentation/widgets/input/number_input.dart';
import '../../../responsive_helper.dart';
import 'package:country_picker/country_picker.dart';

class PhoneFieldCard extends StatefulWidget {
  final bool isEditing;
  final TextEditingController controller;
  final Country tempCountry;
  final ValueChanged<Country> onCountryChanged;
  final bool showCountryDropdown;
  final VoidCallback toggleCountryDropdown;
  final TextEditingController countrySearchController;
  final Function(String)? onChanged;
  final String? hintText;

  const PhoneFieldCard({
    super.key,
    required this.isEditing,
    required this.controller,
    required this.tempCountry,
    required this.onCountryChanged,
    required this.showCountryDropdown,
    required this.toggleCountryDropdown,
    required this.countrySearchController,
    required this.onChanged,
    this.hintText,
  });

  @override
  State<PhoneFieldCard> createState() => _PhoneFieldCardState();
}

class _PhoneFieldCardState extends State<PhoneFieldCard> {
  late List<Country> filteredCountries;

  @override
  void initState() {
    super.initState();
    filteredCountries = CountryService().getAll();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: widget.isEditing ? widget.toggleCountryDropdown : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Text(
                      "${widget.tempCountry.flagEmoji} +${widget.tempCountry.phoneCode}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: widget.isEditing
                            ? (isDark ? Colors.white : Colors.black)
                            : (isDark ? Colors.grey[300] : Colors.grey[600]),
                      ),
                    ),
                    AnimatedRotation(
                      turns: widget.showCountryDropdown ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.arrow_right),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberInput(
                isEditing: widget.isEditing,
                controller: widget.controller,
                onChanged: widget.onChanged,
                hintText: widget.hintText,
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: widget.showCountryDropdown
              ? Container(
            margin: const EdgeInsets.only(top: 10),
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: widget.countrySearchController,
                    decoration: InputDecoration(
                      hintText: "Search country...",
                      isDense: true,
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (query) {
                      setState(() {
                        filteredCountries = CountryService()
                            .getAll()
                            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = filteredCountries[index];
                      return ListTile(
                        dense: true,
                        title: Text("${country.flagEmoji} ${country.name}"),
                        subtitle: Text("+${country.phoneCode}"),
                        onTap: widget.isEditing
                            ? () {
                          widget.onCountryChanged(country);
                          widget.countrySearchController.clear();
                        }
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          )
              : const SizedBox(),
        ),
      ],
    );
  }
}