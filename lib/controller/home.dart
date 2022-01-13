import 'package:craps_simulator_flutter/controller/about.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/craps.dart';
import '../viewmodel/main_view_model.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({Key? key}) : super(key: key);

  final String title = 'Craps Simulator'; // TODO: Localize

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  final MainViewModel _viewModel = MainViewModel();
  final NumberFormat _percentFormat = NumberFormat('0.00%'); // TODO: Localize
  final NumberFormat _integerFormat = NumberFormat('#,##0'); // TODO: Localize
  final Map<_OverflowItem, String> _overflowLabels = {
    _OverflowItem.reset: 'Reset', // TODO: Localize
    _OverflowItem.settings: 'Settings', // TODO: Localize
    _OverflowItem.about: 'About', // TODO: Localize
    _OverflowItem.licenses: 'Licenses', // TODO: Localize
  };

  bool _running = false;

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
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: _buildActions(context),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              color: theme.colorScheme.primary,
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<Snapshot>(
                stream: _viewModel.snapshotStream,
                builder: (context, event) => Text(
                  _summary(event),
                  style: theme.textTheme.bodyText1
                      ?.apply(color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
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
        itemBuilder: _buildOverflowActions,
        onSelected: _onOverflowItemSelected,
      ),
    ];
  }

  List<PopupMenuEntry<_OverflowItem>> _buildOverflowActions(
      BuildContext context) {
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
      PopupMenuItem<_OverflowItem>(
        value: _OverflowItem.licenses,
        child: Text(_overflowLabels[_OverflowItem.licenses]!),
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
        _navigateToAbout();
        break;
      case _OverflowItem.licenses:
        _navigateToLicenses();
        break;
    }
  }

  String _summary(AsyncSnapshot event) {
    String summary;
    if (event.hasData) {
      Snapshot snapshot = event.data as Snapshot;
      int rounds = snapshot.wins + snapshot.losses;
      double percentage = (rounds > 0) ? (snapshot.wins / rounds) : 0;
      String formattedWins = _integerFormat.format(snapshot.wins);
      String formattedRounds = _integerFormat.format(rounds);
      String formattedPercent = _percentFormat.format(percentage);
      summary = // TODO: Localize
          '$formattedWins wins / $formattedRounds rounds = $formattedPercent';
    } else {
      summary = '';
    }
    return summary;
  }

  void _navigateToAbout() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (context) => const AboutRoute()),
    );
  }

  void _navigateToLicenses() {
    DefaultAssetBundle.of(context).loadString('assets/text/notice.txt').then(
        (notice) =>
            showLicensePage(context: context, applicationLegalese: notice));
  }
}

enum _OverflowItem { reset, settings, about, licenses }
