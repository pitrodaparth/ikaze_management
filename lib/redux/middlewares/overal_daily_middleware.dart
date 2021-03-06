import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory_controller/models/overal_daily_model.dart';
import 'package:inventory_controller/redux/actions/overal_daily_action.dart';
import 'package:inventory_controller/redux/appState/app_state.dart';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';

List<Middleware<AppState>> overalDailyTransactionsMiddleware() {
  return [
    TypedMiddleware<AppState, LoadOvaralDailyAction>(_loadOveralDailyTotal()),
    LoggingMiddleware.printer()
  ];
}

_loadOveralDailyTotal() {
  return (Store<AppState> store, LoadOvaralDailyAction action,
      NextDispatcher next) {
    next(action);

    _loadOveralDailyTotalAmount().then(
      (items) {
        store.dispatch(OvaralDailyLoadedAction(items));
      },
    ).catchError((exception, stacktrace) {
      store.dispatch(ErrorOccurredAction(exception));
    });
  };
}

Future<List<OveralDailyTransactionModel>> _loadOveralDailyTotalAmount() async {
  var response = await http
      .get('http://192.168.43.56:5000/api/auth/alltransactions/daily');
  if (response.statusCode == 200) {
    // List<MoneyTransactionModel> listFromJson(List<dynamic> json) {
    //   return json == null ? List<MoneyTransactionModel>() : json.map((value) => MoneyTransactionModel.fromJson(value)).toList();
    // }
    final jsonData = (json.decode(response.body))['data'] as List;
    return jsonData.map((item) => OveralDailyTransactionModel.fromJson(item)).toList();
  } else {
    throw Exception('Error getting data, http code: ${response.statusCode}.');
  }
}
