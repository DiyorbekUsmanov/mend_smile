import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

ValueNotifier<GraphQLClient> initGraphQLClient() {
  final HttpLink httpLink = HttpLink("https://countries.trevorblades.com/");

  return ValueNotifier(
    GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: httpLink,
    ),
  );
}
