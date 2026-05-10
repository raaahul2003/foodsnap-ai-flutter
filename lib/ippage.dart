import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login/src/welcomePage.dart';

void main(){
  runApp(myapp());
}
class myapp extends StatelessWidget {
  const myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ippage(),
    );
  }
}
class ippage extends StatefulWidget {
  const ippage({super.key});

  @override
  State<ippage> createState() => _ippageState();
}

class _ippageState extends State<ippage> {



  TextEditingController ipcontroller =new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IP Page"),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children:[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: ipcontroller,
              decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'IP Address'
            ),),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(onPressed: () async {


            String ip = ipcontroller.text;
            SharedPreferences sh = await SharedPreferences.getInstance();
            sh.setString('url', 'http://'+ip+':8000/myapp');
            sh.setString('img', 'http://'+ip+':8000');
            Navigator.push(context, MaterialPageRoute(builder: (context)=>WelcomePage()));
          }, child: Text('Enter'))
        ],
      ),
    );
  }
}

