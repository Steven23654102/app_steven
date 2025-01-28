import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'ArticleDetailPage.dart';

class RelatedInformationPage extends StatefulWidget {
  @override
  _RelatedInformationPageState createState() =>
      _RelatedInformationPageState();
}

class _RelatedInformationPageState extends State<RelatedInformationPage> {
  List<Map<String, dynamic>> petNews = []; // Change the type to dynamic
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPetNews();
  }

  Future<void> _fetchPetNews() async {
    try {
      const String apiKey = 'your API Key'; // Replace with a valid API Key
      const String cx = 'your CSE ID'; // Replace with a valid CSE ID
      const String query = 'pet'; // Search Keywords
      final String url =
          'https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$cx&q=$query&num=10';

      print('Requesting URL: $url'); // Print the requested URL

      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null) {
          setState(() {
            petNews = List<Map<String, dynamic>>.from(data['items'].map((item) {
              return {
                'title': item['title']?.toString() ?? 'No Title',
                'description': item['snippet']?.toString() ?? 'No Description',
                'image': item['pagemap']?['cse_image']?[0]?['src']?.toString() ?? '',
                'link': item['link']?.toString() ?? '',
                'content': item['snippet']?.toString() ?? '',
              };
            }));
            _isLoading = false;
          });
        } else {
          print('No items found in the response.');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Related Information'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : petNews.isEmpty
          ? const Center(child: Text('No related information found.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: petNews.length,
        itemBuilder: (context, index) {
          final article = petNews[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              leading: article['image'] != null &&
                  article['image'].isNotEmpty
                  ? Image.network(
                article['image'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image,
                    size: 60, color: Colors.grey),
              )
                  : const Icon(Icons.image,
                  size: 60, color: Colors.grey), // Default image
              title: Text(
                article['title'] ?? 'No Title',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                article['description'] ?? 'No Description',
                style: const TextStyle(fontSize: 14.0),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ArticleDetailPage(article: article),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}