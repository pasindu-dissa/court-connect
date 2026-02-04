// searchService.js
const ccDB = require('./mockDB'); 

// Distance calculation using Haversine formula
function getDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Radius of the earth in KM

    // Convert degree values to radians
    const dLat = (lat2 - lat1) * (Math.PI / 180);
    const dLon = (lon2 - lon1) * (Math.PI / 180);

    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * (Math.PI / 180)) *
        Math.cos(lat2 * (Math.PI / 180)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);

    // Calculate angular distance
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c; // Distance in KM
}

// Search courts within radius
const findMatchesInRadius = (userLat, userLon, radiusKm) => {
    console.log(` Searching courts within ${radiusKm} KM`);

    return ccDB.matches
        .map(match => {
            const distance = getDistance(
                userLat,
                userLon,
                match.loc.lat,
                match.loc.lon
            );

            return {
                ...match,                 // keep original court data
                distance: Number(distance.toFixed(2)) // Distance in KM
            };
        })
        .filter(match => match.distance <= radiusKm); // Filter courts inside the given radius
};

module.exports = { findMatchesInRadius };  // Export function to be used in routes or controllers
