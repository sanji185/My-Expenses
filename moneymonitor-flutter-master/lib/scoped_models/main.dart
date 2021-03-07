import 'package:scoped_model/scoped_model.dart';
import 'package:money_monitor/scoped_models/combined_model.dart';

class MainModel extends Model with CombinedModel, UserModel, ExpensesModel, FilterModel{} 

