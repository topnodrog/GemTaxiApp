import 'package:flutter/material.dart';
import '../../core/constants/theme.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(context),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildGridContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: GemTheme.accentGrey,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.diamond_outlined, color: GemTheme.primaryGreen, size: 48),
          const SizedBox(height: 8),
          const Text(
            "Gem Dispatch",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _sidebarItem(Icons.dashboard, "Dashboard", active: true),
          _sidebarItem(Icons.map, "God Mode Map"),
          _sidebarItem(Icons.people, "Manage Drivers"),
          _sidebarItem(Icons.history, "Ride History"),
          _sidebarItem(Icons.account_balance_wallet, "Financials"),
          const Spacer(),
          _sidebarItem(Icons.settings, "Settings"),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, {bool active = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: active ? GemTheme.primaryGreen.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: active ? GemTheme.primaryGreen : Colors.white70),
        title: Text(
          title,
          style: TextStyle(color: active ? Colors.white : Colors.white70, fontWeight: active ? FontWeight.bold : FontWeight.normal),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: const Row(
        children: [
          Text("Burlington Fleet Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Spacer(),
          Icon(Icons.notifications_none),
          SizedBox(width: 20),
          CircleAvatar(backgroundColor: GemTheme.primaryGreen, child: Text("JS")),
          SizedBox(width: 8),
          Text("Admin User"),
        ],
      ),
    );
  }

  Widget _buildGridContent() {
    return Column(
      children: [
        Row(
          children: [
            _statCard("Active Drivers", "42", Icons.drive_eta, Colors.blue),
            _statCard("Ongoing Rides", "12", Icons.map, Colors.orange),
            _statCard("Pending Requests", "5", Icons.pending_actions, Colors.red),
            _statCard("Total Earnings (CAD)", "\$3,240.00", Icons.attach_money, Colors.green),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Placeholder for Live Map
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, size: 48, color: GemTheme.primaryGreen),
                        SizedBox(height: 16),
                        Text("God Mode Map View coming soon", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Recent Activity Table Placeholder
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Recent Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 16),
                      Text("• Driver J. Smith went online"),
                      SizedBox(height: 8),
                      Text("• New ride requested near Burlington GO"),
                      SizedBox(height: 8),
                      Text("• Ride #1284 completed"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
