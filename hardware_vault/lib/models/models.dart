// ─── CPU Model ────────────────────────────────────────────────────────────────
class CPU {
  final String id;
  final String name;
  final String brand; // 'Intel' | 'AMD'
  final String series;
  final int cores;
  final int threads;
  final double baseClock;
  final double boostClock;
  final int tdp;
  final String socket;
  final double price;
  final String imageUrl;
  final String generation;
  final String cache;
  final String process;
  final double benchmark;
  final bool hasIGPU;

  const CPU({
    required this.id,
    required this.name,
    required this.brand,
    required this.series,
    required this.cores,
    required this.threads,
    required this.baseClock,
    required this.boostClock,
    required this.tdp,
    required this.socket,
    required this.price,
    required this.imageUrl,
    required this.generation,
    required this.cache,
    required this.process,
    required this.benchmark,
    required this.hasIGPU,
  });
}

// ─── GPU Model ────────────────────────────────────────────────────────────────
class GPU {
  final String id;
  final String name;
  final String brand; // 'AMD' | 'Intel' | 'Nvidia'
  final String series;
  final int vram;
  final String vramType;
  final int tdp;
  final double price;
  final String imageUrl;
  final String architecture;
  final int cudaCores;
  final int memBandwidth;
  final String process;
  final double benchmark;
  final String slot;

  const GPU({
    required this.id,
    required this.name,
    required this.brand,
    required this.series,
    required this.vram,
    required this.vramType,
    required this.tdp,
    required this.price,
    required this.imageUrl,
    required this.architecture,
    required this.cudaCores,
    required this.memBandwidth,
    required this.process,
    required this.benchmark,
    required this.slot,
  });
}

// ─── News Article Model ────────────────────────────────────────────────────────
class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String source;
  final String category;
  final String imageUrl;
  final DateTime publishedAt;
  final bool isBreaking;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    required this.category,
    required this.imageUrl,
    required this.publishedAt,
    required this.isBreaking,
  });
}

// ─── PC Build Model ────────────────────────────────────────────────────────────
class PCBuild {
  final String id;
  String name;
  String? cpuId;
  String? gpuId;
  int ramGB;
  String ramType;
  int storageGB;
  String storageType;
  String? psuWatts;
  String? caseModel;
  String notes;
  DateTime createdAt;
  DateTime updatedAt;

  PCBuild({
    required this.id,
    required this.name,
    this.cpuId,
    this.gpuId,
    this.ramGB = 16,
    this.ramType = 'DDR5',
    this.storageGB = 1000,
    this.storageType = 'NVMe SSD',
    this.psuWatts,
    this.caseModel,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'cpuId': cpuId,
    'gpuId': gpuId,
    'ramGB': ramGB,
    'ramType': ramType,
    'storageGB': storageGB,
    'storageType': storageType,
    'psuWatts': psuWatts,
    'caseModel': caseModel,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory PCBuild.fromMap(Map<String, dynamic> map) => PCBuild(
    id: map['id'],
    name: map['name'],
    cpuId: map['cpuId'],
    gpuId: map['gpuId'],
    ramGB: map['ramGB'] ?? 16,
    ramType: map['ramType'] ?? 'DDR5',
    storageGB: map['storageGB'] ?? 1000,
    storageType: map['storageType'] ?? 'NVMe SSD',
    psuWatts: map['psuWatts'],
    caseModel: map['caseModel'],
    notes: map['notes'] ?? '',
    createdAt: DateTime.parse(map['createdAt']),
    updatedAt: DateTime.parse(map['updatedAt']),
  );
}
