require('dotenv').config();
const express = require('express');
const app = express();
const mongoose = require('mongoose');
const ShiftModel = require('./models/shifts');
const EmployeeModel = require('./models/employee');
const cors = require('cors');

app.use(express.json());
app.use(cors());

mongoose.connect(process.env.MONGODB_URI);

// POST /login — check employee credentials against MongoDB
app.post("/login", async (req, res) => {
    try {
        const { email, password } = req.body;
        const employee = await EmployeeModel.findOne({ email, password });
        if (!employee) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }
        res.json({
            success: true,
            employee: {
                id: employee._id,
                name: employee.name,
                employeeId: employee.employeeId,
                role: employee.role
            }
        });
    } catch (error) {
        console.error("Login error:", error);
        res.status(500).json({ error: 'Server error during login' });
    }
});

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
    try {                                     
        const shiftData = req.body;
        const newShift = new ShiftModel(shiftData);
        await newShift.save();
        res.json(shiftData);
    } catch (error) {                          
        console.error("Error creating shift:", error);
        res.status(500).json({ error: "An error occurred while creating shift" });
    }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
    console.log(`Scheduler server is running on port ${PORT} and moving forward!`);
});