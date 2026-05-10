import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'hardware_vault.db';
  static const _dbVersion = 1;
  static const _table = 'pc_builds';

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            cpu_id TEXT,
            gpu_id TEXT,
            ram_gb INTEGER NOT NULL DEFAULT 16,
            ram_type TEXT NOT NULL DEFAULT 'DDR5',
            storage_gb INTEGER NOT NULL DEFAULT 1000,
            storage_type TEXT NOT NULL DEFAULT 'NVMe SSD',
            psu_watts TEXT,
            case_model TEXT,
            notes TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Map<String, Object?> _toRow(PCBuild b) => {
        'id': b.id,
        'name': b.name,
        'cpu_id': b.cpuId,
        'gpu_id': b.gpuId,
        'ram_gb': b.ramGB,
        'ram_type': b.ramType,
        'storage_gb': b.storageGB,
        'storage_type': b.storageType,
        'psu_watts': b.psuWatts,
        'case_model': b.caseModel,
        'notes': b.notes,
        'created_at': b.createdAt.toIso8601String(),
        'updated_at': b.updatedAt.toIso8601String(),
      };

  PCBuild _fromRow(Map<String, Object?> row) => PCBuild(
        id: row['id'] as String,
        name: row['name'] as String,
        cpuId: row['cpu_id'] as String?,
        gpuId: row['gpu_id'] as String?,
        ramGB: row['ram_gb'] as int,
        ramType: row['ram_type'] as String,
        storageGB: row['storage_gb'] as int,
        storageType: row['storage_type'] as String,
        psuWatts: row['psu_watts'] as String?,
        caseModel: row['case_model'] as String?,
        notes: row['notes'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );

  Future<List<PCBuild>> getAllBuilds() async {
    final db = await database;
    final rows = await db.query(_table, orderBy: 'updated_at DESC');
    return rows.map(_fromRow).toList();
  }

  Future<void> upsertBuild(PCBuild build) async {
    final db = await database;
    await db.insert(_table, _toRow(build),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteBuild(String id) async {
    final db = await database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete(_table);
  }
}
