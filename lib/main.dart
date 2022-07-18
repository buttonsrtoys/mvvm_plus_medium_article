import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final appTitle = 'example';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CounterPage(title: appTitle),
    );
  }
}

abstract class View<T extends ViewModel> extends StatefulWidget {
  View({
    required this.viewModelBuilder,
    super.key,
  });
  final T Function() viewModelBuilder;
  final _viewModelHolder = _ViewModelHolder<T>();
  T get viewModel => _viewModelHolder.viewModel!;

  Widget build(BuildContext context);

  @nonVirtual
  @override
  State<View<T>> createState() => _ViewState<T>();
}

class _ViewState<T extends ViewModel> extends State<View<T>> {
  late T _viewModel;

  @override
  void initState() {
    super.initState();
    _initViewModel();
    _viewModel.initState();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _initViewModel() {
    _viewModel = widget.viewModelBuilder();
    _viewModel.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    widget._viewModelHolder.viewModel = _viewModel;
    return widget.build(context);
  }
}

class _ViewModelHolder<T> {
  T? viewModel;
}

abstract class ViewModel extends ChangeNotifier {
  @protected
  void initState() {}
}

class IncrementButton extends View<IncrementButtonViewModel> {
  IncrementButton({
    required void Function() onIncrementNumber,
    required void Function() onIncrementLetter,
    super.key,
  }) : super(
            viewModelBuilder: () => IncrementButtonViewModel(
                  incrementNumber: onIncrementNumber,
                  incrementLetter: onIncrementLetter,
                ));

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: viewModel.incrementCounter,
      child: Text(viewModel.label, style: const TextStyle(fontSize: 24)),
    );
  }
}

enum IncrementType { number, letter }

class IncrementButtonViewModel extends ViewModel {
  IncrementButtonViewModel({
    required this.incrementNumber,
    required this.incrementLetter,
  });

  IncrementType _currentType = IncrementType.number;
  final void Function() incrementNumber;
  final void Function() incrementLetter;

  void incrementCounter() {
    _currentType == IncrementType.number ? incrementNumber() : incrementLetter();
    _currentType = _currentType == IncrementType.number ? IncrementType.letter : IncrementType.number;
    notifyListeners();
  }

  String get label => <String>['+1', '+a'][_currentType.index];
}

class CounterPage extends View<CounterPageViewModel> {
  CounterPage({
    required this.title,
    super.key,
  }) : super(
          viewModelBuilder: () => CounterPageViewModel(),
        );

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  viewModel.letterCounter,
                  style: TextStyle(fontSize: 64, color: viewModel.color),
                ),
                Text(
                  '${viewModel.numberCounter}',
                  style: TextStyle(fontSize: 64, color: viewModel.color),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: IncrementButton(
        onIncrementNumber: () => viewModel.incrementNumberCounter(),
        onIncrementLetter: () => viewModel.incrementLetterCounter(),
      ),
    );
  }
}

class ColorService {
  static final currentColor = Stream<Color>.periodic(const Duration(seconds: 2), (int i) {
    return <Color>[Colors.red, Colors.green, Colors.blue, Colors.orange][i % 4];
  });
}

class CounterPageViewModel extends ViewModel {
  Color _color = const Color.fromRGBO(0, 0, 0, 1.0);
  Color get color => _color;
  int _numberCounter = 0;
  int get numberCounter => _numberCounter;
  String _letterCounter = 'a';
  String get letterCounter => _letterCounter;

  @override
  void initState() {
    _streamSubscription = ColorService.currentColor.listen(setColor);
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  late final StreamSubscription<Color> _streamSubscription;

  void setColor(Color newColor) {
    _color = newColor;
    notifyListeners();
  }

  void incrementNumberCounter() {
    _numberCounter = _numberCounter == 9 ? 0 : _numberCounter + 1;
    notifyListeners();
  }

  void incrementLetterCounter() {
    _letterCounter = _letterCounter == 'z' ? 'a' : String.fromCharCode(_letterCounter.codeUnits[0] + 1);
    notifyListeners();
  }
}
