# Widget Usage Guide

## CustomAppBar Usage

Replace standard `AppBar` with `CustomAppBar` for proper notch/dynamic island handling.

### Basic Usage:
```dart
import 'package:ref_qeueu/widgets/custom_app_bar.dart';

Scaffold(
  appBar: CustomAppBar(
    title: "My Screen Title",
    showBackButton: true,
  ),
  body: YourContent(),
)
```

### With Actions:
```dart
CustomAppBar(
  title: "Dashboard",
  showBackButton: false,
  actions: [
    IconButton(
      icon: Icon(Icons.notifications),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {},
    ),
  ],
)
```

### Custom Colors:
```dart
CustomAppBar(
  title: "Settings",
  backgroundColor: Colors.purple,
  foregroundColor: Colors.white,
)
```

---

## CustomBottomNav Usage

Add bottom navigation to screens that need it.

### Basic Usage:
```dart
import 'package:ref_qeueu/widgets/bottom_nav.dart';

int _currentIndex = 0;

Scaffold(
  body: YourContent(),
  bottomNavigationBar: CustomBottomNav(
    currentIndex: _currentIndex,
    onTap: (index) {
      setState(() => _currentIndex = index);
      // Handle navigation
      switch(index) {
        case 0:
          // Navigate to home
          break;
        case 1:
          // Navigate to queue
          break;
        case 2:
          // Navigate to profile
          break;
      }
    },
    items: [
      BottomNavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: "Home",
      ),
      BottomNavItem(
        icon: Icons.queue_outlined,
        selectedIcon: Icons.queue,
        label: "Queue",
      ),
      BottomNavItem(
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: "Profile",
      ),
    ],
  ),
)
```

### For Refugee Home Screen:
```dart
items: [
  BottomNavItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: "Home",
  ),
  BottomNavItem(
    icon: Icons.queue_outlined,
    selectedIcon: Icons.queue,
    label: "My Queue",
  ),
  BottomNavItem(
    icon: Icons.history,
    selectedIcon: Icons.history,
    label: "History",
  ),
  BottomNavItem(
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    label: "Profile",
  ),
]
```

### For Doctor Home Screen:
```dart
items: [
  BottomNavItem(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: "Dashboard",
  ),
  BottomNavItem(
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
    label: "Patients",
  ),
  BottomNavItem(
    icon: Icons.medical_services_outlined,
    selectedIcon: Icons.medical_services,
    label: "Consultations",
  ),
  BottomNavItem(
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    label: "Profile",
  ),
]
```

---

## Integration Examples

### Example: Refugee Home Screen with Both Widgets
```dart
class RefugeeHomeScreen extends StatefulWidget {
  const RefugeeHomeScreen({super.key});

  @override
  State<RefugeeHomeScreen> createState() => _RefugeeHomeScreenState();
}

class _RefugeeHomeScreenState extends State<RefugeeHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "My Queue",
        showBackButton: false,
      ),
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: [
          BottomNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: "Home",
          ),
          BottomNavItem(
            icon: Icons.queue_outlined,
            selectedIcon: Icons.queue,
            label: "Queue",
          ),
          BottomNavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return HomeTab();
      case 1:
        return QueueTab();
      case 2:
        return ProfileTab();
      default:
        return HomeTab();
    }
  }
}
```

---

## Benefits

✅ **Safe Area Handling**: Automatically handles notches and dynamic islands
✅ **Consistent Design**: Same look across all screens
✅ **Easy to Use**: Simple API, just replace existing widgets
✅ **Professional**: Polished UI for competition

---

**Note**: These widgets are ready to use. Just import and replace your existing AppBar/BottomNavBar widgets!

