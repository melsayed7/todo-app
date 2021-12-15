import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/todo_app/archived_tasks/archived_tasks.dart';
import 'package:todo_app/modules/todo_app/done_tasks/done_tasks.dart';
import 'package:todo_app/modules/todo_app/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';
import 'package:todo_app/shared/network/local/cache_helper.dart';


class AppCubit extends Cubit<AppStates>{

  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex =0;
  List<Widget> screens =[
    NewTaskScreen(),
    DoneTaskScreen(),
    ArchivedTaskScreen(),
  ];

  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void ChangeIndex (int index){
    currentIndex = index ;
    emit(AppChangeBottomNavBarState());
  }
  late Database database;
  List<Map> newtasks =[];
  List<Map> donetasks =[];
  List<Map> archivetasks =[];


  void createDatabase()
  {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: ( database, version)  {
        print('database created ');
        database.execute('CREATE TABLE tasks ( id INTEGER PRIMARY KEY , title TEXT , date TEXT , time TEXT , status TEXT)'
        ).then((value){
          print('table created');
        }).catchError((error){
          print('table not created ${error.toString()}');
        });
      },
      onOpen: (Database database) {
        getDataFromDatabase(database);
        print('database opened ');
      },
    ).then((value) {
      database = value ;
      emit(AppCreateDatabaseState());
    });

  }

   insertToDatabase({
    required String title,
    required String date,
    required String time,
  }) async
  {
     await database.transaction((txn)  async {
      await txn.rawInsert(
          'INSERT INTO tasks(title,date,time,status) VALUES ("$title","$date","$time","new")'
      ).then((value) {
        print('$value insert successfully');
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database);
      }).catchError((error){
        print('insert not added ${error.toString()}');
      });
    });
  }

  void getDataFromDatabase(database) {
    newtasks=[];
    donetasks=[];
    archivetasks=[];
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element)
      {
        if(element['status'] == 'new' ) {
          newtasks.add(element);
        } else if (element['status'] == 'done') {
          donetasks.add(element);
        }else {
          archivetasks.add(element);
        }
      });
     emit(AppGetDatabaseState());
    });

  }

  void updateDatabase ({
    required String status ,
    required int id,
})async{
    await database.rawUpdate(
    'UPDATE tasks SET status = ? WHERE id = ?',
    ['$status' , id ],).then((value){
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteDatabase ({
        required int id,
  })async{
    await database.rawDelete(
        'DELETE FROM tasks WHERE id = ?' , [id]).then((value){
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  bool isshowBottomSheet = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
}){
    isshowBottomSheet = isShow ;
    fabIcon = icon ;

    emit(AppChangeBottomSheetState());
  }

  bool isDark = false;
  void changeAppMode ({ bool? fromShared}){
    if(fromShared != null) {
      isDark = fromShared ;
      emit(AppChangeModeState());
    } else {
      isDark = !isDark ;
      CacheHelper.putBoolean(key: 'isDark', value: isDark).then((value) {
        emit(AppChangeModeState());
      });
    }
  }
}