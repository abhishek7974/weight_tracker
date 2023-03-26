import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class EditWeightForm extends StatefulWidget {
  final DocumentSnapshot weight;

  EditWeightForm({required this.weight});

  @override
  _EditWeightFormState createState() => _EditWeightFormState();
}

class _EditWeightFormState extends State<EditWeightForm> {
  final weightController = TextEditingController();

  @override
  void initState() {
    weightController.text = widget.weight['weight'].toString();
    super.initState();
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  void _submitWeight(BuildContext context) {
    if (weightController.text.isEmpty) {
      return;
    }
    final weight = double.parse(weightController.text);
    widget.weight.reference.update({
      'weight': weight,
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Weight (kg)'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a weight';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () => _submitWeight(context),
            ),
          ],
        ),
      ),
    );
  }
}
