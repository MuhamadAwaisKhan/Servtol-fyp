import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProviderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Providers',
          style: TextStyle(
            color: AppColors.heading,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('provider').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final providers = snapshot.data!.docs;
          if (providers.isEmpty) {
            return Center(
              child: Text(
                'No Providers Found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: providers.length,
            itemBuilder: (context, index) {
              var provider = providers[index];
              final data = provider.data() as Map<String, dynamic>;
              return Card(
                color: Colors.lightBlueAccent,

                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      data.containsKey('ProfilePic') && data['ProfilePic'] != null
                          ? data['ProfilePic']
                          : '',
                    ),
                    onBackgroundImageError: (_, __) =>
                        AssetImage('assets/images/fallback_image.png'),
                    backgroundColor: Colors.grey[200],
                  ),
                  title: Text(
                    data.containsKey('FirstName') ? data['FirstName'] : 'N/A',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.heading,
                    ),
                  ),
                  subtitle: Text(
                    data.containsKey('Email') ? data['Email'] : 'N/A',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  trailing: Icon(
                    FontAwesomeIcons.chevronRight,
                    color: Colors.white,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProviderDetailsScreen(provider: provider),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}




class ProviderDetailsScreen extends StatefulWidget {
  final QueryDocumentSnapshot provider;

  ProviderDetailsScreen({required this.provider});

  @override
  _ProviderDetailsScreenState createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  bool _isDeleting = false;

  Future<void> _deleteProvider(BuildContext context, String providerId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Provider'),
        content: Text(
          'Are you sure you want to delete this provider? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isDeleting = true;
      });

      try {
        await FirebaseFirestore.instance.collection('provider').doc(providerId).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Provider deleted successfully.')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting provider: $e')),
        );
      } finally {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.provider.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Provider Details',
          style: TextStyle(
            color: AppColors.heading,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  data.containsKey('ProfilePic') && data['ProfilePic'] != null
                      ? data['ProfilePic']
                      : '',
                ),
                onBackgroundImageError: (_, __) =>
                    AssetImage('assets/images/fallback_image.png'),
              ),
            ),
            SizedBox(height: 24),
            detailItem(FontAwesomeIcons.user, 'First Name', data['FirstName']),
            detailItem(FontAwesomeIcons.user, 'Last Name', data['LastName']),
            detailItem(FontAwesomeIcons.userCircle, 'Username', data['Username']),
            detailItem(FontAwesomeIcons.phone, 'Mobile', data['Mobile']),
            detailItem(FontAwesomeIcons.idCard, 'CNIC', data['CNIC']),
            detailItem(FontAwesomeIcons.suitcase, 'Occupation', data['Occupation']),
            detailItem(FontAwesomeIcons.briefcase, 'Experience', data['Experience']?.toString() ?? 'N/A'),
            detailItemWithExpand(
              FontAwesomeIcons.infoCircle,
              'About',
              data['About'] ?? 'N/A',
            ),
            detailItemWithBulletList(
              FontAwesomeIcons.tasks,
              'Skills',
              data['Skills'] ?? [],
            ),
            detailItem(FontAwesomeIcons.mapMarkerAlt, 'Address', data['Address']),
            SizedBox(height: 24),
            // Center(
            //   child: ElevatedButton.icon(
            //     onPressed: _isDeleting
            //         ? null
            //         : () async {
            //       await _deleteProvider(context, widget.provider.id);
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.red,
            //       padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            //     ),
            //     icon: _isDeleting
            //         ? CircularProgressIndicator(
            //       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            //     )
            //         : Icon(FontAwesomeIcons.trashAlt, size: 16, color: Colors.white),
            //     label: _isDeleting
            //         ? SizedBox()
            //         : Text(
            //       'Delete Provider',
            //       style: TextStyle(fontSize: 16, color: Colors.white),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
  Widget detailItemWithExpand(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blueAccent),
              SizedBox(width: 12),
              Text(
                '$label: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.heading,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            maxLines: 3, // Adjust based on desired truncation
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          if (value.length > 100) // If text is long, show 'Read More' button
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('About'),
                    content: SingleChildScrollView(
                      child: Text(value, style: TextStyle(fontSize: 16)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'Read More',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
        ],
      ),
    );
  }
  Widget detailItemWithBulletList(IconData icon, String label, List<dynamic> skills) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blueAccent),
              SizedBox(width: 12),
              Text(
                '$label: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.heading,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          skills.isNotEmpty
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: skills.map((skill) {
              return Padding(
                padding: const EdgeInsets.only(left: 32.0, bottom: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(width: 8),
                    Text(
                      skill.toString(),
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              );
            }).toList(),
          )
              : Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(
              'No skills provided',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget detailItem(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.heading,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
