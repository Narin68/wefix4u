import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/globals.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial());

  Future init() async {
    emit(LanguageLoading());
    var _pref = await SharedPreferences.getInstance();
    String _code = _pref.getString(Prefs.langCode) ?? "en";
    emit(LanguageSuccess(_code));
  }

  Future change(String code) async {
    emit(LanguageLoading());
    var _pref = await SharedPreferences.getInstance();
    _pref.setString(Prefs.langCode, code);
    emit(LanguageSuccess(code));
  }
}
