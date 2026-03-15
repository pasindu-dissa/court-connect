const mongoose = require('mongoose');
require('dotenv').config();
mongoose.connect('mongodb+srv://pasindu:courtconnect123@courtconnect.7ogtn8k.mongodb.net/?appName=CourtConnect')
.then(() => { console.log("DB connected successfully"); process.exit(0); })
.catch((err) => { console.error("DB connection error:", err); process.exit(1); });
