import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  // BUSINESS
  final businessNameController = TextEditingController();
  final businessTypeController = TextEditingController();
  final locationController = TextEditingController();
  final ownerController = TextEditingController();

  // CONTACT
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  // LEGAL
  final licenseController = TextEditingController();
  final tinController = TextEditingController();

  // MONITORING DEVICE
  final deviceIdController = TextEditingController();

  // GPS
  final latController = TextEditingController();
  final lngController = TextEditingController();

  String status = "Active";
  bool loading = false;

  @override
  void dispose() {
    businessNameController.dispose();
    businessTypeController.dispose();
    locationController.dispose();
    ownerController.dispose();
    phoneController.dispose();
    emailController.dispose();
    licenseController.dispose();
    tinController.dispose();
    deviceIdController.dispose();
    latController.dispose();
    lngController.dispose();
    super.dispose();
  }

  Widget buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> saveBusiness() async {
    setState(() => loading = true);

    final url = Uri.parse("http://YOUR_BACKEND_IP:3000/businesses");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "business": {
            "name": businessNameController.text,
            "type": businessTypeController.text,
            "location": locationController.text,
            "owner": ownerController.text,
          },
          "contact": {
            "phone": phoneController.text,
            "email": emailController.text,
          },
          "legal": {
            "license": licenseController.text,
            "tin": tinController.text,
            "status": status,
          },
          "monitoring": {
            "stationId": deviceIdController.text,
            "latitude": latController.text,
            "longitude": lngController.text,
          },
        }),
      );

      setState(() => loading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Station registered successfully")),
        );

        // clear fields
        for (var c in [
          businessNameController,
          businessTypeController,
          locationController,
          ownerController,
          phoneController,
          emailController,
          licenseController,
          tinController,
          deviceIdController,
          latController,
          lngController,
        ]) {
          c.clear();
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Registration failed")));
      }
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Noise Monitoring Registration"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 750,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Image.asset('images/blink.png', height: 90)),

                const SizedBox(height: 10),

                const Center(
                  child: Text(
                    "Monitoring Station Registration",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),

                // BUSINESS SECTION
                sectionTitle("Business Information"),
                buildField(
                  label: "Business Name",
                  icon: Icons.business,
                  controller: businessNameController,
                ),
                buildField(
                  label: "Business Type",
                  icon: Icons.category,
                  controller: businessTypeController,
                ),
                buildField(
                  label: "Location Description",
                  icon: Icons.location_on,
                  controller: locationController,
                ),
                buildField(
                  label: "Owner Name",
                  icon: Icons.person,
                  controller: ownerController,
                ),
                buildField(
                  label: "Owner NIN",
                  icon: Icons.person,
                  controller: ownerController,
                ),

                // CONTACT
                sectionTitle("Contact Information"),
                buildField(
                  label: "Phone Number",
                  icon: Icons.phone,
                  controller: phoneController,
                ),
                buildField(
                  label: "Email Address",
                  icon: Icons.email,
                  controller: emailController,
                ),

                // LEGAL
                sectionTitle("Legal Information"),
                buildField(
                  label: "License Number",
                  icon: Icons.badge,
                  controller: licenseController,
                ),
                buildField(
                  label: "TIN Number",
                  icon: Icons.receipt_long,
                  controller: tinController,
                ),

                // MONITORING
                sectionTitle("Noise Monitoring Setup"),
                buildField(
                  label: "Station ID (Device ID)",
                  icon: Icons.computer,
                  controller: deviceIdController,
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: status,
                  decoration: InputDecoration(
                    labelText: "Status",
                    prefixIcon: const Icon(Icons.verified),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Active", child: Text("Active")),
                    DropdownMenuItem(
                      value: "Suspended",
                      child: Text("Suspended"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                    });
                  },
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: loading ? null : saveBusiness,
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      loading ? "Saving..." : "Register Monitoring Station",
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
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
}
