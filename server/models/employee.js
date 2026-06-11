const mongoose = require('mongoose');

const employeeSchema = new mongoose.Schema({
    name:       { type: String, required: true },
    email:      { type: String, required: true, unique: true },
    password:   { type: String, required: true },
    employeeId: { type: Number, required: true, unique: true },
    role:       { type: String, enum: ['employee', 'manager'], default: 'employee' }
});

const EmployeeModel = mongoose.model('employees', employeeSchema);
module.exports = EmployeeModel;
