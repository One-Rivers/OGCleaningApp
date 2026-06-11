const express = require('express');
const app = express();
const mongoose = require('mongoose');
const ShiftModel = require('./models/shifts');
const cors = require('cors');
app.use(express.json());
app.use(cors());



mongoose.connect('mongodb://rios:scheduler@ac-ffjhglu-shard-00-00.fzuknqz.mongodb.net:27017,ac-ffjhglu-shard-00-01.fzuknqz.mongodb.net:27017,ac-ffjhglu-shard-00-02.fzuknqz.mongodb.net:27017/work?ssl=true&replicaSet=atlas-cnr56e-shard-0&authSource=admin&appName=shifts');
//Issue was that I had scheduler instead of work in the connection string. 
// I had to change it to work because that is the name of the database in MongoDB Atlas. 
// I also had to add appName=shifts to the connection string to specify the name of the application connecting to the database.

app.listen(3001, () => {
  console.log('Scheduler server is running and moving forward!');
});
//mongoose.connect('mongodb://rios:scheduler@ac-ffjhglu-shard-00-00.fzuknqz.mongodb.net:27017,ac-ffjhglu-shard-00-01.fzuknqz.mongodb.net:27017,ac-ffjhglu-shard-00-02.fzuknqz.mongodb.net:27017/scheduler?ssl=true&replicaSet=atlas-cnr56e-shard-0&authSource=admin&appName=shifts');

app.get ("/getShifts",async (req, res) => {
    try {
        const results = await ShiftModel.find({});
        console.log("Shifts retrieved successfully");
        res.json(results);
    } catch (error) {
        console.error("Error retrieving shifts:", error);
        res.status(500).json({ error: "An error occurred while retrieving shifts" });
    }
});

app.post("/createShift", async (req, res) => {
    const shiftData = req.body;
    const newShift = new ShiftModel(shiftData);
    await newShift.save();

    res.json(shiftData);
});
