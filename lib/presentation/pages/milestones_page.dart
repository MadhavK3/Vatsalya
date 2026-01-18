import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/data/models/milestone_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';

class MilestonesPage extends ConsumerStatefulWidget {
  const MilestonesPage({super.key});

  @override
  ConsumerState<MilestonesPage> createState() => _MilestonesPageState();
}

class _MilestonesPageState extends ConsumerState<MilestonesPage> with TickerProviderStateMixin {
  late AnimationController _xpController;
  late AnimationController _cupController;
  late Animation<double> _xpOpacity;
  late Animation<Offset> _xpSlide;
  late Animation<double> _cupScale;
  late Animation<double> _cupRotate;
  bool _showXp = false;
  bool _showCup = false;

  @override
  void initState() {
    super.initState();
    _xpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _xpOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_xpController);

    _xpSlide = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -2),
    ).animate(CurvedAnimation(parent: _xpController, curve: Curves.easeOut));

    _cupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _cupScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.2),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_cupController);

    _cupRotate = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -0.2, end: 0.2), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.2, end: -0.2), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.2, end: 0.2), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 0.0), weight: 25),
    ]).animate(_cupController);

    _xpController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showXp = false);
        _xpController.reset();
      }
    });

    _cupController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showCup = false);
        _cupController.reset();
      }
    });
  }

  @override
  void dispose() {
    _xpController.dispose();
    _cupController.dispose();
    super.dispose();
  }

  void _triggerXpAnimation() {
    setState(() => _showXp = true);
    _xpController.forward();
  }

  void _triggerCupAnimation() {
    setState(() => _showCup = true);
    _cupController.forward();
  }

  Future<void> _toggleMilestone(MilestoneModel milestone, bool? value) async {
    // 1. Update Repo
    final repo = await ref.read(milestoneRepositoryProvider.future);
    await repo.toggleCompletion(milestone.id, value ?? false);
    
    // 2. Refresh Provider to update UI
    ref.refresh(milestoneRepositoryProvider);

    // 3. Trigger Animations
    if (value == true) {
      _triggerXpAnimation();
      
      // Check if all are now completed
      final allMilestones = repo.getAllMilestones();
      final allCompleted = allMilestones.every((m) => m.isCompleted);
      if (allCompleted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _triggerCupAnimation();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final milestoneAsync = ref.watch(milestoneRepositoryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text('Milestones Journey'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.blueGrey[800],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF8E1), // Light Amber
                  Color(0xFFFFF3E0), // Light Orange
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: milestoneAsync.when(
              data: (repo) {
                final allMilestones = repo.getAllMilestones();
                final completedCount = allMilestones.where((m) => m.isCompleted).length;
                final xp = completedCount * 50;
                // Dummy Level Logic: Level 1 (0-150), Level 2 (150-300), etc.
                final level = (xp / 150).floor() + 1;
                final progress = (xp % 150) / 150;

                return Column(
                  children: [
                    // XP/Level Header
                    _buildLevelHeader(level, xp, progress),
                    
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: allMilestones.length,
                        itemBuilder: (context, index) {
                          final m = allMilestones[index];
                          return _buildMilestoneTile(m);
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
          
          // XP Overlay Animation
          if (_showXp)
            Center(
              child: SlideTransition(
                position: _xpSlide,
                child: FadeTransition(
                  opacity: _xpOpacity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 60),
                      Text(
                        '+50 XP',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.amber[800],
                          fontWeight: FontWeight.w900,
                          shadows: [
                            const Shadow(offset: Offset(0, 2), blurRadius: 4, color: Colors.black12)
                          ]
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Cup/Trophy Animation
          if (_showCup)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: AnimatedBuilder(
                  animation: _cupController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _cupScale.value,
                      child: Transform.rotate(
                        angle: _cupRotate.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.amber, size: 150),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
                                ]
                              ),
                              child: Text(
                                'ALL MILESTONES ACHIEVED!',
                                style: TextStyle(
                                  color: Colors.amber[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLevelHeader(int level, int xp, double progress) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LEVEL $level', 
                    style: TextStyle(
                      color: Colors.amber[800], 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1.5
                    )
                  ),
                  const SizedBox(height: 4),
                  Text('$xp Total XP', 
                    style: TextStyle(color: Colors.blueGrey[600], fontSize: 12)
                  ),
                ],
              ),
              Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.amber[100],
                   shape: BoxShape.circle,
                 ),
                 child: Icon(Icons.emoji_events, color: Colors.amber[800], size: 30),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.amber[50],
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% to Level ${level + 1}',
            style: TextStyle(color: Colors.blueGrey[400], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneTile(MilestoneModel m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: m.isCompleted ? Colors.amber.withOpacity(0.5) : Colors.white,
          width: 2
        ),
      ),
      child: CheckboxListTile(
        value: m.isCompleted,
        onChanged: (val) => _toggleMilestone(m, val),
        title: Text(
          m.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: m.isCompleted ? TextDecoration.lineThrough : null,
            color: m.isCompleted ? Colors.blueGrey[300] : Colors.blueGrey[800],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.description != null) 
              Text(m.description!, style: TextStyle(
                fontSize: 12, 
                color: Colors.blueGrey[400],
                 decoration: m.isCompleted ? TextDecoration.lineThrough : null,
              )),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${m.ageMonthsMin}-${m.ageMonthsMax} mo',
                style: TextStyle(fontSize: 10, color: Colors.blueGrey[600], fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        activeColor: Colors.amber,
        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCategoryColor(m.category).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_getCategoryIcon(m.category), color: _getCategoryColor(m.category), size: 20),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'motor': return Colors.blue;
      case 'social': return Colors.pink;
      case 'language': return Colors.purple;
      case 'cognitive': return Colors.green;
      default: return Colors.orange;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'motor': return Icons.directions_run;
      case 'social': return Icons.sentiment_satisfied_alt;
      case 'language': return Icons.record_voice_over;
      case 'cognitive': return Icons.psychology;
      default: return Icons.star;
    }
  }
}
