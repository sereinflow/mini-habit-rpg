enum ShopItemType {
  outfit,
  hairstyle,
  accessory,
  theme,
  consumable;

  String get label {
    switch (this) {
      case ShopItemType.outfit:
        return 'Outfit';
      case ShopItemType.hairstyle:
        return 'Hairstyle';
      case ShopItemType.accessory:
        return 'Accessory';
      case ShopItemType.theme:
        return 'Theme';
      case ShopItemType.consumable:
        return 'Consumable';
    }
  }
}

class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.type,
    required this.icon,
    required this.rarity,
  });

  final String id;
  final String name;
  final String description;
  final int cost;
  final ShopItemType type;
  final String icon;
  final String rarity;

  static const List<ShopItem> catalog = [
    // Outfits
    ShopItem(
      id: 'outfit_knight',
      name: 'Knight\'s Plate',
      description: 'Sturdy steel plate for protection.',
      cost: 100,
      type: ShopItemType.outfit,
      icon: '🛡️',
      rarity: 'Rare',
    ),
    ShopItem(
      id: 'outfit_mage',
      name: 'Archmage Robes',
      description: 'Infused with raw ambient mana.',
      cost: 120,
      type: ShopItemType.outfit,
      icon: '🔮',
      rarity: 'Epic',
    ),
    ShopItem(
      id: 'outfit_rogue',
      name: 'Shadow Cloak',
      description: 'Perfect for staying hidden in shadows.',
      cost: 90,
      type: ShopItemType.outfit,
      icon: '👤',
      rarity: 'Common',
    ),
    ShopItem(
      id: 'outfit_scholar',
      name: 'Scholar\'s Gown',
      description: 'Worn by masters of the academy.',
      cost: 80,
      type: ShopItemType.outfit,
      icon: '🎓',
      rarity: 'Common',
    ),
    ShopItem(
      id: 'outfit_artist',
      name: 'Artist\'s Apron',
      description: 'Splattered with magical paint.',
      cost: 80,
      type: ShopItemType.outfit,
      icon: '🎨',
      rarity: 'Common',
    ),

    // Hairstyles
    ShopItem(
      id: 'hair_spiky',
      name: 'Spiky Mane',
      description: 'An aggressive, energetic cut.',
      cost: 50,
      type: ShopItemType.hairstyle,
      icon: '💇',
      rarity: 'Common',
    ),
    ShopItem(
      id: 'hair_long',
      name: 'Long Locks',
      description: 'Elegant, flowing locks.',
      cost: 55,
      type: ShopItemType.hairstyle,
      icon: '💇‍♀️',
      rarity: 'Common',
    ),
    ShopItem(
      id: 'hair_mohawk',
      name: 'Punk Mohawk',
      description: 'A rebellious mohawk style.',
      cost: 60,
      type: ShopItemType.hairstyle,
      icon: '💇‍♂️',
      rarity: 'Rare',
    ),

    // Accessories
    ShopItem(
      id: 'acc_shield',
      name: 'Aegis Shield',
      description: 'Blocks any incoming boss blow.',
      cost: 150,
      type: ShopItemType.accessory,
      icon: '🛡️',
      rarity: 'Rare',
    ),
    ShopItem(
      id: 'acc_staff',
      name: 'Crystal Staff',
      description: 'Focuses magic energy.',
      cost: 130,
      type: ShopItemType.accessory,
      icon: '🪄',
      rarity: 'Rare',
    ),
    ShopItem(
      id: 'acc_wings',
      name: 'Angel Wings',
      description: 'Graceful feathery wings.',
      cost: 200,
      type: ShopItemType.accessory,
      icon: '🪽',
      rarity: 'Legendary',
    ),

    // Themes
    ShopItem(
      id: 'theme_forest',
      name: 'Forest Haven',
      description: 'Calm, soothing green woodland theme.',
      cost: 250,
      type: ShopItemType.theme,
      icon: '🌲',
      rarity: 'Rare',
    ),
    ShopItem(
      id: 'theme_ocean',
      name: 'Ocean Depths',
      description: 'Peaceful deep blue aquatic theme.',
      cost: 250,
      type: ShopItemType.theme,
      icon: '🌊',
      rarity: 'Rare',
    ),
    ShopItem(
      id: 'theme_sunset',
      name: 'Sunset Peaks',
      description: 'Warm scenic mountain orange theme.',
      cost: 250,
      type: ShopItemType.theme,
      icon: '🌅',
      rarity: 'Rare',
    ),
    ShopItem(
      id: 'theme_crimson',
      name: 'Crimson Keep',
      description: 'High-energy fiery red theme.',
      cost: 250,
      type: ShopItemType.theme,
      icon: '🌋',
      rarity: 'Rare',
    ),

    // Consumables
    ShopItem(
      id: 'consumable_xp_boost',
      name: 'Elixir of Wisdom',
      description: 'Drink to instantly gain +100 XP.',
      cost: 40,
      type: ShopItemType.consumable,
      icon: '🧪',
      rarity: 'Common',
    ),
    ShopItem(
      id: 'consumable_streak_shield',
      name: 'Streak Aegis',
      description: 'Saves your streak if you miss a day.',
      cost: 75,
      type: ShopItemType.consumable,
      icon: '🛡️',
      rarity: 'Rare',
    ),
  ];

  static ShopItem? getById(String id) {
    for (final item in catalog) {
      if (item.id == id) return item;
    }
    return null;
  }
}
