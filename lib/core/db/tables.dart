const String employeeTable = '''
CREATE TABLE employees (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  mobile TEXT UNIQUE,
  userId TEXT UNIQUE,
  password TEXT,
  designation TEXT,
  faceEmbedding TEXT,
  photoPath TEXT,
  role TEXT,
  createdAt TEXT
)
''';


const String locationTable = '''
CREATE TABLE locations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  radius REAL NOT NULL
)
''';

const String attendanceTable = '''
CREATE TABLE attendance (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  employeeId INTEGER,
  date TEXT,
  time TEXT,
  locationName TEXT,
  photoPath TEXT,
  type TEXT
)
''';
