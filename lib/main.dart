import 'package:flutter/material.dart';
import 'package:main/databaseHelper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Book CRUD',
    theme: ThemeData(
      primarySwatch: Colors.amber,
    ),
    home: const HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _selectedImage;
  double _customImageHeight = 80.0; // Adjust this height as needed

  void _refreshJournals() async {
    final data = await DatabaseHelper.getItems();
    setState(() {
      _items = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
    debugPrint("..Number of items ${_items.length}");
  }

  Future<void> _addItem({String imageUrl = ''}) async {
    String imagePath = '';

    if (_selectedImage != null) {
      imagePath = _selectedImage!.path;
    }

    await DatabaseHelper.createItem(
      _nameController.text,
      _descriptionController.text,
      imagePath,
    );
    _selectedImage = null;
    _refreshJournals();
  }

  Future<Widget> _loadImage(String? imageUrl) async {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      File imageFile = File(imageUrl);
      print('Image file path: ${imageFile.path}');
      if (await imageFile.exists()) {
        return Image.file(
          imageFile,
          width: 70,
          height: _customImageHeight, // Use the custom height
          fit: BoxFit.fill,
        );
      } else {
        print('Image file does not exist: $imageUrl');
        // Return a placeholder or default image
        return Container(
          width: 50,
          height: 180,
          color: Colors.grey,
        );
      }
    } else {
      // Return default image if imageUrl is null or empty
      // ignore: sized_box_for_whitespace
      return Container(
        // ignore: sort_child_properties_last
        child: Image.asset(
          'assets/images/NoBook.jpg',
          fit: BoxFit.fill,
        ),
        width: 70,
        height: 100,
      );
    }
  }

  Future<void> _updateItem(int id, {String imageUrl = ''}) async {
    String imagePath = '';

    if (_selectedImage != null) {
      imagePath = _selectedImage!.path;
    }

    await DatabaseHelper.updateItem(
        id, _nameController.text, _descriptionController.text, imagePath);
    _selectedImage = null; // Reset selected image after update
    _refreshJournals();
  }

  void _deleteItem(int id) async {
    await DatabaseHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted an item!'),
    ));
    _refreshJournals();
  }

  void _showForm(int? id, String? imageUrl) async {
    if (id != null) {
      final existingJournal =
          _items.firstWhere((element) => element['id'] == id);
      _nameController.text = existingJournal['name'];
      _descriptionController.text = existingJournal['description'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        _selectedImage = File(imageUrl);
      }
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
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () async {
                final imagePicker = ImagePicker();
                final XFile? image =
                    await imagePicker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _selectedImage = File(image.path);
                  });
                }
              },
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      width: 50,
                      height: _customImageHeight, // Use the custom height
                      fit: BoxFit.cover,
                    )
                  : Text('Pick Image'),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.center,
              height: 50,
              child: TextField(
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
                controller: _nameController,
                decoration: InputDecoration(
                    hintText: 'Enter Book Name',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.black, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          BorderSide(color: Color(0xff18DAA3), width: 1),
                    )),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              alignment: Alignment.center,
              height: 50,
              child: TextField(
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
                controller: _descriptionController,
                decoration: InputDecoration(
                    hintText: 'Enter Description',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.black, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          BorderSide(color: Color(0xff18DAA3), width: 1),
                    )),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await _addItem();
                }

                if (id != null) {
                  await _updateItem(id);
                }
                _nameController.text = '';
                _descriptionController.text = '';
                Navigator.pop(context);
              },
              child: Text(id == null ? 'Create New' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null, null),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        title: const Text(
          'Book Reading',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.amber,
                  ),
                  width: 100,
                  height: 90,
                  alignment: Alignment.center,
                  child: const Text(
                    'Most Reading',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.blue,
                  ),
                  width: 100,
                  height: 90,
                  alignment: Alignment.center,
                  child: const Text(
                    'You May Like',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.purple,
                  ),
                  width: 100,
                  height: 90,
                  alignment: Alignment.center,
                  child: const Text(
                    'Newly Adding',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.all(10),
                      child: Container(
                        height: 100,
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: ListTile(
                          title: Text(
                            _items[index]['name'] ?? 'No Name',
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              _items[index]['description'],
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          leading: FutureBuilder<Widget>(
                            future: _loadImage(_items[index]['imageUrl']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData) {
                                return snapshot.data!;
                              } else {
                                // Placeholder or default image
                                return Container(
                                  width: 50,
                                  color: Colors.grey,
                                );
                              }
                            },
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => _showForm(
                                    _items[index]['id'],
                                    _items[index]['imageUrl'],
                                  ),
                                  icon: const Icon(Icons.edit),
                                  color: Colors.amber,
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _deleteItem(_items[index]['id']),
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
