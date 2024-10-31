import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_flutter_firebase/pages/employee.dart';
import 'package:exam_flutter_firebase/service/database.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  Stream? employeeStream;
  String searchQuery = "";

  getOnTheLoad() async {
    employeeStream = await DatabaseMethods().getEmployeeDetails();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getOnTheLoad();
  }

  Widget allEmployeeDetails() {
    return StreamBuilder(
      stream: employeeStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return Center(child: Text("No employees found."));
        }

        final filteredDocs = snapshot.data.docs.where((doc) {
          String name = doc["Name"]?.toLowerCase() ?? "";
          return name.contains(searchQuery);
        }).toList();

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = filteredDocs[index];
            return Container(
              margin: EdgeInsets.only(bottom: 20.0),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Name: ${ds["Name"] ?? "N/A"}",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              nameController.text = ds["Name"] ?? "";
                              ageController.text = ds["Age"] ?? "";
                              locationController.text = ds["Location"] ?? "";
                              editEmployeeDetails(ds.id);
                            },
                            child: Icon(Icons.edit, color: Colors.orange),
                          ),
                          SizedBox(width: 5.0),
                          GestureDetector(
                            onTap: () async {
                              await DatabaseMethods().deleteEmployeeDetails(ds.id);
                            },
                            child: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                      Text(
                        "Age: ${ds["Age"] ?? "N/A"}",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Location: ${ds["Location"] ?? "N/A"}",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Employee()),
          );
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Flutter",
              style: TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Firebase",
              style: TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Search Employees",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(child: allEmployeeDetails()),
          ],
        ),
      ),
    );
  }

  Future<void> editEmployeeDetails(String id) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.cancel),
                      ),
                      SizedBox(width: 60.0),
                      Text(
                        "Edit",
                        style: TextStyle(color: Colors.blue, fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Details",
                        style: TextStyle(color: Colors.orange, fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  _buildTextField("Name", nameController),
                  SizedBox(height: 20.0),
                  _buildTextField("Age", ageController),
                  SizedBox(height: 20.0),
                  _buildTextField("Location", locationController),
                  SizedBox(height: 30.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        Map<String, dynamic> updateInfo = {
                          "Id": id,
                          "Name": nameController.text,
                          "Age": ageController.text,
                          "Location": locationController.text,
                        };
                        await DatabaseMethods().updateEmployeeDetails(id, updateInfo).then((value) {
                          Navigator.pop(context);
                        });
                      },
                      child: Text("Update"),
                    ),
                  )
                ],
              ),
            ),
          ));

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        Container(
          padding: EdgeInsets.only(left: 10.0),
          decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }
}
