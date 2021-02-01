const express = require("express");
const serverRouter = new express.Router();

serverRouter.get("/", async (req, res, next) => {
  let resp = {
    auth_session_token: "87a235815b8d6661ac73329f75815b8d6661ac73329f815"
  };
  return res.json(resp);
});

module.exports = serverRouter;
