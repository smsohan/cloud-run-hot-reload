const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs').promises;
const path = require('path');

const app = express();
const port = process.env.PORT || 8000;

app.use(bodyParser.json({ limit: '50mb' }));

app.post('/sync', async (req, res) => {
    const files = req.body;
    const promises = [];

    for (const filePath in files) {
        if (Object.hasOwnProperty.call(files, filePath)) {
            const promise = (async () => {
                const encodedContent = files[filePath];
                const decodedContent = Buffer.from(encodedContent, 'base64');

                const dirname = path.dirname(filePath);
                await fs.mkdir(dirname, { recursive: true });
                await fs.writeFile(filePath, decodedContent);
            })();
            promises.push(promise);
        }
    }

    try {
        await Promise.all(promises);
        res.status(200).send('Files synced successfully.');
    } catch (error) {
        console.error('Error syncing files:', error);
        res.status(500).send('Error syncing files.');
    }
});

app.listen(port, () => {
    console.log(`Server listening at http://localhost:${port}`);
});
