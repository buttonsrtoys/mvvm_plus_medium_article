import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class View<T extends ViewModel> extends StatefulWidget {
  //// Start of immutable code
  View({
    required this.viewModelBuilder,
    super.key,
  });
  final T Function() viewModelBuilder;
  final _viewModelInstance = _ViewModelHolder<T>();
  T get viewModel => _viewModelInstance.value!;

  Widget build(BuildContext context);

  //// Start of MVVM implementation
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
    widget._viewModelInstance.value = _viewModel;
    return widget.build(context);
  }
}

class _ViewModelHolder<T> {
  T? value;
}

//// Start of mutable code
abstract class ViewModel extends ChangeNotifier {
  @protected
  @mustCallSuper
  void initState() {}
}
