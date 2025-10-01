const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const todosRoute = require('./routes/todos');

const app = express();
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://mongo:27017/todos';

app.use(bodyParser.json());
app.use('/todos', todosRoute);

mongoose.connect(MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => console.log("MongoDB connected"))
  .catch(err => console.log(err));

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
