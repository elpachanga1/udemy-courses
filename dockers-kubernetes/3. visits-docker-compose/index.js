const express = require('express');
const { createClient } = require('redis');

const app = express();
const PORT = process.env.PORT || 8080;
const client = createClient({
    socket: {
        host: 'redis-server',
        port: 6379
    }
});

// Connect to Redis and initialize
client.connect().then(async () => {
    console.log('Connected to Redis');
    await client.set('visits', '0');
}).catch(err => {
    console.error('Redis connection error:', err);
});

app.get('/', async (req, res) => {
    try {
        const visits = await client.get('visits');
        res.send(`Number of visits is: ${visits}`);
        await client.set('visits', parseInt(visits) + 1);
    } catch (err) {
        res.status(500).send('Error: ' + err.message);
    }
});

app.listen(PORT, () => {
    console.log(`App listening on port ${PORT}`);
});