import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/driver_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../theme/app_theme.dart';
import 'vehicle_info_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverProvider>(context, listen: false).fetchProfile();
    });
  }

  void _openEditProfileModal(BuildContext context, DriverProfileModel? profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileBottomSheet(profile: profile),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppTheme.offlineRed),
            SizedBox(width: 8),
            Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text('Are you sure you want to log out of your driver account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.offlineRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final profile = driverProvider.profile;
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + topPadding),
        child: Container(
          color: AppTheme.primaryBlue,
          padding: EdgeInsets.only(top: topPadding),
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                const Text(
                  'Driver Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  tooltip: 'Edit Profile',
                  onPressed: () => _openEditProfileModal(context, profile),
                ),
              ],
            ),
          ),
        ),
      ),
      body: driverProvider.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await driverProvider.fetchProfile();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    // Top Hero Profile Card
                    _buildHeroCard(context, profile, driverProvider.isOnline),
                    const SizedBox(height: 16),

                    // Contact & Personal Info Card
                    _buildPersonalInfoCard(profile),
                    const SizedBox(height: 16),

                    // Driver Work & Identity Details Card
                    _buildWorkDetailsCard(profile),
                    const SizedBox(height: 16),

                    // Vehicle Details Card (if available)
                    if (profile?.vehicle != null) ...[
                      _buildVehicleCard(context, profile!.vehicle!),
                      const SizedBox(height: 16),
                    ],

                    // Dynamic API Extra Details (if any unmapped fields present in response)
                    _buildDynamicExtraDetailsCard(profile?.rawData),
                    const SizedBox(height: 20),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.offlineRed,
                          side: const BorderSide(color: AppTheme.offlineRed, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text(
                          'Logout Account',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _showLogoutConfirmation(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroCard(BuildContext context, DriverProfileModel? profile, bool isOnline) {
    final name = profile != null && profile.name.trim().isNotEmpty ? profile.name.trim() : 'Driver Partner';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';
    final hasPhoto = profile?.photo.isNotEmpty == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                backgroundImage: hasPhoto ? NetworkImage(profile!.photo) : null,
                child: !hasPhoto
                    ? Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isOnline ? AppTheme.onlineGreen : AppTheme.offlineRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            textAlign: TextAlign.center,
          ),
          if (profile?.id.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Driver ID: #${profile!.id}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${profile?.rating ?? 4.8}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isOnline ? AppTheme.onlineGreen : Colors.grey).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isOnline ? AppTheme.onlineGreen : AppTheme.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Profile Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            onPressed: () => _openEditProfileModal(context, profile),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(DriverProfileModel? profile) {
    final mobile = profile != null && profile.mobileNumber.isNotEmpty ? profile.mobileNumber : '--';
    final email = profile != null && profile.email.isNotEmpty ? profile.email : '--';
    final address = profile != null && profile.address.isNotEmpty ? profile.address : '--';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_pin_circle_outlined, color: AppTheme.primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Personal & Contact Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(Icons.phone_outlined, 'Mobile Number', mobile, isCopyable: true),
          const Divider(height: 20),
          _buildInfoRow(Icons.email_outlined, 'Email Address', email),
          const Divider(height: 20),
          _buildInfoRow(Icons.home_outlined, 'Address', address),
          if (profile?.city.isNotEmpty == true || profile?.state.isNotEmpty == true || profile?.pincode.isNotEmpty == true) ...[
            const Divider(height: 20),
            _buildInfoRow(
              Icons.location_city_outlined,
              'City / Region',
              [
                if (profile?.city.isNotEmpty == true) profile!.city,
                if (profile?.state.isNotEmpty == true) profile!.state,
                if (profile?.pincode.isNotEmpty == true) profile!.pincode,
              ].join(', '),
            ),
          ],
          if (profile?.dob.isNotEmpty == true) ...[
            const Divider(height: 20),
            _buildInfoRow(Icons.cake_outlined, 'Date of Birth', profile!.dob),
          ],
          if (profile?.gender.isNotEmpty == true) ...[
            const Divider(height: 20),
            _buildInfoRow(Icons.wc_outlined, 'Gender', profile!.gender),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkDetailsCard(DriverProfileModel? profile) {
    final license = profile != null && profile.licenseNumber.isNotEmpty ? profile.licenseNumber : '--';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.badge_outlined, color: AppTheme.primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Work & License Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(Icons.card_membership_outlined, 'Driving License', license),
          if (profile?.experience.isNotEmpty == true) ...[
            const Divider(height: 20),
            _buildInfoRow(Icons.timeline_outlined, 'Driving Experience', profile!.experience),
          ],
          const Divider(height: 20),
          _buildInfoRow(
            Icons.access_time_filled_outlined,
            'Availability Status',
            profile?.availability.toUpperCase() ?? 'OFFLINE',
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, VehicleModel vehicle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.directions_car_outlined, color: AppTheme.primaryBlue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Assigned Vehicle',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VehicleInfoScreen(vehicle: vehicle)),
                  );
                },
                child: const Text('View All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.model.isNotEmpty ? vehicle.model : 'Vehicle',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.type} • ${vehicle.capacity} Seater',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  vehicle.plateNo.isNotEmpty ? vehicle.plateNo : '--',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicExtraDetailsCard(Map<String, dynamic>? rawData) {
    if (rawData == null || rawData.isEmpty) return const SizedBox.shrink();

    // Filter out standard keys that are already shown above or sensitive internal keys
    const excludedKeys = {
      'id', 'driver_id', 'name', 'driver_name', 'fullName', 'email',
      'mobile', 'mobile_number', 'mobileNumber', 'phone', 'address',
      'city', 'state', 'pincode', 'pin_code', 'zip',
      'license_number', 'license_no', 'driving_license',
      'photo', 'profile_image', 'image',
      'availability', 'status', 'gender', 'dob', 'date_of_birth',
      'experience', 'rating', 'vehicle', 'password', 'token', 'access_token',
      'created_at', 'updated_at', 'deleted_at',
    };

    final extraEntries = rawData.entries.where((entry) {
      final key = entry.key.toLowerCase();
      final val = entry.value;
      if (excludedKeys.contains(key)) return false;
      if (val == null || val.toString().trim().isEmpty) return false;
      if (val is Map || val is List) return false;
      return true;
    }).toList();

    if (extraEntries.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Other Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ],
          ),
          const Divider(height: 24),
          ...extraEntries.map((entry) {
            final formattedKey = entry.key
                .replaceAll('_', ' ')
                .split(' ')
                .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
                .join(' ');

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildInfoRow(Icons.label_outline, formattedKey, entry.value.toString()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isCopyable = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
            ],
          ),
        ),
        if (isCopyable && value.isNotEmpty && value != '--')
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
            icon: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.primaryBlue),
            tooltip: 'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied to clipboard'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _EditProfileBottomSheet extends StatefulWidget {
  final DriverProfileModel? profile;
  const _EditProfileBottomSheet({this.profile});

  @override
  State<_EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _emailController = TextEditingController(text: widget.profile?.email ?? '');
    _mobileController = TextEditingController(text: widget.profile?.mobileNumber ?? '');
    _addressController = TextEditingController(text: widget.profile?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final success = await driverProvider.editProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppTheme.onlineGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(driverProvider.error ?? 'Failed to update profile'),
          backgroundColor: AppTheme.offlineRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_note_rounded, color: AppTheme.primaryBlue, size: 26),
                      SizedBox(width: 8),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 16),
              const SizedBox(height: 8),

              // Full Name Field
              const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter full name',
                  prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primaryBlue),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Name cannot be empty';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Mobile Number Field
              const Text('Mobile Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter mobile number',
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.primaryBlue),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Mobile number cannot be empty';
                  if (val.trim().length < 10) return 'Enter a valid 10-digit number';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Email Address Field
              const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter email address',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryBlue),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Email cannot be empty';
                  if (!val.contains('@') || !val.contains('.')) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Address Field
              const Text('Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter complete address',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.home_outlined, color: AppTheme.primaryBlue),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Address cannot be empty';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: driverProvider.isLoading ? null : _submitUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: driverProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Save & Update Profile',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

