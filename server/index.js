require('dotenv').config();
const express = require('express');
const app = express();
const mongoose = require('mongoose');
const ShiftModel = require('./models/shifts');
const EmployeeModel = require('./models/employee');
const LocationModel = require('./models/locations');
const cors = require('cors');

app.use(express.json());
app.use(cors());

mongoose.connect(process.env.MONGODB_URI); /* is defined in seperate file to avoid hardcoding sensitive info */
const db = mongoose.connection; // Log successful connection
db.once('open', () => {
    console.log('Connected to MongoDB successfully');
});

db.on('error', console.error.bind(console, 'MongoDB connection error:'));
/****************************************************************************************************************************/
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
                role: employee.role,
                certification: employee.certification
            }
        });
    } catch (error) {
        console.error("Login error:", error);
        res.status(500).json({ error: 'Server error during login' });
    }
});
/****************************************************************************************************************************/
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
/****************************************************************************************************************************/
app.post("/createShifts", async (req, res) => {
    try {
        const shiftData = req.body;
        // the shift's locationid must match a real location's name
        const location = await LocationModel.findOne({ name: shiftData.locationid });
        if (!location) {
            return res.status(400).json({ error: 'Unknown location: ' + shiftData.locationid });
        }
        const newShift = new ShiftModel(shiftData);
        await newShift.save();
        res.json(shiftData);
    } catch (error) {
        console.error("Error creating shift:", error);
        res.status(500).json({ error: "An error occurred while creating shift" });
    }
});
/****************************************************************************************************************************/
app.delete("/deleteShift/:id", async (req, res) => {
    try {
        const deleted = await ShiftModel.findByIdAndDelete(req.params.id);
        if (!deleted) {
            return res.status(404).json({ error: 'Shift not found' });
        }
        res.json({ success: true });
    } catch (error) {
        console.error("Error deleting shift:", error);
        res.status(500).json({ error: "An error occurred while deleting shift" });
    }
});
/****************************************************************************************************************************/
// PATCH /updateShift/:id — update fields on a shift (used by Punch In/Out)
app.patch("/updateShift/:id", async (req, res) => {
    try {
        const updated = await ShiftModel.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updated) {
            return res.status(404).json({ error: 'Shift not found' });
        }
        res.json(updated);
    } catch (error) {
        console.error("Error updating shift:", error);
        res.status(500).json({ error: "An error occurred while updating shift" });
    }
});
/****************************************************************************************************************************/
// GET /getEmployees — employee list for the manager dashboard.
// The projection string only returns these fields, so passwords and emails never leave the server.
app.get("/getEmployees", async (req, res) => {
    try {
        const employees = await EmployeeModel.find({}, 'name employeeId role certification');
        res.json(employees);
    } catch (error) {
        console.error("Error retrieving employees:", error);
        res.status(500).json({ error: "An error occurred while retrieving employees" });
    }
});
/****************************************************************************************************************************/
// GET /getLocations — list all job sites (used by the Add Shift dropdown)
app.get("/getLocations", async (req, res) => {
    try {
        const locations = await LocationModel.find({});
        res.json(locations);
    } catch (error) {
        console.error("Error retrieving locations:", error);
        res.status(500).json({ error: "An error occurred while retrieving locations" });
    }
});
/****************************************************************************************************************************/
// POST /createLocations — add a new job site
app.post("/createLocations", async (req, res) => {
    try {
        const newLocation = new LocationModel(req.body);
        await newLocation.save();
        res.json(newLocation);
    } catch (error) {
        console.error("Error creating location:", error);
        res.status(500).json({ error: "An error occurred while creating location" });
    }
});
/****************************************************************************************************************************/
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
    console.log(`Scheduler server is running on port ${PORT} and moving forward!`);
});
