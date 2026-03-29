const verifySuperAdmin = (req, res, next) => {
    const adminKey = req.headers['x-super-admin-key'];
    const expectedKey = process.env.SUPER_ADMIN_PASSWORD || 'admin123';
    
    if (adminKey && adminKey === expectedKey) {
        next();
    } else {
        res.status(401).json({ message: 'Unauthorized: Invalid Super Admin Key' });
    }
};

module.exports = verifySuperAdmin;
