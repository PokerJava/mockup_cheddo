module.exports = {
  resultCode(code) {
    for (data of require("../config").resultCode) {
      if (data.resultCode == code) {
        return data;
      }
    }
  }
};
