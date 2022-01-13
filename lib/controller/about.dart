import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AboutRoute extends StatelessWidget {
  const AboutRoute({Key? key})
      : title = 'About Craps Simulator',
        // TODO: Localize
        super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    Future<String> about =
        DefaultAssetBundle.of(context).loadString('assets/markdown/about.md');
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title),
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: about,
          builder: (context, snapshot) {
            return (snapshot.connectionState == ConnectionState.done)
                ? Markdown(data: snapshot.data!)
                : const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
