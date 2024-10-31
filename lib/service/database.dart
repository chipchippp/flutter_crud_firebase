import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseMethods{
Future addEmployeeDetails(Map<String, dynamic> employeeInfoMap, String id) async {
  try {
    return await FirebaseFirestore.instance
      .collection("Employee")
      .doc(id)
      .set(employeeInfoMap);
  } catch (e) {
    print("Error adding employee: $e");
    return null;
  }
}

  Future<Stream<QuerySnapshot>> getEmployeeDetails() async{
    return await FirebaseFirestore.instance.collection("Employee").snapshots();
  }

  Future updateEmployeeDetails(String id, Map<String, dynamic> updateInfo)async{
    return await FirebaseFirestore.instance.collection("Employee").doc(id)
    .update(updateInfo);
  }

Future<bool> deleteEmployeeDetails(String id) async {
  try {
    await FirebaseFirestore.instance.collection("Employee").doc(id).delete();
    return true;
  } catch (e) {
    print("Error deleting employee: $e");
    return false;
  }
}



}