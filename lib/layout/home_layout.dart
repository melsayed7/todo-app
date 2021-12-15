
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget{

      var scaffoldKey = GlobalKey<ScaffoldState>();
      var formKey = GlobalKey<FormState>();
      var titlecontroller = TextEditingController();
      var timecontroller = TextEditingController();
      var datecontroller = TextEditingController();


      @override
      Widget build(BuildContext context) {
      return BlocProvider(
        create: (context) => AppCubit()..createDatabase(),
        child: BlocConsumer<AppCubit,AppStates>(
          listener: (BuildContext context,AppStates state) {
            if (state is AppInsertDatabaseState){
            Navigator.pop(context);
            }
          } ,
          builder: (BuildContext context,AppStates state) {
            AppCubit cubit = AppCubit.get(context);
            return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                title: Text(
                  cubit.titles[cubit.currentIndex],
                ),
              ),
              body: ConditionalBuilder(
                condition: true,
                builder:(context) => cubit.screens[cubit.currentIndex]  ,
                fallback:(context) =>Center(child: CircularProgressIndicator())  ,
              ) ,
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (cubit.isshowBottomSheet) {
                    if(formKey.currentState!.validate()){
                      cubit.insertToDatabase(
                          title: titlecontroller.text ,
                          date: datecontroller.text,
                          time: timecontroller.text
                      );

                      /*insertToDatabase(
                          title: titlecontroller.text,
                          date: datecontroller.text,
                          time: timecontroller.text).then((value) {
                        Navigator.pop(context);
                        isshowBottomSheet = false;
                        *//* setState(() {
                            fabIcon = Icons.edit;
                            });*//*
                      });*/
                    }
                  }else{
                    scaffoldKey.currentState!.showBottomSheet((
                        context) => Container(
                      padding: EdgeInsets.all(20.0),
                      color: Colors.grey[100],
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            defaultTextFeild(
                                controller: titlecontroller,
                                type: TextInputType.text,
                                label: 'New task',
                                prefix: Icons.title,
                                validate: (value ){
                                  if(value!.isEmpty){
                                    return'you should entre new task!!' ;
                                  }
                                  return null ;
                                }
                            ),
                            SizedBox(height: 15.0,),
                            defaultTextFeild(
                              controller: timecontroller,
                              type: TextInputType.datetime,
                              label: 'Time task',
                              prefix: Icons.watch_later_outlined,
                              validate: (value ){
                                if(value!.isEmpty){
                                  return('you should entre time task!!');
                                }
                                return null ;
                              },
                              ontaped: (){
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((value) {
                                  timecontroller.text= value!.format(context).toString();
                                });
                              },
                            ),
                            SizedBox(height: 15.0,),
                            defaultTextFeild(
                              controller: datecontroller,
                              type: TextInputType.datetime,
                              label: 'Date task',
                              prefix: Icons.calendar_today,
                              validate: (value ){
                                if(value!.isEmpty){
                                  return ('you should entre date task!!');
                                }
                                return null ;
                              },
                              ontaped: (){
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.parse("20220201"),
                                ).then((value) {
                                  datecontroller.text= DateFormat.yMMMd().format(value!);
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    ).closed.then((value) {
                      cubit.changeBottomSheetState(
                          isShow: false,
                          icon: Icons.edit
                      );
                    });
                    cubit.changeBottomSheetState(
                        isShow: true,
                        icon: Icons.add
                    );
                  }
                },
                child: Icon(
                  cubit.fabIcon,
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: cubit.currentIndex,
                onTap: (index){
                  cubit.ChangeIndex(index);
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle),
                    label: 'Done',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined),
                    label: 'Archived',
                  ),

                ],

              ),
            );
          },
        ),
      );
      }


    }

