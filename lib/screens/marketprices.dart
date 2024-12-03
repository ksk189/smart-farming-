import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarketPricesPage extends StatefulWidget {
  const MarketPricesPage({super.key});

  @override
  State<MarketPricesPage> createState() => _MarketPricesPageState();
}

class _MarketPricesPageState extends State<MarketPricesPage> {
  late Future<String> _readmeData;
  List<String> _stateDropdownItems = [];
  List<String> _commodityDropdownItems = [];
  String? _selectedState;
  String? _selectedCommodity;
  String _filteredData = '';

  @override
  void initState() {
    super.initState();
    _fetchReadmeData();
    _fetchStateDropdownData();
    _fetchCommodityDropdownData();
  }

  Future<void> _fetchReadmeData() async {
    try {
      final response = await Gemini.instance.text(
        modelName: 'models/gemini-1.5-flash',
        "Provide sample agricultural commodity prices in a Markdown table format.\n\nFormat as follows:\n\n"
        "## Agricultural Commodity Market Prices\n\n"
        "| Commodity   | State       | District     | Market       | Price (INR) |\n"
        "|-------------|-------------|--------------|--------------|-------------|\n"
        "| Rice        | Punjab      | Amritsar     | Majitha      | 3800        |\n"
        "| Wheat       | Haryana     | Karnal       | Kaithal      | 3600        |\n"
        "| Barley      | Uttar Pradesh | Saharanpur | Deoband      | 3550        |\n\n"
        "Include other commodities and states similarly, with realistic values.",
      );

      if (response != null && response.content?.parts?.isNotEmpty == true) {
        setState(() {
          _filteredData = response.content!.parts!.first.text ?? '';
        });
      }
    } catch (e) {
      print("Error loading README data: $e");
    }
  }

  Future<void> _fetchStateDropdownData() async {
    try {
      final response = await Gemini.instance.text(
        modelName: 'models/gemini-1.5-flash',
        "List major agricultural states for a market data application.",
      );

      if (response != null && response.content?.parts?.isNotEmpty == true) {
        setState(() {
          _stateDropdownItems = response.content!.parts!.first.text!.split('\n').where((line) => line.isNotEmpty).toList();
        });
      }
    } catch (e) {
      print("Error loading states: $e");
    }
  }

  Future<void> _fetchCommodityDropdownData() async {
    try {
      final response = await Gemini.instance.text(
        modelName: 'models/gemini-1.5-flash',
        "List common agricultural commodities for a market app.",
      );

      if (response != null && response.content?.parts?.isNotEmpty == true) {
        setState(() {
          _commodityDropdownItems = response.content!.parts!.first.text!.split(', ');
        });
      }
    } catch (e) {
      print("Error loading commodities: $e");
    }
  }

  void _applyFilters() {
    setState(() {
      if (_selectedState != null || _selectedCommodity != null) {
        _filteredData = _filteredData
            .split('\n')
            .where((line) => (_selectedState == null || line.contains(_selectedState!)) &&
                            (_selectedCommodity == null || line.contains(_selectedCommodity!)))
            .join('\n');
      } else {
        _fetchReadmeData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Prices'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: _filteredData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Markdown(
                  data: _filteredData,
                  styleSheet: MarkdownStyleSheet(
                    tableHead: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    p: const TextStyle(fontSize: 16),
                    listBullet: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: _selectedState,
                hint: const Text('Select State'),
                items: _stateDropdownItems.map((state) {
                  return DropdownMenuItem(value: state, child: Text(state));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                  });
                },
              ),
              DropdownButton<String>(
                value: _selectedCommodity,
                hint: const Text('Select Commodity'),
                items: _commodityDropdownItems.map((commodity) {
                  return DropdownMenuItem(value: commodity, child: Text(commodity));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCommodity = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  _applyFilters();
                  Navigator.pop(context);
                },
                child: const Text('Apply Filter'),
              ),
            ],
          ),
        );
      },
    );
  }
}