import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



import '../Admin_Module/Model/Rent.dart';
import '../Admin_Module/Model/RentDetail.dart';
import '../Admin_Module/Model/User.dart'; // Update the path as needed

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static Database? _database1;
  static Database? _database3;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();

    return _database!;

  }

  Future<Database> get database3 async {
    if (_database3 != null) return _database3!;
    _database3 = await _initDatabase2();
    return _database3!;
  }

  Future<Database> _initDatabase2() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'rent_data.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE rents(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            phone_number TEXT,
            name TEXT,
            paid_rent REAL,
            unpaid_rent REAL
          )
          ''',
        );
      },
      version: 1,
    );
  }

  Future<void> insertRent(Rent rent) async {
    final db = await database3;
    await db!.insert(
      'rents',
      rent.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Rent>> getRents() async {
    final db = await database3;
    final List<Map<String, dynamic>> maps = await db!.query('rents');
    return List.generate(maps.length, (i) {
      return Rent.fromMap(maps[i]);
    });
  }
  Future<Database> get database1 async {
    if (_database1 != null) return _database1!;
    _database1 = await _initDatabase1();

    return _database1!;

  }
  Future<Database> _initDatabase1() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            user_id INTEGER PRIMARY KEY,
            admin_id INTEGER,
            name TEXT,
            email_id TEXT,
            username TEXT,
            phone_number TEXT,
            room_occupied_date TEXT,
            password TEXT,
            role TEXT,
            deposit INTEGER,
            is_login INTEGER,
            is_active INTEGER,
            created_date TEXT,
            updated_date TEXT
          )
        ''');
      },
    );
  }
  Future<Database> _initDatabase() async {

    String path = join(await getDatabasesPath(), 'rent_details.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE rent_details (
            rent_details_id INTEGER PRIMARY KEY,
            user_id INTEGER,
            rent_received_on TEXT,
            rent_amount INTEGER,
            light_bill_amount INTEGER,
            comment TEXT,
            status TEXT,
            created_date TEXT,
            updated_date TEXT
          )
        ''');
      },
    );
  }



  Future<int> getUserCount() async {
    final db = await _database;
    final count = Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM users'));
    return count ?? 0;
  }
  Future<bool> hasPosts() async {
    final db = await database1;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users'));
    return count != 0;
  }
  Future<void> insertUser(User user) async {
    final db = await database1;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<List<User>> fetchInactiveUsers() async {
    final db = await database1;

    // Query to fetch users where isActive == 0
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'is_active = ?',
      whereArgs: [0],
    );

    // Convert the List<Map<String, dynamic>> to List<User>
    return List.generate(maps.length, (i) {
      return User.fromJson(maps[i]);
    });
  }
  Future<void> updateUserStatus(String userId, int newStatus) async {
    final db = await database1;

    // Update the is_active status of a specific user
    await db.update(
      'users',
      {'is_active': newStatus}, // New status value
      where: 'user_id = ?', // Condition to identify the record
      whereArgs: [userId], // Arguments for the condition
    );
  }
  Future<List<User>> fetchactiveUsers() async {
    final db = await database1;

    // Query to fetch users where isActive == 0
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'is_active = ?',
      whereArgs: [1],
    );

    // Convert the List<Map<String, dynamic>> to List<User>
    return List.generate(maps.length, (i) {
      return User.fromJson(maps[i]);
    });
  }

  Future<List<User>> fetchUsers(int adminId) async {
    final db = await database1;

    // Query the 'users' table with a WHERE clause for the admin_id
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'admin_id = ?',
      whereArgs: [adminId],
    );

    return List.generate(maps.length, (i) {
      return User.fromJson(maps[i]);
    });
  }
  Future<void> insertRentDetail(RentDetail rentDetail) async {
    final db = await database;
    await db.insert(
      'rent_details',
      rentDetail.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<List<RentDetail>> fetchRentDetails(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rent_details',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return RentDetail.fromJson(maps[i]);
    });
  }

}
