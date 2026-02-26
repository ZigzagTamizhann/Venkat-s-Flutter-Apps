import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sign_data.dart';
import '../services/user_progress_service.dart';
import '../widgets/avatar_display.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({Key? key}) : super(key: key);

  static final List<Story> _stories = [
    Story(
      title: 'The Helpful Friend',
      chapter: 'Chapter 1',
      moral: 'Helping others makes everyone happy!',
      scenes: [
        StoryScene(
          avatarEmotion: 'happy',
          signText: 'HELLO FRIEND',
          narrative: 'Signa meets a new friend at school.',
          interactionPrompt: 'Practice sign: HELLO',
          practiceSign: 'HELLO',
        ),
        StoryScene(
          avatarEmotion: 'happy',
          signText: 'WANT HELP',
          narrative: 'The friend needs help carrying books.',
          interactionPrompt: 'Practice sign: HELP',
          practiceSign: 'HELP',
        ),
        StoryScene(
          avatarEmotion: 'happy',
          signText: 'THANK YOU',
          narrative: 'The friend is grateful for the help!',
          interactionPrompt: 'Practice sign: THANK YOU',
          practiceSign: 'THANK',
        ),
      ],
    ),
    Story(
      title: 'The Lost Teddy',
      chapter: 'Chapter 2',
      moral: "It's okay to ask for help!",
      scenes: [
        StoryScene(
          avatarEmotion: 'sad',
          signText: 'MY TEDDY WHERE',
          narrative: 'Signa lost favorite teddy bear.',
          interactionPrompt: 'Practice sign: WHERE',
          practiceSign: 'WHERE',
        ),
        StoryScene(
          avatarEmotion: 'sad',
          signText: 'HELP PLEASE',
          narrative: 'Signa asks mother for help.',
          interactionPrompt: 'Practice sign: HELP',
          practiceSign: 'HELP',
        ),
        StoryScene(
          avatarEmotion: 'happy',
          signText: 'FOUND THANK YOU',
          narrative: 'Mother helps find teddy! Signa is happy!',
          interactionPrompt: 'Practice sign: THANK YOU',
          practiceSign: 'THANK',
        ),
      ],
    ),
    Story(
      title: 'Sharing is Caring',
      chapter: 'Chapter 3',
      moral: 'Sharing makes friendships stronger!',
      scenes: [
        StoryScene(
          avatarEmotion: 'happy',
          signText: 'I HAVE APPLE',
          narrative: 'Signa has a delicious apple for lunch.',
          interactionPrompt: 'Practice sign: APPLE',
          practiceSign: 'APPLE',
        ),
        StoryScene(
          avatarEmotion: 'happy',
          signText: 'YOU WANT SHARE',
          narrative: 'Signa sees friend without lunch.',
          interactionPrompt: 'Practice sign: SHARE',
          practiceSign: 'SHARE',
        ),
        StoryScene(
          avatarEmotion: 'happy',
          signText: 'HAPPY FRIENDS',
          narrative: 'Both friends share and enjoy together!',
          interactionPrompt: 'Practice sign: FRIEND',
          practiceSign: 'FRIEND',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 My Stories'),
        backgroundColor: Colors.blue[400],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[200]!,
              Colors.purple[200]!,
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _stories.length,
          itemBuilder: (context, index) {
            final story = _stories[index];
            return _buildStoryCard(context, story, index);
          },
        ),
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, Story story, int index) {
    final colors = [Colors.blue, Colors.purple, Colors.teal];
    final color = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoryDetailScreen(story: story),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    size: 40,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.chapter,
                        style: TextStyle(
                          fontSize: 14,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        story.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${story.scenes.length} scenes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StoryDetailScreen extends StatefulWidget {
  final Story story;

  const StoryDetailScreen({Key? key, required this.story}) : super(key: key);

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  int _currentSceneIndex = 0;
  bool _hasInteracted = false;

  StoryScene get _currentScene => widget.story.scenes[_currentSceneIndex];
  bool get _isLastScene => _currentSceneIndex == widget.story.scenes.length - 1;

  void _nextScene() {
    if (!_hasInteracted && _currentScene.interactionPrompt != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Practice the sign first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isLastScene) {
      _completeStory();
    } else {
      setState(() {
        _currentSceneIndex++;
        _hasInteracted = false;
      });
    }
  }

  void _completeStory() {
    final progressService = Provider.of<UserProgressService>(context, listen: false);
    progressService.completeStory();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '🎉 Story Complete!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 15),
            Text(
              'MORAL: ${widget.story.moral}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              '+20 points earned!',
              style: TextStyle(
                fontSize: 20,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Finish',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressService = Provider.of<UserProgressService>(context);
    final avatar = progressService.avatar!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
        backgroundColor: Colors.blue[400],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[100]!,
              Colors.purple[100]!,
            ],
          ),
        ),
        child: Column(
          children: [
            // Progress
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scene ${_currentSceneIndex + 1}/${widget.story.scenes.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold, 
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentSceneIndex + 1) / widget.story.scenes.length,
                    ),
                  ),
                ],
              ),
            ),

            // Story Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          AvatarDisplay(
                            avatar: avatar,
                            size: 150,
                            emotion: _currentScene.avatarEmotion,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _currentScene.signText,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Narrative
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentScene.narrative,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Interaction
                    if (_currentScene.interactionPrompt != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '👋 INTERACT',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _currentScene.interactionPrompt!,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _hasInteracted = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Great signing! +5 points 🎉'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                _hasInteracted ? '✓ Done!' : 'Practice Sign',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Next Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextScene,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    _isLastScene ? 'Finish Story' : 'Next Scene →',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
