import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class SearchAppBar extends StatefulWidget {
  const SearchAppBar({super.key});

  @override
  _SearchAppBarState createState() => _SearchAppBarState();
}

LatLng point = LatLng(52.52024375710182, 13.405136949283436);

class _SearchAppBarState extends State<SearchAppBar> {
  List<String> _searchList = [
    'Holly',
    '20,20',
  ];
  String _searchResult = "";

  MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asian Food in Berlin'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // do something
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _SearchDelegate(searchList: _searchList),
              ).then((value) {
                setState(() {
                  _searchResult = value ?? '';
                  point = LatLng(double.parse(_searchResult.split(",")[0]),
                      double.parse(_searchResult.split(",")[1]));
                  print(point);
                  _mapController.move(point, 13.0);
                });
              });
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: point, // 伦敦的坐标
          zoom: 13.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
        ],
      ),
    );
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  final List<String> searchList;

  _SearchDelegate({required this.searchList});

  Future<String> getData(String key, String value) async {
    var url =
        Uri.parse('https://asianfood.heguangyu.net/search.php?k=$key&v=$value');
    http.Response response = await http.get(url);
    // print(response.body);
    return response.body;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          if (query == '') {
            close(context, '');
          }
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<String> filteredList = searchList
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredList[index]),
          onTap: () {
            // Close the search page and return the selected value to the previous screen.
            Navigator.of(context).pop(filteredList[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<String> filteredList = searchList
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(filteredList[index]),
          onTap: () {
            query = filteredList[index];
            showResults(context);
            Navigator.of(context).pop(filteredList[index]);
          },
        );
      },
    );
  }
}
