import 'package:flutter/material.dart';
import 'database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All data
  List<Map<String, dynamic>> myData = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshData() async {
    final data = await DatabaseHelper.getItems();
    setState(() {
      myData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData(); // Loading the data when the app starts
  }

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _postalAddressController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void showMyForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingData = myData.firstWhere((element) => element['id'] == id);
      _userNameController.text = existingData['userName'];
      _postalAddressController.text = existingData['postalAddress'];
      _phoneNumberController.text = existingData['phoneNumber'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _userNameController,
                    decoration: const InputDecoration(hintText: 'User Name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _postalAddressController,
                    decoration:
                        const InputDecoration(hintText: 'Postal Address'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(hintText: 'Phone Number'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new data
                      if (id == null) {
                        await addItem();
                      }

                      if (id != null) {
                        await updateItem(id);
                      }

                      // Clear the text fields
                      _userNameController.text = '';
                      _postalAddressController.text = '';
                      _phoneNumberController.text = '';

                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

// Insert a new data to the database
  Future<void> addItem() async {
    await DatabaseHelper.createItem(_userNameController.text,
        _postalAddressController.text, _phoneNumberController.text);
    _refreshData();
  }

  // Update an existing data
  Future<void> updateItem(int id) async {
    await DatabaseHelper.updateItem(id, _userNameController.text,
        _postalAddressController.text, _phoneNumberController.text);
    _refreshData();
  }

  // Delete an item
  void deleteItem(int id) async {
    await DatabaseHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Successfully deleted!'), backgroundColor: Colors.green));
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : myData.isEmpty
              ? const Center(child: Text("No Data Available!!!"))
              : ListView.builder(
                  itemCount: myData.length,
                  itemBuilder: (context, index) => Card(
                    color: index % 2 == 0 ? Colors.green : Colors.green[200],
                    margin: const EdgeInsets.all(15),
                    child: ListTile(
                        title: Text(myData[index]['userName']),
                        subtitle: Text(myData[index]['postalAddress'] +
                            ' : ' +
                            (myData[index]['phoneNumber'])),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    showMyForm(myData[index]['id']),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    deleteItem(myData[index]['id']),
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showMyForm(null),
      ),
    );
  }
}
