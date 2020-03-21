import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

// StatelessWidget はすべての値が final （変更不可）
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: RandomWords(),
    );
  }
}

// StatefulWidget は StatelessWidget と異なり値の変更が可能。ここでは State の作成だけおこなう
class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}

// State の実装。ロジックはここに分離される
class RandomWordsState extends State<RandomWords> {
  // State において build メソッドの実装は必須
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );

          final List<Widget> divided =
            ListTile
            .divideTiles(
              context: context,
              tiles: tiles,
            )
            .toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  // アンダースコアを付けると private になる
  final _suggestions = <WordPair>[]; // リストに表示される単語一覧
  final _saved = Set<WordPair>(); // 一意にしたいので List でなく Set を用いる
  final _biggerFont = const TextStyle(fontSize: 18.0);

  // 単語と区切り線が交互に出てくる ListView を作成する
  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        // ListView は itemBuilder プロパティを持つ
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider(); // 奇数回目で Divider（仕切り）を設置（ i は 0 始まりなので実質偶数番目に区切り線は置かれる）

          final index = i ~/ 2; // ~/ は切り捨て。単語リストの他に区切り線が表示されるので 2 で割っている
          if (index >= _suggestions.length) {
            // リストをすべて読み込むとさらに 10 追加される
            _suggestions.addAll(generateWordPairs().take(10));
          }
          // 偶数回目では Divider でなく ListTile を設置する
          return _buildRow(_suggestions[index]);
        });
  }

  // WordPair をもとに ListTile を作成
  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);

    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      }
    );
  }
}
