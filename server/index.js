require('dotenv').config();
const express = require('express');
const app = express();
const mongoose = require('mongoose');
const ShiftModel = require('./models/shifts');
const cors = require('cors');

app.use(express.json());
app.use(cors());

mongoose.connect(process.env.MONGODB_URI);

app.get("/getShifts", async (req, res) => {
    try {
        const results = await ShiftModel.find({});
        console.log("Shifts retrieved successfully");
        res.json(results);
    } catch (error) {
        console.error("Error retrieving shifts:", error);
        res.status(500).json({ error: "An error occurred while retrieving shifts" });
    }
});

app.post("/createShifts", async (req, res) => {
    try {                                        // ✅ added try/catch
        const shiftData = req.body;
        const newShift = new ShiftModel(shiftData);
        await newShift.save();
        res.json(shiftData);
    } catch (error) {                           // ✅ catches save errors
        console.error("Error creating shift:", error);
        res.status(500).json({ error: "An error occurred while creating shift" });
    }
});

app.listen(3001, () => {                        // ✅ moved to bottom
    console.log('Scheduler server is running and moving forward!');
});