import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/testing/exercisedetail.dart';
import 'package:servtol/testing/list.dart';
import 'package:servtol/util/AppColors.dart';

class ExerciseList extends StatefulWidget {
  ExerciseList({super.key});

  List<Listmodel> exerciseListModel = [
    Listmodel(
      name: "Push Up",
      description: "A basic upper body strength exercise.",
      imageurl: "https://cdn-icons-png.flaticon.com/512/2548/2548530.png",
      type: "strength",
    ),
    Listmodel(
      name: "Weightlifting",
      description: "Lifting weights to build muscle mass.",
      imageurl: "https://cdn-icons-png.flaticon.com/512/8012/8012855.png",
      type: "strength",
    ),
    Listmodel(
      name: "Swimming",
      description: "A full-body workout in water.",
      imageurl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKS9yvYoZRT_5KCTpWu2xKg6vH4QTu0pRm2g&s",
      type: "aerobic",
    ),
    Listmodel(
      name: "Walking",
      description: "A basic low-impact aerobic exercise.",
      imageurl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQuUR28e80clDq2xnwVpLfvzTXBglA4FE6Wmw&s",
      type: "aerobic",
    ),
    Listmodel(
      name: "Squats",
      description: "A lower body strength exercise.",
      imageurl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQens-UypI4aCQP-piJMLxhH0aDef7-_QpYzg&s",
      type: "strength",
    ),
    Listmodel(
      name: "Deadlifts",
      description: "A full-body strength exercise.",
      imageurl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJem_Rx9Bazp1ZPrqtFevnf_ai7JVuqiUlQA&s",
      type: "strength",
    ),
    Listmodel(
      name: "Yoga",
      description: "A practice of physical and mental wellness.",
      imageurl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSN2wKrjxmWcItGHP8cu69LZIYyrLt0jZhIqw&s",
      type: "flexibility",
    ),
    Listmodel(
      name: "Pilates",
      description: "A workout focusing on core strength and flexibility.",
      imageurl: "https://static.vecteezy.com/system/resources/previews/021/413/116/non_2x/health-pilates-icon-flat-vector.jpg",
      type: "flexibility",
    ),
    Listmodel(
      name: "Burpees",
      description: "A full-body high-intensity exercise.",
      imageurl: "https://cdn.vectorstock.com/i/500p/38/04/man-doing-squat-thrust-burpee-vector-34493804.jpg",
      type: "hiit",
    ),

  ];

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exercise App"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
              flex:2,
          child: Container(
            child: Lottie.asset('assets/images/exercise.json'),
          )),
          Expanded(
            flex: 4,
            child: ListView.builder(
              itemCount: widget.exerciseListModel.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseDetail(exercise: widget.exerciseListModel[index]),
                      ),
                    );

                  },
                  title: Text(widget.exerciseListModel[index].name),
                leading: SizedBox(
                width: 50, // Constrain the width of the leading widget
                child: Image.network(
                widget.exerciseListModel[index].imageurl,width: double.infinity,height: 200,fit:BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/startlogo.jpeg');
                },
                ),
                ),
                  subtitle: Text(widget.exerciseListModel[index].description, maxLines: 1,),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}