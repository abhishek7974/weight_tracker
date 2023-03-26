import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:weight_tracker/view/edit_form.dart';
import 'package:weight_tracker/view/login_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SignInScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    hintText: 'Enter your weight in kg',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your weight';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text('Submit'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _submitWeight(context, _weightController);
                    }
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('weights')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    return Container(
                      height: height * 0.6,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final QueryDocumentSnapshot<Object?> weight =
                              snapshot.data!.docs[index];
                          final DateTime time = weight['time'].toDate();
                          final formattedTime =
                              DateFormat('yyyy-MM-dd HH:mm').format(time);
                          return ListTile(
                            title: Text('Weight: ${weight['weight']} kg'),
                            subtitle: Text('Time: ${formattedTime}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: EditWeightForm(weight: weight),
                                    ),
                                  ),
                                ),
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('weights')
                                          .doc(weight.id)
                                          .delete();
                                    }),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _submitWeight(
    BuildContext context, TextEditingController weightController) async {
  final now = Timestamp.now();

  final weight = {
    'weight': double.parse(weightController.text),
    'time': now,
  };

  final result =
      await FirebaseFirestore.instance.collection('weights').add(weight);

  // Show a success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Weight saved with ID: ${result.id}')),
  );
}
