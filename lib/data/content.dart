// Static, offline content for the Learn tab and Home facts.

class LearnSection {
  const LearnSection(this.heading, this.body, {this.bullets = const []});
  final String heading;
  final String body;
  final List<String> bullets;
}

class LearnArticle {
  const LearnArticle({
    required this.title,
    required this.emoji,
    required this.summary,
    required this.sections,
  });
  final String title;
  final String emoji;
  final String summary;
  final List<LearnSection> sections;
}

const List<String> chickenFacts = [
  'A hen turns her eggs about 50 times a day while nesting.',
  'Chickens can recognize over 100 individual faces — people and other hens.',
  'Hens "sing" an egg song, a proud cackle, right after laying.',
  'The colour of an egg depends on the breed, not on nutrition.',
  'Chickens have full-colour vision and even see some ultraviolet light.',
  'A hen needs about 4 hours of daylight to build a single egg.',
  'Chickens dream — they have REM sleep just like people.',
  'A flock has a real "pecking order" that keeps daily life peaceful.',
  'Hens prefer to lay in a nest that already has an egg in it.',
  'Chickens can run up to about 9 mph (14 km/h) in a sprint.',
  'A happy dust bath keeps feathers clean and mites away.',
  'Fresh, clean water can boost egg production more than almost anything.',
];

const List<LearnArticle> learnArticles = [
  LearnArticle(
    title: 'Feeding Guide',
    emoji: '🌽',
    summary: 'What, when and how much to feed at every age.',
    sections: [
      LearnSection(
        'Chicks (0–8 weeks)',
        'Start with a "starter" crumble that is high in protein to fuel fast '
            'growth. Keep feed and fresh water available at all times.',
        bullets: [
          'Protein: ~20–22%',
          'Typical intake: ~40–50 g per bird / day',
          'Use a shallow chick feeder to avoid waste',
        ],
      ),
      LearnSection(
        'Growers (8–20 weeks)',
        'Switch to a "grower" feed with a bit less protein so birds develop '
            'steadily without laying too early.',
        bullets: [
          'Protein: ~16–18%',
          'Typical intake: ~80–100 g per bird / day',
          'Avoid layer feed until first eggs (too much calcium)',
        ],
      ),
      LearnSection(
        'Layers (20+ weeks)',
        'Move to "layer" feed with added calcium for strong shells. Offer '
            'oyster shell on the side so hens self-regulate.',
        bullets: [
          'Protein: ~16–18% + calcium',
          'Typical intake: ~110–130 g per bird / day',
          'Provide grit to help digestion',
        ],
      ),
      LearnSection(
        'Treats & extras',
        'Treats should stay under ~10% of the diet so the balanced feed still '
            'does its job.',
        bullets: [
          'Great: leafy greens, pumpkin, mealworms',
          'Avoid: avocado, raw beans, salty or moldy food',
          'Always keep clean water within reach',
        ],
      ),
    ],
  ),
  LearnArticle(
    title: 'Popular Breeds',
    emoji: '🐔',
    summary: 'Egg output and temperament of common backyard hens.',
    sections: [
      LearnSection(
        'Rhode Island Red',
        'Hardy, dependable and beginner-friendly. Lays large brown eggs and '
            'handles cold well.',
        bullets: ['~250–300 eggs/year', 'Brown eggs', 'Calm & hardy'],
      ),
      LearnSection(
        'Leghorn',
        'The classic white-egg machine. Active, lightweight and efficient on '
            'feed.',
        bullets: ['~280–320 eggs/year', 'White eggs', 'Energetic'],
      ),
      LearnSection(
        'Plymouth Rock',
        'Friendly dual-purpose bird with striking barred feathers, great for '
            'families.',
        bullets: ['~200–280 eggs/year', 'Brown eggs', 'Docile'],
      ),
      LearnSection(
        'Orpington',
        'Big, fluffy and gentle — a favourite lap chicken that tolerates '
            'handling.',
        bullets: ['~180–220 eggs/year', 'Brown eggs', 'Very friendly'],
      ),
      LearnSection(
        'Silkie',
        'Ornamental, fluffy and famously broody. More pet than producer.',
        bullets: ['~100–120 eggs/year', 'Cream eggs', 'Sweet & broody'],
      ),
    ],
  ),
  LearnArticle(
    title: 'Health & Care',
    emoji: '❤️',
    summary: 'Keep your flock happy, clean and thriving.',
    sections: [
      LearnSection(
        'Signs of a healthy hen',
        'A healthy bird is alert and active with a bright red comb.',
        bullets: [
          'Clear, bright eyes',
          'Smooth, glossy feathers',
          'Good appetite & steady laying',
          'Clean vent, no discharge',
        ],
      ),
      LearnSection(
        'Common problems',
        'Catching issues early keeps the whole flock safe.',
        bullets: [
          'Mites & lice — check under wings & vent',
          'Worms — watch for weight loss',
          'Respiratory — sneezing or wheezing',
          'Isolate sick birds promptly',
        ],
      ),
      LearnSection(
        'Space & hygiene',
        'Crowding causes stress and disease. Give birds room and keep bedding '
            'dry.',
        bullets: [
          '~4 sq ft indoors per bird',
          '~8–10 sq ft in the run per bird',
          'Clean bedding regularly',
          'Provide a dry dust-bath area',
        ],
      ),
    ],
  ),
  LearnArticle(
    title: 'Egg Production',
    emoji: '🥚',
    summary: 'What drives laying and how to store eggs well.',
    sections: [
      LearnSection(
        'When hens lay',
        'Most hens begin laying around 18–22 weeks and peak in their first '
            'one to two years.',
        bullets: [
          'Daylight: ~14–16 h supports laying',
          'Production naturally dips in winter & molt',
        ],
      ),
      LearnSection(
        'Boosting laying',
        'Consistency is everything — steady food, water, light and low stress.',
        bullets: [
          'Balanced layer feed + calcium',
          'Fresh water at all times',
          'Calm, predator-free coop',
          'Clean, inviting nesting boxes',
        ],
      ),
      LearnSection(
        'Storing eggs',
        'Fresh eggs keep for weeks when handled well.',
        bullets: [
          'Only wash right before use',
          'Store pointed-end down',
          'Refrigerate for longest freshness',
          'Float test: fresh eggs sink',
        ],
      ),
    ],
  ),
  LearnArticle(
    title: 'Coop & Environment',
    emoji: '🏡',
    summary: 'Design a safe, comfortable home for your birds.',
    sections: [
      LearnSection(
        'Nesting boxes',
        'Give hens quiet, dim spots to lay so eggs stay clean and unbroken.',
        bullets: [
          '1 box per 3–4 hens',
          'Soft, clean bedding',
          'Slightly raised off the floor',
        ],
      ),
      LearnSection(
        'Roosting',
        'Chickens instinctively sleep up high on bars.',
        bullets: [
          '~8 inches of bar per bird',
          'Higher than the nesting boxes',
          'Rounded, splinter-free perches',
        ],
      ),
      LearnSection(
        'Protection',
        'A secure coop is the best defence against predators and weather.',
        bullets: [
          'Use hardware cloth, not chicken wire',
          'Lock up at dusk',
          'Good ventilation without drafts',
        ],
      ),
    ],
  ),
];
