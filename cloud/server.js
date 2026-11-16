const express = require('express');
const helmet = require('helmet');
require('dotenv').config();

const app = express();
app.use(helmet()); // Security headers (OWASP)
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/health', (req, res) => res.json({ status: 'ok' }));
app.use(require('./routes/products'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`App on port ${PORT}`));