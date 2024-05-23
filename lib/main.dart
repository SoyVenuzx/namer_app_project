import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    (favorites.contains(current))
        ? favorites.remove(current)
        : favorites.add(current);

    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;

      case 1:
        page = FavouritesPage();
        break;

      default:
        throw UnimplementedError('No widget for index $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  minExtendedWidth: 180,
                  destinations: [
                    NavigationRailDestination(
                        icon: Icon(Icons.home), label: Text('Home')),
                    NavigationRailDestination(
                        icon: Icon(Icons.favorite), label: Text('Favorites')),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) =>
                      setState(() => selectedIndex = index),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            )
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    (appState.favorites.contains(pair))
        ? icon = Icons.favorite
        : icon = Icons.favorite_border;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text.rich(
            TextSpan(
                text: 'A random ',
                children: [
                  TextSpan(
                    text: 'and fantastic',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  TextSpan(text: ' idea:'),
                ],
                style: TextStyle(fontSize: 25)),
          ),
          BigCard(pair: pair),

          //* El widget de SizedBox solamente ocupa espacio y no renderiza nada
          //* por sí solo. En general, se usa para crear "espacios visuales".
          SizedBox(height: 15),

          //* Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              //* Button: Favorite
              ElevatedButton.icon(
                  onPressed: () => appState.toggleFavorite(),
                  icon: Icon(icon),
                  label: Text('Like')),

              SizedBox(width: 10),

              //* Button: Next
              ElevatedButton(
                onPressed: () => appState.getNext(),
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontSize: 30,
    );

    return Card(
      color: theme.colorScheme.primary,
      margin: const EdgeInsets.only(top: 20, right: 10, bottom: 10, left: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavouritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet!'),
      );
    }

    return ListView(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Text(
          'You have ${appState.favorites.length} favorites:',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
        ),
      ),
      ...appState.favorites.map((pair) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${appState.favorites.indexOf(pair) + 1}. ${pair.asLowerCase}',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => appState.removeFavorite(pair),
                    icon: Icon(
                      Icons.delete,
                      size: 19,
                    ),
                    label: Text(
                      'Remove',
                      style: TextStyle(fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 15,
              thickness: 0.5,
              color: Theme.of(context).colorScheme.primary,
              indent: 20,
              endIndent: 20,
            ),
          ],
        );
      }),
    ]);
  }
}
