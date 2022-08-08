import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CounterPage(title: 'example'),
    );
  }
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

enum FabLabel {
  number('+1'),
  letter('+a');

  const FabLabel(this.value);
  final String value;
  FabLabel get nextLabel => value == number.value ? letter : number;
}

class IncrementButtonViewModel extends ViewModel {
  IncrementButtonViewModel({
    required this.incrementNumber,
    required this.incrementLetter,
  });

  final void Function() incrementNumber;
  final void Function() incrementLetter;
  final _currentFabLabel = ValueNotifier<FabLabel>(FabLabel.number);

  @override
  void initState() {
    super.initState();
    _currentFabLabel.addListener(buildView);
  }

  void incrementCounter() {
    _currentFabLabel.value == FabLabel.number ? incrementNumber() : incrementLetter();
    _currentFabLabel.value = _currentFabLabel.value.nextLabel;
  }

  String get label => _currentFabLabel.value.value;
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                viewModel.letterCounter.value,
                style: TextStyle(fontSize: 64, color: viewModel.color.value),
              ),
              Text(
                viewModel.numberCounter.value.toString(),
                style: TextStyle(fontSize: 64, color: viewModel.color.value),
              ),
            ],
          ),
        ],
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
  final color = ValueNotifier<Color>(const Color.fromRGBO(0, 0, 0, 1.0));
  final numberCounter = ValueNotifier<int>(0);
  final letterCounter = ValueNotifier<String>('a');

  @override
  void initState() {
    super.initState();
    numberCounter.addListener(buildView);
    letterCounter.addListener(buildView);
    color.addListener(buildView);
    _streamSubscription = ColorService.currentColor.listen((newColor) => color.value = newColor);
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  late final StreamSubscription<Color> _streamSubscription;

  void incrementNumberCounter() {
    numberCounter.value = numberCounter.value == 9 ? 0 : numberCounter.value + 1;
  }

  void incrementLetterCounter() {
    letterCounter.value = letterCounter.value == 'z' ? 'a' : String.fromCharCode(letterCounter.value.codeUnits[0] + 1);
  }
}

abstract class View<T extends ViewModel> extends StatefulWidget {
  View({
    required this.viewModelBuilder,
    super.key,
  });
  final T Function() viewModelBuilder;
  final _viewModelInstance = _ViewModelInstance<T>();
  T get viewModel => _viewModelInstance.value!;

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
    _viewModel.buildView = () => setState(() {});
    _viewModel.addListener(_viewModel.buildView);
  }

  @override
  Widget build(BuildContext context) {
    widget._viewModelInstance.value = _viewModel;
    return widget.build(context);
  }
}

class _ViewModelInstance<T> {
  T? value;
}

abstract class ViewModel extends ChangeNotifier {
  @protected
  late void Function() buildView;

  @protected
  @mustCallSuper
  void initState() {}
}
