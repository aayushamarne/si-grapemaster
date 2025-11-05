import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFarmerScreen extends StatefulWidget {
  const AddFarmerScreen({super.key});

  @override
  State<AddFarmerScreen> createState() => _AddFarmerScreenState();
}

class _AddFarmerScreenState extends State<AddFarmerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _area = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _farmName.dispose();
    _phone.dispose();
    _address.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in first')));
      return;
    }
    setState(() => _loading = true);
    try {
      final doc = FirebaseFirestore.instance.collection('farmers').doc();
      await doc.set({
        'userId': user.uid,
        'farmName': _farmName.text.trim(),
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
        'area': double.tryParse(_area.text) ?? 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Farmer saved')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Farmer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _farmName,
                decoration: const InputDecoration(labelText: 'Farm name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter farm name' : null,
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextFormField(
                controller: _area,
                decoration: const InputDecoration(labelText: 'Area (hectares)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const CircularProgressIndicator() : const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
