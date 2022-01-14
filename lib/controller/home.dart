import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../model/craps.dart';
import '../viewmodel/main_view_model.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  final String title = 'Craps Simulator'; // TODO: Localize

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const double _summaryPadding = 8;
  static const String _iconPath = 'assets/images/icon.png';
  static const int _iconScale = 3;

  final MainViewModel _viewModel = MainViewModel();
  final NumberFormat _percentFormat = NumberFormat('0.00%'); // TODO: Localize
  final NumberFormat _integerFormat = NumberFormat('#,##0'); // TODO: Localize
  final Map<_OverflowItem, String> _overflowLabels = {
    _OverflowItem.reset: 'Reset', // TODO: Localize
    _OverflowItem.settings: 'Settings', // TODO: Localize
    _OverflowItem.about: 'About', // TODO: Localize
  };

  bool _running = false;

  late ThemeData _theme;
  late ColorScheme _colorScheme;
  late TextTheme _textTheme;
  late IconThemeData _iconTheme;

  void _start() {
    setState(() => _running = true);
    _viewModel.start();
  }

  void _stop() {
    setState(() => _running = false);
    _viewModel.stop();
  }

  void _reset() {
    _stop();
    _viewModel.reset();
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    _colorScheme = _theme.colorScheme;
    _textTheme = _theme.textTheme;
    _iconTheme = IconTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: _actions(context),
      ),
      body: _body(context),
    );
  }

  List<Widget> _actions(BuildContext context) {
    return <Widget>[
      if (!_running)
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: () => _viewModel.simulate(true),
          tooltip: 'Simulate one batch of rounds', // TODO: Localize
        ),
      if (!_running)
        IconButton(
          icon: const Icon(Icons.fast_forward),
          onPressed: _start,
          tooltip: 'Simulate rounds until pause', // TODO: Localize
        )
      else
        IconButton(
          icon: const Icon(Icons.pause),
          onPressed: _stop,
          tooltip: 'Pause simulation', // TODO: Localize
        ),
      PopupMenuButton<_OverflowItem>(
        itemBuilder: _overflowActions,
        onSelected: _onOverflowItemSelected,
      ),
    ];
  }

  Widget _body(BuildContext context) {
    return StreamBuilder<Snapshot>(
      stream: _viewModel.snapshotStream,
      builder: (context, event) {
        List<Widget?> children = <Widget?>[];
        if (event.hasData) {
          Snapshot snapshot = event.data!;
          children.addAll([_rolls(snapshot), _summary(snapshot)]);
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: children
              .where((element) => element != null)
              .map<Widget>((element) => element!)
              .toList(growable: false),
        );
      },
    );
  }

  List<PopupMenuEntry<_OverflowItem>> _overflowActions(BuildContext context) {
    return <PopupMenuEntry<_OverflowItem>>[
      PopupMenuItem<_OverflowItem>(
        value: _OverflowItem.reset,
        child: Text(_overflowLabels[_OverflowItem.reset]!),
      ),
      PopupMenuItem<_OverflowItem>(
        value: _OverflowItem.settings,
        child: Text(_overflowLabels[_OverflowItem.settings]!),
      ),
      PopupMenuItem<_OverflowItem>(
        value: _OverflowItem.about,
        child: Text(_overflowLabels[_OverflowItem.about]!),
      ),
    ];
  }

  void _onOverflowItemSelected(_OverflowItem item) {
    switch (item) {
      case _OverflowItem.reset:
        _reset();
        break;
      case _OverflowItem.settings:
        break;
      case _OverflowItem.about:
        _showAbout();
        break;
    }
  }

  Widget? _rolls(Snapshot snapshot) {
    // TODO: Return ListBuilder
  }

  Widget _summary(Snapshot snapshot) {
    int rounds = snapshot.wins + snapshot.losses;
    double percentage = (rounds > 0) ? (snapshot.wins / rounds) : 0;
    String formattedWins = _integerFormat.format(snapshot.wins);
    String formattedRounds = _integerFormat.format(rounds);
    String formattedPercent = _percentFormat.format(percentage);
    String summary =
        '$formattedWins wins / $formattedRounds rounds = $formattedPercent'; // TODO: Localize.
    return Container(
      alignment: Alignment.center,
      color: _colorScheme.primary,
      padding: const EdgeInsets.all(_summaryPadding),
      child: Text(
        summary,
        style: _textTheme.bodyText1?.apply(color: _colorScheme.onPrimary),
      ),
    );
  }

  void _showAbout() {
    _appInfo().then<void>((Map<String, String> info) {
      showAboutDialog(
        context: context,
        applicationIcon: Image(
          image: const AssetImage(_iconPath),
          width: _iconTheme.size! * _iconScale,
          height: _iconTheme.size! * _iconScale,
        ),
        applicationName: info['name'],
        applicationVersion: info['version'],
        children: <Widget>[
          Text(
            info['about']!,
            style: _textTheme.bodyText1,
          ),
          Text(
            info['notice']!,
            style: _textTheme.caption,
          ),
        ],
      );
    });
  }

  Future<Map<String, String>> _appInfo() {
    AssetBundle bundle = DefaultAssetBundle.of(context);
    return Future.wait<Object>(<Future<Object>>[
      bundle.loadString('assets/text/about.txt', cache: true),
      bundle.loadString('assets/text/notice.txt', cache: true),
      PackageInfo.fromPlatform(),
    ]).then<Map<String, String>>((List<Object> content) {
      PackageInfo info = content[2] as PackageInfo;
      return {
        'about': content[0] as String,
        'notice': content[1] as String,
        'name': info.appName,
        'version': info.version,
      };
    });
  }
}

enum _OverflowItem { reset, settings, about }
