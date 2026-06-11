const mongoose = require('mongoose');

const employeeSchema = new mongoose.Schema({
    name:       { 
        type: String, 
        required: true 
    },
    email:      { 
        type: String, 
        required: true, 
        unique: true 
    },
    password:   { 
        type: String, 
        required: true
    },
    employeeId: { 
        type: Number, 
        required: true, 
        unique: true },
    role:       { 
        type: String, 
        enum: ['employee', 'manager'], 
        default: 'employee' 
    },
    certification: { 
        type: Boolean, 
        default: false /* If they are true they can change the schedules, if false they can only view them. */
    }

});

const EmployeeModel = mongoose.model('employees', employeeSchema);
module.exports = EmployeeModel;
