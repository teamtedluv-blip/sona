const express = require("express");
const sqlite3 = require("sqlite3").verbose();
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

// database
const db = new sqlite3.Database("./sona.db");

// create table
db.run(`
  CREATE TABLE IF NOT EXISTS businesses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    type TEXT,
    location TEXT,
    phone TEXT
  )
`);

// test route
app.get("/", (req, res) => {
  res.send("Server is running 🚀");
});

// get all businesses
app.get("/businesses", (req, res) => {
  db.all("SELECT * FROM businesses", [], (err, rows) => {
    if (err) return res.status(500).json(err);
    res.json(rows);
  });
});

// add business
app.post("/businesses", (req, res) => {
  const { name, type, location, phone } = req.body;

  db.run(
    `INSERT INTO businesses (name, type, location, phone)
     VALUES (?, ?, ?, ?)`,
    [name, type, location, phone],
    function (err) {
      if (err) return res.status(500).json(err);
      res.json({ id: this.lastID });
    }
  );
});

app.listen(3000, () => {
  console.log("Server running on http://localhost:3000");
});