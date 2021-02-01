const express = require("express");
const api = new express.Router();
const loginRouter = require("./login");
// const otpRouter = require("./otp");

api.use("/login", loginRouter);
// api.use("/otp", otpRouter);

module.exports = api;
