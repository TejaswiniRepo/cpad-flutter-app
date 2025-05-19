import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../services/parse_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _statusOptions = ['None', 'Submitted', 'Not Submitted'];
  String _selectedStatus = 'None';
  List<ParseObject> items = [];
  ParseObject? _selectedItemForEdit;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    items = await ParseService.fetchItems();
    setState(() {});
  }

  Future<void> addItem() async {
    if (_nameController.text.isEmpty || int.tryParse(_ageController.text) == null) return;
    await ParseService.addItem(_nameController.text, int.parse(_ageController.text), _selectedStatus);
    _clearForm();
    fetchItems();
  }

  Future<void> updateItem(ParseObject person) async {
    if (_nameController.text.isEmpty || int.tryParse(_ageController.text) == null) return;
    await ParseService.updateItem(person, _nameController.text, int.parse(_ageController.text), _selectedStatus);
    _clearForm();
    fetchItems();
  }

  Future<void> deleteItem(ParseObject person) async {
    await ParseService.deleteItem(person);
    fetchItems();
  }

  void _clearForm() {
    _nameController.clear();
    _ageController.clear();
    _selectedStatus = 'None';
    _selectedItemForEdit = null;
    setState(() {});
  }

  Future<void> doLogout() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      final response = await user.logout();
      if (response.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${response.error?.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('User Records', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: doLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: Icon(
                    _selectedItemForEdit == null ? Icons.add : Icons.update,
                    color: Colors.white,
                  ),
                  label: Text(
                    _selectedItemForEdit == null ? 'Add Record' : 'Update Record',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (_selectedItemForEdit == null) {
                      addItem();
                    } else {
                      updateItem(_selectedItemForEdit!);
                    }
                  },
                ),
                if (_selectedItemForEdit != null)
                  TextButton.icon(
                    onPressed: _clearForm,
                    icon: Icon(Icons.cancel, color: Colors.red),
                    label: Text('Cancel Edit', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: items.isEmpty
                ? Center(child: Text('No records found.'))
                : ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];
                final name = item.get<String>('name') ?? '';
                final age = item.get<int>('age')?.toString() ?? '';
                final status = item.get<String>('status')?.toString() ?? '';
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Text(name.isNotEmpty ? name[0] : '?', style: TextStyle(color: Colors.white)),
                    ),
                    title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Age: $age | Status: $status'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.amber),
                          onPressed: () {
                            setState(() {
                              _nameController.text = name;
                              _ageController.text = age;
                              _selectedStatus = status;
                              _selectedItemForEdit = item;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteItem(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
