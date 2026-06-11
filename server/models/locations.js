const mongoose = require('mongoose');


const locationSchema = new mongoose.Schema({
    name:    {
        type: String,
        required: true,
        unique: true
    },  // "Premier Office"
    address: {
        type: String,
        required: true
    },                 // "3195 28th St SE, Grand Rapids, MI 49512"
    lat:     {
        type: Number
    },                                  // 42.9123
    lng:     {
        type: Number
    }                                   // -85.5872
});

const LocationModel = mongoose.model('locations', locationSchema);
module.exports = LocationModel;