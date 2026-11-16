const router = require('express').Router();
const pool = require('../db');

// Endpoint 1 (Read): daftar produk + nama kategori
router.get('/api/products', async (req, res) => {
    try {
        const { rows } = await pool.query(
            `SELECT p.*, c.name AS category
       FROM products p
       JOIN categories c ON c.id = p.category_id
       ORDER BY p.id`
        );
        res.json(rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Endpoint 2 (Read): detail satu produk
router.get('/api/products/:id', async (req, res) => {
    const id = Number(req.params.id);
    // Validasi input (OWASP)
    if (!Number.isInteger(id) || id < 1 || id > 2147483647) {
        return res.status(400).json({ error: 'ID tidak valid' });
    }
    try {
        const { rows } = await pool.query(
            `SELECT p.*, c.name AS category
       FROM products p
       JOIN categories c ON c.id = p.category_id
       WHERE p.id = $1`,
            [id] // parameterized query -> cegah SQL injection
        );
        if (!rows[0]) return res.status(404).json({ error: 'Not found' });
        res.json(rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

module.exports = router;