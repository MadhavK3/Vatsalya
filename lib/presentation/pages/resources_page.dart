import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/data/models/resource_article_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_provider.dart';
import 'package:maternal_infant_care/presentation/widgets/resource_card.dart';
import 'package:maternal_infant_care/presentation/pages/careflow_ai_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:maternal_infant_care/presentation/pages/disease_awareness_page.dart';
import 'package:maternal_infant_care/presentation/pages/nutrition_guidance_page.dart';
import 'package:maternal_infant_care/presentation/pages/daily_tips_page.dart';
import 'package:maternal_infant_care/presentation/pages/hospital_bag_page.dart';

class ResourcesPage extends ConsumerStatefulWidget {
  const ResourcesPage({super.key});

  @override
  ConsumerState<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends ConsumerState<ResourcesPage> {
  String searchQuery = '';
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Baby Care',
    'Health',
    'Nutrition',
    'Development',
    'Mother Care'
  ];

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final allArticles = _getArticles(userProfile);
    
    // Filter articles based on search and category
    final filteredArticles = allArticles.where((article) {
      final matchesSearch = article.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          article.description.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'All' || article.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Resources'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF4A4A4A),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        ),
      ),
      body: Stack(
        children: [
          // Background: Parchment (scaffold background handles this in theme, but ensuring here)
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          
          CustomScrollView(
            slivers: [
              // Add top padding for status bar + transparency
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
              ),
              
              SliverToBoxAdapter(
                child: _buildSearchAndFilters(context),
              ),
              
              filteredArticles.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(context),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Build rows of 2 items each
                            final startIndex = index * 2;
                            if (startIndex >= filteredArticles.length) return null;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ResourceCard(article: filteredArticles[startIndex]),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: startIndex + 1 < filteredArticles.length
                                        ? ResourceCard(article: filteredArticles[startIndex + 1])
                                        : const SizedBox(),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: (filteredArticles.length / 2).ceil(),
                        ),
                      ),
                    ),
              
              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const VatsalyaAiPage()),
          );
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Ask AI'),
        heroTag: 'fab_resources',
        // Theme handles FAB style, but ensuring high contrast if needed
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting / Hero Section
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Discover Helpful\nInsights & Guides ✨',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
            ),
          ),
          
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search for articles...',
                hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Explore Guides Section
          Text(
            'Explore Guides',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            padding: EdgeInsets.zero,
            children: [
              _CategoryCard(
                title: 'Medical',
                icon: Icons.medical_services_outlined,
                color: Colors.redAccent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiseaseAwarenessPage())),
              ),
              _CategoryCard(
                title: 'Nutrition',
                icon: Icons.restaurant_menu,
                color: Colors.orangeAccent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionGuidancePage())),
              ),
              _CategoryCard(
                title: 'Daily Tips',
                icon: Icons.lightbulb_outline,
                color: Colors.green,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyTipsPage())),
              ),
              _CategoryCard(
                title: 'Labour Prep',
                icon: Icons.child_friendly,
                color: Colors.blueAccent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalBagPage())),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Category Chips
          Text(
            'Browse Articles',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => selectedCategory = category);
                    },
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.5),
                    selectedColor: isDark ? const Color(0xFF4A148C) : const Color(0xFFE1BEE7),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: isSelected 
                        ? (isDark ? Colors.white : const Color(0xFF4A148C))
                        : (isDark ? Colors.white70 : const Color(0xFF455A64)),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected 
                          ? Colors.transparent 
                          : (isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8)),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No resources found',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<ResourceArticleModel> _getArticles(UserProfileType? type) {
    if (type == UserProfileType.pregnant) {
      return [
        const ResourceArticleModel(
          id: 'preg1',
          title: 'Week-by-Week Guide',
          description: 'Track your baby\'s development journey.',
          icon: Icons.calendar_month,
          color: Color(0xFFF48FB1), // Soft Pink
          category: 'Development',
          readingTime: '5 min',
          content: '''
# Week-by-Week Pregnancy Guide

## First Trimester (Week 1-12)
Your body is undergoing major changes. You might experience nausea, fatigue, and tender breasts.

*   **Week 4:** Baby is the size of a poppy seed.
*   **Week 8:** Baby is the size of a kidney bean.
*   **Week 12:** Baby is the size of a lime.

## Second Trimester (Week 13-26)
Often called the "honeymoon period," your energy may return.

*   **Week 16:** Baby is the size of an avocado.
*   **Week 20:** Halfway there! Baby is the size of a banana.
*   **Week 24:** Baby is the size of a cantaloupe.

## Third Trimester (Week 27-40)
The final stretch! You may feel more uncomfortable as baby grows.

*   **Week 28:** Baby is the size of an eggplant.
*   **Week 36:** Baby is the size of a papaya.
*   **Week 40:** Welcome baby! Size of a watermelon.
''',
        ),
        const ResourceArticleModel(
          id: 'preg2',
          title: 'Pregnancy Nutrition',
          description: 'Eating healthy for two: Essential nutrients.',
          icon: Icons.restaurant_menu,
          color: Color(0xFFA5D6A7), // Soft Green
          category: 'Nutrition',
          readingTime: '4 min',
          content: '''
# Nutrition During Pregnancy

Eating a balanced diet is crucial for your baby's development.

## Key Nutrients
*   **Folic Acid:** Prevents birth defects. Found in leafy greens and fortified cereals.
*   **Iron:** Supports increased blood volume. Found in red meat, beans, and spinach.
*   **Calcium:** Builds strong bones. Found in dairy products and tofu.
*   **Protein:** Essential for growth. Found in lean meats, eggs, and nuts.

## Foods to Avoid
*   Raw or undercooked seafood/eggs
*   Unpasteurized dairy
*   High-mercury fish (shark, swordfish)
*   Excess caffeine
''',
        ),
        const ResourceArticleModel(
          id: 'preg3',
          title: 'Labor Preparation',
          description: 'Signs of labor and hospital bag checklist.',
          icon: Icons.pregnant_woman,
          color: Color(0xFFCE93D8), // Soft Purple
          category: 'Health',
          readingTime: '6 min',
          content: '''
# Preparing for Labor

## Signs of Labor
1.  **Contractions:** Regular, stronger, and closer together.
2.  **Water Breaking:** A gush or trickle of fluid.
3.  **Back Pain:** Persistent lower back ache.
4.  **Bloody Show:** Loss of mucus plug.

## Hospital Bag Checklist
*   **For Mom:** Comfortable clothes, toiletries, nursing bra, snacks, ID/insurance cards.
*   **For Baby:** Going-home outfit, car seat, blanket, diapers.
*   **For Partner:** Change of clothes, snacks, phone charger.
''',
        ),
        const ResourceArticleModel(
          id: 'preg4',
          title: 'Safe Exercises',
          description: 'Staying active safely during pregnancy.',
          icon: Icons.fitness_center,
          color: Color(0xFF90CAF9), // Soft Blue
          category: 'Health',
          readingTime: '5 min',
          content: '''
# Safe Exercises During Pregnancy

Staying active is healthy for both you and your baby! It can improve mood, sleep, and even make labor easier.

## Recommended Activities
*   **Walking:** The perfect low-impact exercise. Easy on the joints and can be done anywhere.
*   **Swimming:** Water supports your weight, relieving back tension and preventing overheating.
*   **Prenatal Yoga:** Great for flexibility, breathing (useful for labor!), and relaxation.
*   **Pilates:** Focuses on core strength, which helps support your growing belly.

## Trimester Specific Tips
*   **First Trimester:** Don't overdo it. Listen to your body and rest if you feel nauseous or fatigued.
*   **Second Trimester:** Avoid exercises lying flat on your back, as this can reduce blood flow.
*   **Third Trimester:** Focus on pelvic floor exercises (Kegels) and gentle movements.

## ⚠️ Stop Exercising If You Experience:
*   Dizziness or feeling faint.
*   Shortness of breath before starting exercise.
*   Chest pain or headache.
*   Vaginal bleeding or fluid leaking.
*   Calf pain or swelling.

*Always consult your doctor before starting any new exercise routine.*
''',
        ),
         const ResourceArticleModel(
          id: 'preg5',
          title: 'Mental Wellness',
          description: 'Managing stress and emotions.',
          icon: Icons.spa,
          color: Color(0xFF80CBC4), // Soft Teal
          category: 'Mother Care',
          readingTime: '6 min',
          content: '''
# Your Mental Wellness Matters

Pregnancy is a time of huge transition. It's completely normal to feel a mix of excitement, anxiety, and everything in between.

## Managing Your Emotions
*   **Acknowledge Your Feelings:** Don't judge yourself for feeling anxious or overwhelmed. 
*   **Talk it Out:** Share your thoughts with your partner, a friend, or a support group.
*   **Limit "Information Overload":** Constant googling can increase anxiety. Stick to trusted sources like Vatsalya.
*   **Self-Care Rituals:** Whether it's a warm bath, reading, or listening to music, make time for things you love.

## Stress Relief Techniques
1.  **Box Breathing:** Inhale for 4s, hold for 4s, exhale for 4s, hold for 4s.
2.  **Mindfulness:** Try to focus on the present moment during daily tasks.
3.  **Journaling:** Writing down your thoughts can help clear your mind.

## When to Seek Professional Support
It's time to talk to a doctor or therapist if you experience:
*   Persistent sadness or hopelessness.
*   Constant, overwhelming worry.
*   Loss of interest in things you used to enjoy.
*   Changes in appetite or sleep patterns not related to pregnancy.

*You are not alone. Reaching out is a sign of strength.*
''',
        ),
        const ResourceArticleModel(
          id: 'preg6',
          title: 'Breastfeeding 101',
          description: 'Basics of latching, positions, and supply.',
          icon: Icons.baby_changing_station,
          color: Color(0xFFCE93D8), // Soft Purple
          category: 'Baby Care',
          readingTime: '7 min',
          content: '''
# Breastfeeding 101

## The Basics
Breastfeeding is a learned skill for both you and baby.

## Tips for Success
*   **Skin-to-Skin:** Helps bonding and milk flow.
*   **Good Latch:** Nipple should be deep in baby's mouth.
*   **Feed on Demand:** Watch for hunger cues (rooting, sucking hands).
*   **Hydration:** Drink plenty of water.

If it hurts, break suction and try again. Don't hesitate to see a lactation consultant.
''',
        ),
        const ResourceArticleModel(
          id: 'preg7',
          title: 'Postpartum Recovery',
          description: 'Healing your body after birth.',
          icon: Icons.healing,
          color: Color(0xFFFFCC80), // Soft Orange
          category: 'Mother Care',
          readingTime: '5 min',
          content: '''
# Postpartum Recovery

## What to Expect
*   **Lochia:** Bleeding for 4-6 weeks is normal.
*   **Cramping:** Uterus shrinking back to size.
*   **Soreness:** Perineal or C-section incision pain.

## Self-Care
*   Rest as much as possible.
*   Use a peri bottle for hygiene.
*   Eat nourishing, warm meals.
*   Gentle walking when ready.
''',
        ),
      ];
    } else {
      return [
        const ResourceArticleModel(
          id: 'tod1',
          title: 'Developmental Milestones',
          description: 'What to expect 1-3 years.',
          icon: Icons.accessibility,
          color: Color(0xFFFFCC80), // Soft Orange
          category: 'Development',
          readingTime: '5 min',
          content: '''
# Toddler Milestones

## 12 Months
*   Pulls up to stand
*   Cruises or takes first steps
*   Says "mama" or "dada"

## 18 Months
*   Walks alone
*   Drinks from a cup
*   Points to show interest

## 2 Years
*   Kicks a ball
*   Speaks in short sentences (2-4 words)
*   Follows simple instructions
''',
        ),
        const ResourceArticleModel(
          id: 'tod2',
          title: 'Feeding Guide',
          description: 'Solids, snacks and dealing with picky eaters.',
          icon: Icons.child_care,
          color: Color(0xFF80CBC4), // Soft Teal
          category: 'Nutrition',
          readingTime: '4 min',
          content: '''
# Feeding Your Toddler

Offer a variety of foods. It's normal for appetite to fluctuate. Avoid force-feeding. Offer 3 meals and 2 snacks daily.
''',
        ),
        const ResourceArticleModel(
          id: 'tod3',
          title: 'Sleep Training',
          description: 'Tips for better nights and naps.',
          icon: Icons.bedtime,
          color: Color(0xFF9FA8DA), // Soft Indigo
          category: 'Baby Care',
          readingTime: '5 min',
          content: '''
# Sleep Tips

Establish a consistent bedtime routine. Keep the room dark and cool. Be patient with regressions. Aim for 11-14 hours of sleep total.
''',
        ),
        const ResourceArticleModel(
          id: 'tod4',
          title: 'Vaccination Schedule',
          description: 'Immunization checklist and guide.',
          icon: Icons.vaccines,
          color: Color(0xFFEF9A9A), // Soft Red
          category: 'Health',
          readingTime: '2 min',
          content: '''
# Vaccinations

Check with your pediatrician for the standard schedule (e.g., MMR, Varicella, DTaP boosters). Keep your records updated.
''',
        ),
        const ResourceArticleModel(
          id: 'tod5',
          title: 'Potty Training',
          description: 'Signs of readiness and tips.',
          icon: Icons.wc,
          color: Color(0xFFCE93D8), // Soft Purple
          category: 'Baby Care',
          readingTime: '4 min',
          content: '''
# Potty Training

Most children are ready between 2 and 3 years old. Look for signs like staying dry for longer periods and showing interest in the bathroom.
''',
        ),
      ];
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5)
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white : const Color(0xFF2D3142)
              )
            ),
          ],
        ),
      ),
    );
  }
}
