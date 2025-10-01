const express = require('express');
const router = express.Router();
const Todo = require('../models/todo');

// GET all todos
router.get('/', async (req, res) => {
    const todos = await Todo.find();
    res.json(todos);
});

// POST create todo
router.post('/', async (req, res) => {
    const newTodo = new Todo(req.body);
    await newTodo.save();
    res.status(201).json(newTodo);
});

// GET todo by ID
router.get('/:id', async (req, res) => {
    const todo = await Todo.findById(req.params.id);
    if (!todo) return res.status(404).json({ message: "Todo not found" });
    res.json(todo);
});

// PUT update todo
router.put('/:id', async (req, res) => {
    const todo = await Todo.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!todo) return res.status(404).json({ message: "Todo not found" });
    res.json(todo);
});

// DELETE todo
router.delete('/:id', async (req, res) => {
    const todo = await Todo.findByIdAndDelete(req.params.id);
    if (!todo) return res.status(404).json({ message: "Todo not found" });
    res.json({ message: "Todo deleted" });
});

module.exports = router;
