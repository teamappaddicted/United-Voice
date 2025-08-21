// lib/user_form.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unitedvoice/MainHome.dart';

class CustomerIssuePage extends StatefulWidget {
  const CustomerIssuePage({super.key});

  @override
  State<CustomerIssuePage> createState() => _CustomerIssuePageState();
}

class _CustomerIssuePageState extends State<CustomerIssuePage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();
  final _productIdCtrl = TextEditingController();
  final _issueDetailsCtrl = TextEditingController();

  final List<String> _categories = [
    'Hardware',
    'Software',
    'Services',
    'Other',
  ];
  String? _selectedCategory;
  bool _submitting = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _companyNameCtrl.dispose();
    _productIdCtrl.dispose();
    _issueDetailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final customer = Customer(
        fullName: _fullNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        companyName: _companyNameCtrl.text.trim(),
        productId: _productIdCtrl.text.trim(),
        category: _selectedCategory!,
        issueDetails: _issueDetailsCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('customer_issues')
          .add(customer.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Issue submitted successfully')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainHome(selectedIndex: 0),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to submit issue: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black, // ✅ black background
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Post a Problem", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _SectionCard(
                  title: "User Information",
                  child: Column(
                    children: [
                      _darkTextField(
                        controller: _fullNameCtrl,
                        label: "Full Name",
                        icon: Icons.person,
                        hint: "e.g., John Doe",
                      ),
                      const SizedBox(height: 14),
                      _darkTextField(
                        controller: _emailCtrl,
                        label: "Email Address",
                        icon: Icons.email,
                        hint: "e.g., john.doe@gmail.com",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _darkTextField(
                        controller: _companyNameCtrl,
                        label: "Company Name",
                        icon: Icons.business,
                        hint: "e.g., TechNova Solutions Pvt Ltd",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  title: "Product Information",
                  child: Column(
                    children: [
                      _darkTextField(
                        controller: _productIdCtrl,
                        label: "Product ID",
                        icon: Icons.qr_code,
                        hint: "Enter the unique product code",
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        dropdownColor: Colors.black, // ✅ dark dropdown
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Product Category",
                          labelStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(Icons.category, color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        items: _categories
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val),
                        validator: (v) =>
                            v == null ? "Please select a category" : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  title: "Issue Details",
                  child: _darkTextField(
                    controller: _issueDetailsCtrl,
                    label: "Describe the Issue",
                    icon: Icons.report_problem,
                    hint: "Explain the issue clearly...",
                    maxLines: 5,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_alt),
                    label: Text(
                      _submitting ? "Submitting..." : "Submit Issue",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Dark TextField
  Widget _darkTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      validator: (v) =>
          v == null || v.trim().isEmpty ? "$label is required" : null,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent, // ✅ transparent card
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24, width: 1), // subtle border
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class Customer {
  final String fullName;
  final String email;
  final String companyName;
  final String productId;
  final String category;
  final String issueDetails;
  final DateTime createdAt;

  Customer({
    required this.fullName,
    required this.email,
    required this.companyName,
    required this.productId,
    required this.category,
    required this.issueDetails,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'email': email,
        'companyName': companyName,
        'productId': productId,
        'category': category,
        'issueDetails': issueDetails,
        'createdAt': createdAt,
      };
}
