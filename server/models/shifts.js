const mongoose = require('mongoose');

const shiftSchema = new mongoose.Schema({
    employeeid: {
    type: Number,
    required: true
    },

    locationid: {
    type: String,
    required: true
    },

    scheduleStart: {
    type: Date,
    required: true
    }, 
    
    scheduleEnd: {
    type: Date,
    required: true
    },
    
    clockIn: {
    type: Boolean,
    default: false
    },
    
    clockOut: {
    type: Boolean,
    default: true
    },
    
    managerApproval: {
    type: Boolean,
    default: false
    }
});

const ShiftModel = mongoose.model('shifts', shiftSchema);
module.exports = ShiftModel;