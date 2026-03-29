const User = require('../models/User');

const checkAuth = (req, res) => {
    res.status(200).json({ success: true, message: 'Authenticated' });
};

const getUsers = async (req, res) => {
    try {
        const users = await User.find({}, 'name email role createdAt').sort({ createdAt: -1 });
        res.status(200).json(users);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error fetching users' });
    }
};

const updateRole = async (req, res) => {
    try {
        const { id } = req.params;
        const { role } = req.body;

        if (!['player', 'court_owner'].includes(role)) {
            return res.status(400).json({ message: 'Role can exclusively be player or court_owner from this dashboard' });
        }

        const user = await User.findById(id);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        user.role = role;
        await user.save();

        res.status(200).json({ message: `User role updated to ${role}`, user });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error updating role' });
    }
};

module.exports = {
    checkAuth,
    getUsers,
    updateRole
};
