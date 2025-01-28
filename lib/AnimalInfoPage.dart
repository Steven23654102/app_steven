import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnimalInfoPage extends StatefulWidget {
  final String animalType;

  const AnimalInfoPage({Key? key, required this.animalType}) : super(key: key);

  @override
  _AnimalInfoPageState createState() => _AnimalInfoPageState();
}

class _AnimalInfoPageState extends State<AnimalInfoPage> {
  String _searchResult = 'Searching for information...';
  String? _imageUrl; // Used to store the image URL
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnimalInfo(widget.animalType);
  }

  Future<void> _fetchAnimalInfo(String animalType) async {
    try {
      const String apiKey = 'your Key';
      const String cx = 'your cx';
      final query = '$animalType'; // Use more general keywords

      final String url =
          'https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$cx&q=$query';
      print('API URL: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: ${data.toString()}'); // Print the complete response data

        if (data['items'] != null && data['items'].isNotEmpty) {
          final firstResult = data['items'][0];
          print('First Item: ${firstResult.toString()}'); // print first result

          setState(() {
            _searchResult = firstResult['snippet'] ?? 'No details available.';
            _imageUrl = firstResult['pagemap']?['cse_image']?[0]?['src'];
            if (_imageUrl == null || _imageUrl!.isEmpty) {
              print('No image found for this result.');
            }
            _isLoading = false;
          });
        } else {
          setState(() {
            _searchResult = 'No results found for $query.';
            _isLoading = false;
          });
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        setState(() {
          _searchResult = 'Failed to fetch information. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Network error: $e');
      setState(() {
        _searchResult = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.animalType} Care Tips'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_imageUrl != null && _imageUrl!.isNotEmpty)
                Image.network(
                  _imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey,
                    );
                  },
                )
              else
                const Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: Colors.grey,
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _searchResult,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}