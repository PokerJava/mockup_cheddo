const express = require("express");
const serverRouter = new express.Router();

serverRouter
    .get("/", async (req, res, next) => {
        console.log('asdasd')
        resHeaders = { "Content-Type": "application/json" }
        res.set(resHeaders);
        return res.status(200).send({aa:'123'});
    })
module.exports = serverRouter;