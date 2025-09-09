import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_demo1/query.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CountryListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Countries")),
      body: Query(
        options: QueryOptions(
          document: gql(getCountries),
        ),
        builder: (QueryResult result, { VoidCallback? refetch, FetchMore? fetchMore }) {
          if (result.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (result.hasException) {
            return Center(child: Text(result.exception.toString()));
          }

          final List countries = result.data?['countries'] ?? [];

          return ListView.builder(
            itemCount: countries.length,
            itemBuilder: (context, index) {
              final country = countries[index];
              return ListTile(
                title: Text(country['name']),
                subtitle: Text("Capital: ${country['capital'] ?? 'N/A'}"),
                trailing: Text(country['code']),
              );
            },
          );
        },
      ),
    );
  }
}
